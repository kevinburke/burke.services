vet:
	go vet ./...

test: vet
	go test ./...

watch:
	justrun -c 'make compile' 2016-donations.md ethics.md index.md index.template burke_services_renderer/main.go 

serve:
	go run burke_services_server/main.go

compile:
	burke_services_renderer index.md > public/index.html
	burke_services_renderer ethics.md > public/ethics.html
	burke_services_renderer 2016-donations.md > public/2016/donations.html

release:
	bump_version minor burke_services_renderer/main.go
