watch:
	justrun -c 'go run burke_services_renderer/main.go index.md > public/index.html' index.md index.template burke_services_renderer/main.go 

serve:
	go run burke_services_server/main.go
