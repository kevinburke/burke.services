vet:
	go vet ./...

test: vet
	go test ./...

watch:
	justrun -c 'make compile' ethics.md index.md index.template burke_services_renderer/main.go 

serve:
	go run burke_services_server/main.go

compile:
	go run burke_services_renderer/main.go index.md > public/index.html
	go run burke_services_renderer/main.go ethics.md > public/ethics.html

release:
	bump_version minor burke_services_renderer/main.go
