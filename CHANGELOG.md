# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Modularized the installer into smaller, more manageable scripts.
- Added a centralized configuration file (`config.yaml`) to manage installer and shell options.
- Added a Python script (`installer/config.py`) to parse the configuration file.
- Improved the dependency check to verify versions of dependencies.
- Added unit tests for the `installer/config.py` script.
- Added integration tests for the installer using `bats-core`.
- Added a `CONTRIBUTING.md` file with developer documentation.
- Added a `docs/architecture.md` file with an overview of the system architecture.
- Added this `CHANGELOG.md` file.

### Changed
- The main `install.sh` script is now a simple wrapper that calls the main installer logic in `installer/main.sh`.
- The installer now uses the `config.yaml` file for configuration.
- The `README.md` file has been updated to reflect the changes to the installer and configuration.

### Removed
- Hardcoded configuration variables from the installer scripts.
- The `VENV_AUTO` check from the post-install verification script.
