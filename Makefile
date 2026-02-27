# --- Variables ---
OCAML_SRC = benches/caml_version/vquad.ml
OCAML_BIN = benches/caml_version/vquad.bin
MAP_FILE = data/map.txt

# --- Default Target ---
all: build-rust build-ocaml

# --- Rust Commands ---
build-rust:
	cargo build --release

test-rust:
	cargo test

run-rust:
	cargo run -- $(MAP_FILE)

# --- OCaml Commands ---
build-ocaml:
	ocamlopt -o $(OCAML_BIN) unix.cmxa $(OCAML_SRC)

run-ocaml: build-ocaml
	./$(OCAML_BIN) $(MAP_FILE)

# --- Utility ---
clean:
	cargo clean
	rm -f benches/caml_version/*.cmx benches/caml_version/*.cmi benches/caml_version/*.o $(OCAML_BIN)

help:
	@echo "Available commands:"
	@echo "  make build-rust   - Compile Rust in release mode"
	@echo "  make build-ocaml  - Compile OCaml to native binary"
	@echo "  make test-rust    - Run Rust integration tests"
	@echo "  make run-rust     - Run Rust version with data/map.txt"
	@echo "  make run-ocaml    - Run OCaml version with data/map.txt"
	@echo "  make clean        - Remove build artifacts"