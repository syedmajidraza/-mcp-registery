package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/exec"
	"os/signal"
	"sync"
	"syscall"
	"time"
)

const (
	installerPort = "3456"
	version       = "1.0.0"
)

// InstallRequest represents a request to install an MCP server
type InstallRequest struct {
	PackageIdentifier string `json:"packageIdentifier"`
	RegistryType      string `json:"registryType"`
	Version           string `json:"version"`
}

// InstallResponse represents the response of an installation request
type InstallResponse struct {
	Success bool   `json:"success"`
	Message string `json:"message"`
	JobID   string `json:"jobId,omitempty"`
}

// JobStatus represents the status of an installation job
type JobStatus struct {
	JobID     string    `json:"jobId"`
	Status    string    `json:"status"` // "pending", "running", "completed", "failed"
	Message   string    `json:"message"`
	Output    string    `json:"output,omitempty"`
	Error     string    `json:"error,omitempty"`
	StartedAt time.Time `json:"startedAt"`
	UpdatedAt time.Time `json:"updatedAt"`
}

type InstallerServer struct {
	jobs   map[string]*JobStatus
	jobsMu sync.RWMutex
}

func NewInstallerServer() *InstallerServer {
	return &InstallerServer{
		jobs: make(map[string]*JobStatus),
	}
}

func main() {
	server := NewInstallerServer()

	mux := http.NewServeMux()

	// CORS middleware
	corsMiddleware := func(next http.HandlerFunc) http.HandlerFunc {
		return func(w http.ResponseWriter, r *http.Request) {
			w.Header().Set("Access-Control-Allow-Origin", "*")
			w.Header().Set("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
			w.Header().Set("Access-Control-Allow-Headers", "Content-Type")

			if r.Method == "OPTIONS" {
				w.WriteHeader(http.StatusOK)
				return
			}

			next(w, r)
		}
	}

	// Health check endpoint
	mux.HandleFunc("/health", corsMiddleware(func(w http.ResponseWriter, r *http.Request) {
		json.NewEncoder(w).Encode(map[string]string{
			"status":  "healthy",
			"version": version,
		})
	}))

	// Install endpoint
	mux.HandleFunc("/install", corsMiddleware(server.handleInstall))

	// Job status endpoint
	mux.HandleFunc("/status/", corsMiddleware(server.handleStatus))

	httpServer := &http.Server{
		Addr:         ":" + installerPort,
		Handler:      mux,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
	}

	// Start server
	go func() {
		log.Printf("MCP Installer Server v%s starting on port %s", version, installerPort)
		log.Printf("CORS enabled for all origins")
		if err := httpServer.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("Server failed to start: %v", err)
		}
	}()

	// Graceful shutdown
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, os.Interrupt, syscall.SIGTERM)
	<-sigChan

	log.Println("Shutting down installer server...")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	if err := httpServer.Shutdown(ctx); err != nil {
		log.Printf("Error during shutdown: %v", err)
	}
	log.Println("Server stopped")
}

func (s *InstallerServer) handleInstall(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	if r.Method != http.MethodPost {
		w.WriteHeader(http.StatusMethodNotAllowed)
		json.NewEncoder(w).Encode(InstallResponse{
			Success: false,
			Message: "Method not allowed",
		})
		return
	}

	var req InstallRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(InstallResponse{
			Success: false,
			Message: "Invalid request body: " + err.Error(),
		})
		return
	}

	// Validate registry type
	if req.RegistryType != "npm" {
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(InstallResponse{
			Success: false,
			Message: fmt.Sprintf("Unsupported registry type: %s. Currently only 'npm' is supported.", req.RegistryType),
		})
		return
	}

	// Generate job ID
	jobID := fmt.Sprintf("job-%d", time.Now().UnixNano())

	// Create job status
	job := &JobStatus{
		JobID:     jobID,
		Status:    "pending",
		Message:   "Installation queued",
		StartedAt: time.Now(),
		UpdatedAt: time.Now(),
	}

	s.jobsMu.Lock()
	s.jobs[jobID] = job
	s.jobsMu.Unlock()

	// Start installation in background
	go s.runInstallation(jobID, &req)

	// Return job ID immediately
	json.NewEncoder(w).Encode(InstallResponse{
		Success: true,
		Message: "Installation started",
		JobID:   jobID,
	})
}

func (s *InstallerServer) handleStatus(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	if r.Method != http.MethodGet {
		w.WriteHeader(http.StatusMethodNotAllowed)
		return
	}

	// Extract job ID from path (format: /status/{jobID})
	jobID := r.URL.Path[len("/status/"):]
	if jobID == "" {
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(map[string]string{"error": "Job ID required"})
		return
	}

	s.jobsMu.RLock()
	job, exists := s.jobs[jobID]
	s.jobsMu.RUnlock()

	if !exists {
		w.WriteHeader(http.StatusNotFound)
		json.NewEncoder(w).Encode(map[string]string{"error": "Job not found"})
		return
	}

	json.NewEncoder(w).Encode(job)
}

func (s *InstallerServer) runInstallation(jobID string, req *InstallRequest) {
	s.updateJob(jobID, "running", "Installing package...", "", "")

	var cmd *exec.Cmd
	packageSpec := req.PackageIdentifier
	if req.Version != "" {
		packageSpec = fmt.Sprintf("%s@%s", req.PackageIdentifier, req.Version)
	}

	switch req.RegistryType {
	case "npm":
		cmd = exec.Command("npm", "install", "-g", packageSpec)
	default:
		s.updateJob(jobID, "failed", "Unsupported registry type", "", "")
		return
	}

	output, err := cmd.CombinedOutput()
	outputStr := string(output)

	if err != nil {
		s.updateJob(jobID, "failed", "Installation failed", outputStr, err.Error())
		return
	}

	s.updateJob(jobID, "completed", "Installation successful", outputStr, "")
}

func (s *InstallerServer) updateJob(jobID, status, message, output, errorMsg string) {
	s.jobsMu.Lock()
	defer s.jobsMu.Unlock()

	if job, exists := s.jobs[jobID]; exists {
		job.Status = status
		job.Message = message
		job.Output = output
		job.Error = errorMsg
		job.UpdatedAt = time.Now()
	}
}
