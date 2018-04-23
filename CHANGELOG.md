# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## Unreleased
### Fixed
- More context and metadata sent to bugsnag in Bugsnag error handler.

## [1.1.0] 2018-04-19
Added error handling for `Absinthe.Middleware.Async`

## [1.0.1] 2018-04-02
First public release

## [1.0.0] 2018-02-18
### Changed
- Exception handling no longer added around the default `MapGet` resolver middleware. This gives a dramatic performance improvement.
### Added
- `Blunder.Absinthe.Dataloader.SafeKV` added to provide excpetion handling in KV Dataloaders
### Fixed
- Absinthe middleware can be specified in the middleware list by a bare module name (atom). We were not handling this case in `add_error_handling`
- Just adding blunder-absinthe to your mixfile caused runtime errors since there was no default error handler list. Making `LogError` the default.

## [0.1.2] 2018-02-13
### Fixed
- Added credo and coveralls and fixed the issues they surfaced

## [0.1.1] 2018-02-13
Fix compiler warnings

## [0.1.0] 2018-02-13
Initial extraction of logic from Blunder

[0.1.2]: https://github.decisiv.net/PlatformServices/blunder-absinthe/tree/0.1.2
[0.1.1]: https://github.decisiv.net/PlatformServices/blunder-absinthe/tree/0.1.1
[0.1.0]: https://github.decisiv.net/PlatformServices/blunder-absinthe/tree/0.1.0
