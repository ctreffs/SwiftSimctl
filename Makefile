# Version 1.0.0
UNAME_S := $(shell uname -s)
BINDIR_PREFIX?=/usr/local
SIMCTLCLI_NAME = SimctlCLI

# Build SimctlCLI release
buildSimctlCLI:
	@echo "Building..."
	@swift build -Xswiftc -Osize -Xswiftc -whole-module-optimization -c release --product $(SIMCTLCLI_NAME) 
	@echo "Done - $(SIMCTLCLI_NAME) executable at `swift build -c release --product $(SIMCTLCLI_NAME) --show-bin-path`/$(SIMCTLCLI_NAME)"

cleanBuildSimctlCLI: cleanArtifacts buildSimctlCLI

installSimctlCLI: buildSimctlCLI
	@mkdir -p $(BINDIR_PREFIX)/bin
	@install `swift build -c release --product $(SIMCTLCLI_NAME) --show-bin-path`/$(SIMCTLCLI_NAME) $(BINDIR_PREFIX)/bin
	@echo "Installed $(SIMCTLCLI_NAME) to $(BINDIR_PREFIX)/bin/$(SIMCTLCLI_NAME)"

uninstallSimctlCLI:
	@rm -f $(BINDIR_PREFIX)/bin/$(SIMCTLCLI_NAME)
	@echo "Removed $(BINDIR_PREFIX)/bin/$(SIMCTLCLI_NAME)"

# Lint
lint:
	swiftlint autocorrect --format
	swiftlint lint --quiet

lintErrorOnly:
	@swiftlint autocorrect --format --quiet
	@swiftlint lint --quiet | grep error

# Git
precommit: lint genLinuxTests

submodule:
	git submodule init
	git submodule update --recursive

# Tests
genLinuxTests:
	swift test --generate-linuxmain
	swiftlint autocorrect --format --path Tests/

test: genLinuxTests
	swift test

# Package
latest:
	swift package update

resolve:
	swift package resolve

# Xcode
genXcode:
	swift package generate-xcodeproj --enable-code-coverage --skip-extra-files

genXcodeOpen: genXcode
	open *.xcodeproj

# Clean
clean:
	swift package reset
	rm -rdf .swiftpm/xcode
	rm -rdf .build/
	rm Package.resolved
	rm .DS_Store

cleanArtifacts:
	swift package clean

# Test links in README
# requires <https://github.com/tcort/markdown-link-check>
testReadme:
	markdown-link-check -p -v ./README.md