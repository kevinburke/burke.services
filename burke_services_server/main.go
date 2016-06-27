package main

import (
	"flag"
	"fmt"
	"net/http"
	"time"
)

func main() {
	port := flag.Uint("port", 8901, "Port to listen on")
	flag.Parse()
	http.Handle("/", http.FileServer(http.Dir("./public")))
	go func() {
		time.Sleep(30 * time.Millisecond)
		fmt.Sprintf("Listening on port %d", *port)
	}()
	http.ListenAndServe(fmt.Sprintf(":%d", *port), nil)
}
