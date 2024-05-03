.PHONY: assets

TARGET = wasm32-none-wasm
SWIFT_SOURCES = $(wildcard src/*.swift) $(wildcard src/Core/*.swift) $(wildcard src/Core/Platform/*.swift)
C_SOURCES = $(wildcard runtime/*.c)
ASSET_SOURCES = $(wildcard assets/bundle/*)

SWIFT_FLAGS = -enable-builtin-module -enable-experimental-feature Embedded -enable-experimental-feature SymbolLinkageMarkers -wmo -parse-as-library -Osize -Xcc -fdeclspec
C_FLAGS = -O2 -nostdlib -Wno-incompatible-library-redeclaration

all: wasm

wasm:
	@clang -target $(TARGET) $(C_FLAGS) $(C_SOURCES) -c -o build/runtime.o
	@swiftc -target $(TARGET) $(SWIFT_FLAGS) -Xcc -fmodule-map-file=runtime/module.modulemap -Xcc -fmodule-map-file=assets/module.modulemap $(SWIFT_SOURCES) -c -o build/game-wasm.o
	@wasm-ld build/game-wasm.o build/runtime.o -o web/src/game.wasm --no-entry --allow-undefined

clean:
	@rm -r build/* || true
	@rm assets/include/assets.h || true
	@rm assets/assets.c || true

serve:
	@cd web; esbuild --servedir=src --serve

assets:
	@> assets/include/assets.h
	@> assets/assets.c
	@echo "#include \"include/assets.h\"" >> assets/assets.c
	@for asset in $(ASSET_SOURCES); do \
		xxd -C -i $$asset >> assets/assets.c; \
	done
