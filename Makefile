BINDIR_PREFIX?=/usr/local
SIMCTLCLI_NAME = SimctlCLI

.PHONY: lint-fix
lint-fix:
	swiftlint --fix --format
	swiftlint lint --quiet

.PHONY: buildRelease
buildRelease:
	swift build -c release

.PHONY: buildSimctlCLI
buildSimctlCLI:
	@printf "Building SimctlCLI..."
	@swift build -Xswiftc -Osize -Xswiftc -whole-module-optimization -c release --product $(SIMCTLCLI_NAME) 
	@cp "`swift build -c release --product $(SIMCTLCLI_NAME) --show-bin-path`/$(SIMCTLCLI_NAME)" ./bin
	@echo "Done"

.PHONY: cleanBuildSimctlCLI
cleanBuildSimctlCLI: cleanArtifacts buildSimctlCLI

.PHONY: installSimctlCLI
installSimctlCLI: buildSimctlCLI
	@mkdir -p $(BINDIR_PREFIX)/bin
	@install `swift build -c release --product $(SIMCTLCLI_NAME) --show-bin-path`/$(SIMCTLCLI_NAME) $(BINDIR_PREFIX)/bin
	@echo "Installed $(SIMCTLCLI_NAME) to $(BINDIR_PREFIX)/bin/$(SIMCTLCLI_NAME)"

.PHONY: uninstallSimctlCLI
uninstallSimctlCLI:
	@rm -f $(BINDIR_PREFIX)/bin/$(SIMCTLCLI_NAME)
	@echo "Removed $(BINDIR_PREFIX)/bin/$(SIMCTLCLI_NAME)"

.PHONY: precommit
precommit: lint-fix

.PHONY: genLinuxTests
genLinuxTests:
	swift test --generate-linuxmain
	swiftlint --fix --format --path Tests/

.PHONY: test
test: genLinuxTests
	swift test

.PHONY: genXcode
genXcode:
	swift package generate-xcodeproj --enable-code-coverage --skip-extra-files

.PHONY: clean
clean:
	swift package reset
	rm -rdf .swiftpm/xcode
	rm -rdf .build/
	rm Package.resolved
	rm .DS_Store

.PHONY: cleanArtifacts
cleanArtifacts:
	swift package clean

# Test links in README
# requires <https://github.com/tcort/markdown-link-check>
.PHONY: testReadme
testReadme:
	markdown-link-check -p -v ./README.md
