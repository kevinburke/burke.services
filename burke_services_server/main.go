package main

import (
	"flag"
	"fmt"
	"log"
	"net"
	"net/http"

	"github.com/kevinburke/handlers"
)

func main() {
	port := flag.Uint("port", 8901, "Port to listen on")
	flag.Parse()
	http.Handle("/", http.FileServer(http.Dir("./public")))
	ln, err := net.Listen("tcp", fmt.Sprintf(":%d", *port))
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("Listening on port %d\n", *port)
	http.Serve(ln, handlers.Log(http.DefaultServeMux))
}
