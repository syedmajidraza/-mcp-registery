package v0

import (
	"net/http"
	"time"
)

// SSEHandler streams heartbeat events to the client every 5 seconds.
func SSEHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/event-stream")
	w.Header().Set("Cache-Control", "no-cache")
	w.Header().Set("Connection", "keep-alive")

	flusher, ok := w.(http.Flusher)
	if !ok {
		http.Error(w, "Streaming unsupported", http.StatusInternalServerError)
		return
	}

	for {
		_, open := <-r.Context().Done()
		if !open {
			return
		}
		// Send heartbeat event
		w.Write([]byte("event: heartbeat\ndata: alive\n\n"))
		flusher.Flush()
		// Wait 5 seconds
		time.Sleep(5 * time.Second)
	}
}
