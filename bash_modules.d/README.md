# SENTINEL Bash Modules

This directory contains the Bash modules for the SENTINEL shell environment.

## Module Loading System

The SENTINEL module system is designed to be flexible and performant. It uses a dependency-aware loading system to ensure that modules are loaded in the correct order. It also uses lazy loading and caching to minimize the impact on shell startup time.

### How it works

The module system is controlled by the `bash_modules` file in the root of the repository. This file is a simple list of the modules that should be loaded. The `module_manager.module` script is responsible for reading this file, resolving dependencies, and loading the modules in the correct order.

### Loading Guards

Each module is loaded only once per shell session. This is achieved using a loading guard, which is a simple environment variable that is set when the module is loaded.

### Performance Optimizations

The module system uses a number of performance optimizations to minimize the impact on shell startup time:

-   **Lazy Loading**: Modules are loaded only when they are needed.
-   **Caching**: The module lookup paths are cached to speed up initialization.
-   **Parallel Loading**: Modules are loaded in parallel where possible.

## Module Categories

### Security
-   `hashcat.module`: Integration with Hashcat.
-   `distcc.module`: Integration with distcc.
-   `hmac.module`: HMAC verification for module integrity.

### Development
-   `auto_install.module`: Functions for automatically installing packages.
-   `config_cache.module`: A system for caching configuration files.
-   `python_integration.module`: Integration with Python.

### Intelligence
-   `sentinel_context.module`: Core context-aware intelligence features.
-   `sentinel_ml_enhanced.module`: Enhanced machine learning features.
-   `sentinel_chat.module`: Terminal-based chat system.
-   `sentinel_gitstar.module`: GitHub repository analysis.
-   `sentinel_markov.module`: Markov chain command generation.
-   `sentinel_osint.module`: OSINT data collection.
-   `sentinel_smallllm.module`: Small LLM integration.

## Creating New Modules

To create a new module, you can use the `module_template.module` file as a starting point. This file contains a basic module structure with a description, version, and dependencies.

When creating a new module, please follow these guidelines:
-   Use a descriptive name for your module.
-   Add a `README.md` file to your module directory to explain what it does and how to use it.
-   Declare all your module's dependencies in the `SENTINEL_MODULE_DEPENDENCIES` variable.
-   Use the `sentinel_log` function for logging.
-   Use the `export -f` command to export any functions that you want to be available to other modules.
