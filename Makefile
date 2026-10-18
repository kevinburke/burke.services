SHELL := /bin/bash -o pipefail

BUMP_VERSION := $(shell go env GOPATH)/bin/bump_version
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

compile: $(PAGES)

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

# Fails if any checked-in page is out of date with its Markdown source, or if
# the Go code isn't formatted.
check: vet
	go install github.com/kevinburke/differ@latest
	differ $(MAKE) --always-make compile
	differ gofmt -w .

vet:
	go vet -trimpath ./...

lint: vet
	go install honnef.co/go/tools/cmd/staticcheck@latest
	$(shell go env GOPATH)/bin/staticcheck ./...

test: vet
	go test -trimpath ./...

$(JUSTRUN):
	go install github.com/jmhodges/justrun@latest

watch: $(JUSTRUN)
	$(JUSTRUN) -c 'make compile serve' $(WATCH_TARGETS) $(GO_FILES)

serve:
	go run -trimpath ./burke_services_server

$(BUMP_VERSION):
	go install github.com/kevinburke/bump_version@latest

release: $(BUMP_VERSION)
	$(BUMP_VERSION) minor burke_services_renderer/main.go
	$(MAKE) --always-make compile

.PHONY: compile check lint vet test watch serve release
