# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-04-25

### Added
- Initial release of Logfita, a macOS menu bar application to track work hours logged in Apple Calendar.
- Configurable daily, weekly, and yearly hour goals (defaulting to 8, 40, and 1642 respectively).
- Calendar selection support.
- Automatic filtering of all-day events.
- Advanced interval merging logic to correctly calculate hours and avoid double-counting overlapping or duplicate calendar events.
- Build script (`build.sh`) to natively compile the application bundle.
