



# Run all unit tests
.PHONY: test
test: 
	pongo up
	pongo run ./spec/unit
	pongo down

# Run all unit tests
.PHONY: generate
generate: 
	./generate_configmap.sh