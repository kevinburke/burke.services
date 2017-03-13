BUMP_VERSION := $(shell command -v bump_version)
JUSTRUN := $(shell command -v justrun)
RENDERER := $(shell command -v burke_services_renderer)

vet:
	go vet ./...

test: vet
	go test ./...

watch:
ifndef JUSTRUN
	go get github.com/jmhodges/justrun
endif
	justrun -c 'make compile' 2016-donations.md twilio.md ethics.md index.md index.template burke_services_renderer/main.go 

serve:
	go run burke_services_server/main.go

compile:
ifndef RENDERER
	go install ./burke_services_renderer
endif
	burke_services_renderer index.md > public/index.html
	burke_services_renderer ethics.md > public/ethics.html
	burke_services_renderer twilio.md > public/twilio.html
	burke_services_renderer 2016-donations.md > public/2016/donations.html

release:
ifndef BUMP_VERSION
	go get github.com/Shyp/bump_version
endif
	bump_version minor burke_services_renderer/main.go
	@# pick up the version change
	go install ./burke_services_renderer
