package main

import (
	"flag"
	"html/template"
	"log"
	"os"
	"os/exec"
)

func main() {
	flag.Parse()
	if flag.NArg() != 1 {
		log.Fatal("Usage: burke_services_renderer file-to-render")
	}
	cmd := exec.Command("markdown", flag.Arg(0))
	out, err := cmd.Output()
	if err != nil {
		log.Fatal(err)
	}
	// todo make this work with relative paths.
	tpl, err := template.ParseFiles("index.template")
	if err != nil {
		log.Fatal(err)
	}
	data := struct {
		Content template.HTML
	}{
		Content: template.HTML(out),
	}
	err = tpl.Execute(os.Stdout, data)
	if err != nil {
		log.Fatal(err)
	}
}
