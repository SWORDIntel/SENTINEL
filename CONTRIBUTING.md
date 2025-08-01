# Contributing to SENTINEL

First off, thank you for considering contributing to SENTINEL! It's people like you that make SENTINEL such a great tool.

## Where do I go from here?

If you've noticed a bug or have a question, [search the issue tracker](https://github.com/yourusername/sentinel/issues) to see if someone else has already reported the issue. If not, feel free to [open a new issue](https://github.com/yourusername/sentinel/issues/new).

If you're looking to contribute code, you can check out the [open issues](https://github.com/yourusername/sentinel/issues) to see what we're looking for.

## Fork & create a branch

If this is something you think you can fix, then [fork SENTINEL](https://github.com/yourusername/sentinel/fork) and create a branch with a descriptive name.

A good branch name would be (where issue #38 is the ticket you're working on):

```sh
git checkout -b 38-add-awesome-new-feature
```

## Get the test suite running

Make sure you're running the tests before you start making changes. We've got a suite of tests that you can run with:

```sh
bats tests/
```

## Implement your fix or feature

At this point, you're ready to make your changes! Feel free to ask for help; everyone is a beginner at first :smile_cat:

## Make a Pull Request

At this point, you should switch back to your master branch and make sure it's up to date with SENTINEL's master branch:

```sh
git remote add upstream git@github.com:yourusername/sentinel.git
git checkout master
git pull upstream master
```

Then update your feature branch from your local copy of master, and push it!

```sh
git checkout 38-add-awesome-new-feature
git rebase master
git push --force origin 38-add-awesome-new-feature
```

Finally, go to GitHub and [make a Pull Request](https://github.com/yourusername/sentinel/compare)

## Developer Guide: Adding/Modifying Autocompletions

SENTINEL uses a hybrid autocompletion system. Understanding its components is key to extending it.

### 1. Core Architecture

*   **`sentinel-completion.bash`**: This script (typically installed to `/usr/share/bash-completion/completions/sentinel` or a similar user-local path) handles completions for the main `sentinel` command, its global options, and any subcommands implemented directly as Bash functions within the main `sentinel` script.
*   **`argcomplete`**: Python scripts (especially those in `contrib/` or those acting as implementations for `sentinel` subcommands like `sentinel process`) use the `argcomplete` library. This allows Python scripts to define their own completions based on their `argparse` definitions.

### 2. Modifying Bash Completions (`sentinel-completion.bash`)

The `sentinel-completion.bash` script contains a main completion function, typically `_sentinel_completions`.

*   **Location**: Find this script in the SENTINEL source or its installed location.
*   **Structure**:
    *   The function uses Bash built-ins like `compgen` and helper variables like `COMP_WORDS`, `COMP_CWORD`, `cur`, `prev`.
    *   The `_get_comp_words_by_ref` function (often included or sourced) is useful for robustly parsing words, especially those containing `=`,`:`.
    *   A central `case "$cmd"` block (where `cmd` is the current subcommand) dispatches to logic for that subcommand.
*   **Adding a New Bash Subcommand (e.g., `sentinel newbashcmd`)**:
    1.  Add `"newbashcmd"` to the `subcommands` array in `_sentinel_completions`.
    2.  Add a new case to the main `case "$cmd" in ... esac` block:
        ```bash
        newbashcmd)
            # Logic for completing args for newbashcmd
            # Example: complete from a list of actions
            if [[ "$cword" -eq 2 ]]; then # Assuming sentinel newbashcmd <action>
                local actions="action1 action2"
                COMPREPLY=( $(compgen -W "${actions}" -- "$cur") )
            # Add more logic for further arguments/options
            fi
            ;;
        ```
*   **Adding Options to a Bash Subcommand**:
    *   Locate the `case` block for that subcommand.
    *   If completing an option (e.g., `if [[ "$cur" == -* ]]; then`), add your new option to the `compgen -W "..."` list for that subcommand's option completions.
    *   If the option takes an argument, add logic to complete that argument when `prev` is your new option.
*   **Dynamic Completions**: You can call other shell commands or read files within your completion logic to generate `COMPREPLY` dynamically. For example, `sentinel module unload` reads from `/tmp/sentinel_loaded_modules.txt`.
*   **File/Directory Completions**: Use the `_filedir` function (provided by `bash-completion`).

### 3. Enabling `argcomplete` for Python Scripts

For Python scripts (e.g., new tools in `contrib/` or scripts that implement a `sentinel` subcommand):

1.  **Use `argparse`**: Ensure your Python script uses `argparse` to define its command-line arguments.
    ```python
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("--my-option", choices=["a", "b"])
    # ... other arguments
    ```
2.  **Add `PYTHON_ARGCOMPLETE_OK` Marker**: Place this comment at the top of your Python script:
    ```python
    #!/usr/bin/env python3
    # PYTHON_ARGCOMPLETE_OK
    ```
3.  **Import and Call `argcomplete`**:
    ```python
    import argcomplete
    # ... (define your parser) ...
    argcomplete.autocomplete(parser)
    args = parser.parse_args()
    ```
    Call `argcomplete.autocomplete(parser)` *before* `parser.parse_args()`.
4.  **Ensure Script is Executable**: `chmod +x your_script.py`.
5.  **Registration (for testing/development)**:
    *   Run `eval "$(register-python-argcomplete your_script.py)"` in your shell.
    *   The `install.sh` script should handle advising users to install `argcomplete` system-wide or for the user, which often enables these completions automatically without manual registration for every script if global completion is active.
6.  **Integration with `sentinel` main command (if applicable)**:
    *   If your Python script is called by the main `sentinel` Bash script (e.g., `sentinel process` calls `sentinel_process.py`), the `sentinel-completion.bash` script should "step aside" when it detects that the `process` subcommand is being completed for its options. It typically does this by returning empty `COMPREPLY` for option arguments of `process`, allowing `argcomplete`'s hooks to take over.
    *   Ensure the `sentinel` script calls the Python script directly (e.g., `./path/to/script.py "$@"`) rather than via `python ./path/to/script.py "$@"`, as `argcomplete` often relies on the executable name in `COMP_LINE`.

By following these guidelines, developers can extend SENTINEL's autocompletion capabilities effectively, maintaining a consistent and helpful user experience.
