SHELL := /bin/bash -o pipefail

NEXT_VERSION := $(shell go env GOPATH)/bin/next_version
JUSTRUN := $(shell go env GOPATH)/bin/justrun
# Build the renderer locally rather than relying on whatever version is
# installed on $PATH.
RENDERER := tmp/bin/burke_services_renderer

WATCH_TARGETS := $(shell find . -path ./worktrees -prune -o -name '*.md' -print)
GO_FILES := $(shell find . -path ./worktrees -prune -o -name '*.go' -print)

# Every page we publish. public/2016-donations.html is the original URL for
# the 2016 page, kept so old links keep working.
PAGES := \
	public/index.html \
	public/ethics.html \
	public/segment.html \
	public/twilio.html \
	public/capital-one-open-redirect.html \
	public/2016-donations.html \
	public/2016/donations.html \
	public/2017/donations.html

# public/markdown.css is an unmodified copy of markdown.css from
# github.com/kevinburke/markdowncss at this tag. To upgrade, change the tag
# and run "make sync-css". Site-specific rules go in public/site.css.
MARKDOWNCSS_VERSION := v1.0.0
MARKDOWNCSS_URL := https://raw.githubusercontent.com/kevinburke/markdowncss/$(MARKDOWNCSS_VERSION)/markdown.css

compile: $(PAGES)

sync-css:
	curl --fail --silent --show-error --location --output public/markdown.css.tmp $(MARKDOWNCSS_URL)
	@mv public/markdown.css.tmp public/markdown.css

# Render to a temp file first so a failed render doesn't leave an empty or
# truncated page behind.
define render
	@mkdir -p $(dir $@)
	$(RENDERER) $< > $@.tmp
	@mv $@.tmp $@
endef

public/%.html: %.md index.template $(RENDERER)
	$(render)

public/capital-one-open-redirect.html: open-redirect.md index.template $(RENDERER)
	$(render)

public/2016-donations.html public/2016/donations.html: 2016-donations.md index.template $(RENDERER)
	$(render)

public/2017/donations.html: 2017-donations.md index.template $(RENDERER)
	$(render)

$(RENDERER): $(GO_FILES) go.mod go.sum
	go build -trimpath -o $@ ./burke_services_renderer

# Fails if any checked-in page is out of date with its Markdown source, if
# public/markdown.css doesn't match MARKDOWNCSS_VERSION, or if the Go code
# isn't formatted.
check: vet test-release
	go install github.com/kevinburke/differ@latest
	differ $(MAKE) --always-make compile
	differ $(MAKE) sync-css
	differ gofmt -w .

vet:
	go vet -trimpath ./...

lint: vet
	go install honnef.co/go/tools/cmd/staticcheck@latest
	$(shell go env GOPATH)/bin/staticcheck ./...

test: vet test-release
	go test -trimpath ./...

test-release:
	bash scripts/release_test.sh

$(JUSTRUN):
	go install github.com/jmhodges/justrun@latest

watch: $(JUSTRUN)
	$(JUSTRUN) -c 'make compile serve' $(WATCH_TARGETS) $(GO_FILES)

serve:
	go run -trimpath ./burke_services_server

$(NEXT_VERSION):
	go install github.com/kevinburke/bump_version/next_version@latest

# Commit the version and generated pages together, then tag that commit.
# Run in a release worktree with a clean index, renderer, and HTML. Sources
# must already match the checked-in HTML; stale pages abort before the bump.
release: $(NEXT_VERSION)
	+bash scripts/release.sh "$(NEXT_VERSION)" $(PAGES)

.PHONY: compile sync-css check lint vet test test-release watch serve release
