   prefix ?= /usr/local
   bindir = $(prefix)/bin

   build:
      swift build -c release --disable-sandbox
  
   install: build
	install ".build/release/appstoreconnect-cli" "$(bindir)"

   uninstall:
        rm -rf "$(bindir)/appstoreconnect-cli"
   
   clean:
        rm -rf .build

   .PHONY: build install uninstall clean
