# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- Top-level `Makefile` (`make`, `make universal`, `make install PREFIX=...`, `make uninstall`,
  `make clean`).
- Homebrew formula in `Formula/uvc-util.rb`, making the repository usable as a tap:
  `brew tap jtfrey/uvc-util https://github.com/jtfrey/uvc-util && brew install uvc-util`.
- Release workflow that publishes a signed universal binary for each `vN.N` tag and repoints the
  formula at it, plus a CI workflow that builds and smoke-tests every push and pull request.

### Changed
- `uvc-util --version` now reports the version the build was given -- the release tag in CI, or
  `git describe` in a working copy -- rather than a hand-maintained struct, and states the real
  deployment target of a universal build instead of the SDK-implied one.

## [1.1.0]
Baseline release to open source.

## [1.2.0] - 2021-04-25
### Fixed
- Several issues reported with some camera's ProcessingUnit being available but unusable.  Diagnosed as the use of a static unit id of 2 for the ProcessingUnit, whereas the UVC standard has a variable unit id present in the PU header.  Added unit id map to UVCController with default unit ids for each handled unit type, overridden by unit id from the unit's header record.  User who reported issues tested the change, confirmed success.
