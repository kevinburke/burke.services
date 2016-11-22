package main

import (
	"flag"
	"fmt"
	"net/http"
	"time"

	"github.com/kevinburke/handlers"
)

func main() {
	port := flag.Uint("port", 8901, "Port to listen on")
	flag.Parse()
	http.Handle("/", http.FileServer(http.Dir("./public")))
	go func() {
		time.Sleep(30 * time.Millisecond)
		fmt.Printf("Listening on port %d\n", *port)
	}()
	http.ListenAndServe(fmt.Sprintf(":%d", *port), handlers.Log(http.DefaultServeMux))
}
