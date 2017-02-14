package main

import (
	"flag"
	"html/template"
	"log"
	"os"
	"os/exec"
	"runtime"
)

const Version = "1.10"

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
	tpl = tpl.Option("missingkey=error")
	if err != nil {
		log.Fatal(err)
	}
	data := struct {
		Content   template.HTML
		GoVersion string
		Version   string
	}{
		Content:   template.HTML(out),
		GoVersion: runtime.Version(),
		Version:   Version,
	}
	err = tpl.Execute(os.Stdout, data)
	if err != nil {
		log.Fatal(err)
	}
}
