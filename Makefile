BUMP_VERSION := $(shell command -v bump_version)
JUSTRUN := $(shell command -v justrun)
RECOMPILE := $(shell command -v recompile)
RENDERER := $(shell command -v burke_services_renderer)

WATCH_TARGETS := $(shell find . -name '*.md')
GO_FILES := $(shell find . -name '*.go')

vet:
	go vet ./...

test: vet
	go test ./...

$(JUSTRUN):
	go get -u github.com/jmhodges/justrun

watch: $(JUSTRUN)
	justrun -c 'make compile serve' $(WATCH_TARGETS) $(GO_FILES)

serve:
	go run burke_services_server/main.go

public/2016/donations.html: 2016-donations.md
	burke_services_renderer 2016-donations.md > public/2016/donations.html

public/2017:
	mkdir -p public/2017

public/2017/donations.html: 2017-donations.md | public/2017
	burke_services_renderer 2017-donations.md > public/2017/donations.html

public/capital-one-open-redirect.html: open-redirect.md
	burke_services_renderer open-redirect.md > public/capital-one-open-redirect.html

public/%.html: %.md
ifndef RENDERER
	go install ./burke_services_renderer
endif
ifndef RECOMPILE
	go get -u github.com/kevinburke/recompile
endif
	echo "$?"
	@recompile --command='burke_services_renderer' --out-dir=public --extension=html $?

compile: public/*.html public/2016/donations.html public/2017/donations.html

release:
ifndef BUMP_VERSION
	go get github.com/Shyp/bump_version
endif
	bump_version minor burke_services_renderer/main.go
	@# pick up the version change
	go install ./burke_services_renderer
