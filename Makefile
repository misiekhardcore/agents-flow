.PHONY: changelog test-install-smoke test-install-docker

changelog:
	sed -i '/^## \[Unreleased\]/,/^## \[/{/^## \[Unreleased\]/d;/^## \[/!d}' CHANGELOG.md
	npx git-cliff --unreleased --prepend CHANGELOG.md

test-install-smoke:
	tests/install-smoke.sh

test-install-docker:
	docker build -f tests/Dockerfile.install -t agents-flow-install-test .
	docker run --rm agents-flow-install-test
