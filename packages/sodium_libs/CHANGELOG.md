# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.2] - 2022-04-27
### Changed
- updated referenced libsodium.js to version 0.7.10
  - integration tests now run this version
  - the `update_web` command will now download this version

## [1.2.1] - 2022-04-14
### Fixed
- Windows: Invoke dart via CMD in CMake to prevent problems on Windows 11 (#9)

## [1.2.0] - 2021-01-25
### Added
- Added support for the Sumo-Version of sodium.js (#4)
### Changed
- Changed dependency requirements
  - Set minimum required dart SDK version to 2.15
  - Set minimum required flutter SDK version to 2.8
  - Updated minimum required `sodium` version to 1.2.0+2
  - Updated dependencies
- Use newer platform setups of flutter 2.8
- Replaced `lint` with `dart_test_tools` which makes the default rules of `lint` even more strict
- Refactored test setup tooling
- Windows builds now required `dart` to be in the PATH (should be like that per default)
### Deprecated
- `SodiumInit.ensurePlatformRegistered` is no longer needed, as platform registration now works automatically
### Removed
- Various internal APIs have been removed
### Fixed
- Fix formatting and linter issues with the newer dart SDK & dependencies
- Removed unused native code
- Added README hint on how to use the library on iOs Simulators

## [1.1.1] - 2021-08-26
### Changed
- `SodiumInit.init` now automatically handles multiple initializations and no longer requires the `initNative` parameter for consecutive invocations (#3)
- Updated minimum required `sodium` version to `1.1.1`
### Deprecated
- The `initNative` parameter of `SodiumInit.init` has been deprecated as it no longer has any effect (#3)

## [1.1.0] - 2021-08-17
### Added
- `SodiumInit.init` can now be called with `initNative: false` to disable initialization of the native library, in case it has already been initialized
### Changed
- Updated minimum required `sodium` version to `1.1.0`

## [1.0.1] - 2021-07-13
### Fixed
- Make links in README secure (pub.dev score)
- Use longer package description (pub.dev score)

## [1.0.0] - 2021-07-12
### Fixed
- Web/Windows builds did not work when packages was installed via pub.dev

## [0.1.0] - 2021-06-24
### Added
- Initial release

## [Unreleased] - 20XX-XX-XX
### Added
### Changed
### Deprecated
### Removed
### Fixed
### Security
