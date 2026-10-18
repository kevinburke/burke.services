// Command burke_services_server serves the ./public directory for local
// development.
package main

import (
	"flag"
	"fmt"
	"log/slog"
	"net"
	"net/http"
	"os"

	"github.com/kevinburke/handlers"
)

func main() {
	port := flag.Uint("port", 8901, "Port to listen on")
	flag.Parse()
	http.Handle("/", http.FileServer(http.Dir("./public")))
	ln, err := net.Listen("tcp", fmt.Sprintf(":%d", *port))
	if err != nil {
		slog.Error("could not listen", "port", *port, "err", err)
		os.Exit(1)
	}
	slog.Info("listening", "port", *port)
	if err := http.Serve(ln, handlers.Log(http.DefaultServeMux)); err != nil {
		slog.Error("server exited", "err", err)
		os.Exit(1)
	}
}
