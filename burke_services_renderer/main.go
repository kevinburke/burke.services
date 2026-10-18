// Command burke_services_renderer renders a Markdown file to HTML using the
// site template (index.template in the current directory) and writes the
// result to stdout.
//
// It shells out to the "markdown" binary, which must pass raw HTML through
// unchanged (e.g. Gruber's Markdown.pl). Renderers that strip raw HTML are
// detected and rejected, since they silently drop images and links.
package main

import (
	"bytes"
	"flag"
	"fmt"
	"html/template"
	"log/slog"
	"os"
	"os/exec"
	"runtime"
)

const Version = "1.30"

// strippedHTMLMarker is the comment goldmark and some other renderers emit in
// place of raw HTML when "unsafe" rendering is disabled.
const strippedHTMLMarker = "raw HTML omitted"

func main() {
	version := flag.Bool("version", false, "Print the version and exit")
	flag.Usage = func() {
		fmt.Fprintf(os.Stderr, "Usage: burke_services_renderer [flags] file-to-render\n\n")
		flag.PrintDefaults()
	}
	flag.Parse()
	if *version {
		fmt.Fprintf(os.Stdout, "burke_services_renderer version %s (%s)\n", Version, runtime.Version())
		return
	}
	if flag.NArg() != 1 {
		flag.Usage()
		os.Exit(2)
	}
	if err := run(flag.Arg(0)); err != nil {
		slog.Error("could not render file", "file", flag.Arg(0), "err", err)
		os.Exit(1)
	}
}

func run(filename string) error {
	cmd := exec.Command("markdown", filename)
	cmd.Stderr = os.Stderr
	out, err := cmd.Output()
	if err != nil {
		return fmt.Errorf("running markdown: %w", err)
	}
	if bytes.Contains(out, []byte(strippedHTMLMarker)) {
		return fmt.Errorf("markdown output contains %q; the markdown binary on your PATH strips raw HTML, use one that passes it through", strippedHTMLMarker)
	}
	// todo make this work with relative paths.
	tpl, err := template.ParseFiles("index.template")
	if err != nil {
		return err
	}
	tpl = tpl.Option("missingkey=error")
	// The Go version is deliberately left out of the page: it would make
	// the output depend on the toolchain, so "make check" would fail any
	// time CI and a local build used different Go releases.
	data := struct {
		Content template.HTML
		Version string
	}{
		Content: template.HTML(out),
		Version: Version,
	}
	// Render into a buffer so a template error doesn't leave a partially
	// written page behind.
	var buf bytes.Buffer
	if err := tpl.Execute(&buf, data); err != nil {
		return err
	}
	_, err = os.Stdout.Write(buf.Bytes())
	return err
}
