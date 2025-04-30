#!/usr/bin/env python3
# sentinel_chat_patch.py - Patch instructions for sentinel_chat.py to use context integration

"""
This file contains the changes needed to integrate the context module with sentinel_chat.py.
It's not meant to be run directly, but rather to illustrate the modifications needed.

Here are the key changes to make to sentinel_chat.py:

1. Import the context integration module
2. Enhance the system prompt with context
3. Update context after command execution
4. Use context-aware command suggestions

The changes should be applied at these locations:
"""

# ---- CHANGE 1: Add import for context module ----
# Add after other imports:
"""
# Try to import context integration
try:
    import sentinel_chat_context
    CONTEXT_INTEGRATION = sentinel_chat_context.is_available()
except ImportError:
    CONTEXT_INTEGRATION = False
"""

# ---- CHANGE 2: Enhance system prompt with context ----
# In the load_llm function, modify where config["system_prompt"] is used:
"""
# Original code:
system_prompt = config["system_prompt"]

# Replacement code:
system_prompt = config["system_prompt"]
if CONTEXT_INTEGRATION:
    system_prompt = sentinel_chat_context.get_enhanced_system_prompt(system_prompt)
"""

# ---- CHANGE 3: Update context after command execution ----
# In the execute_command function, add after command execution:
"""
# After executing the command and getting the result, add:
if CONTEXT_INTEGRATION:
    sentinel_chat_context.update_context_after_command(command, result.returncode)
"""

# ---- CHANGE 4: Add a new /context command to chat loop ----
# In the chat_loop function, add a new command handler:
"""
# Add to the command handlers section:
elif cmd.startswith("/context"):
    if CONTEXT_INTEGRATION:
        context_info = sentinel_chat_context.get_context_for_llm()
        console.print(Panel(context_info, title="Current Shell Context"))
    else:
        console.print("[yellow]Context integration not available[/yellow]")
"""

# ---- CHANGE 5: Add a new /suggest command to chat loop ----
# In the chat_loop function, add another command handler:
"""
# Add to the command handlers section:
elif cmd.startswith("/suggest"):
    if CONTEXT_INTEGRATION:
        parts = cmd.split(maxsplit=1)
        prefix = parts[1] if len(parts) > 1 else ""
        if prefix:
            suggestions = sentinel_chat_context.get_command_suggestions(prefix)
            if suggestions:
                console.print(Panel(
                    "\n".join([f"[bold]{s['command']}[/bold] ({s['confidence']:.2f}): {s['description']}" 
                              for s in suggestions]),
                    title=f"Command Suggestions for '{prefix}'"
                ))
            else:
                console.print(f"[yellow]No suggestions found for '{prefix}'[/yellow]")
        else:
            console.print("[yellow]Usage: /suggest <command_prefix>[/yellow]")
    else:
        console.print("[yellow]Context integration not available[/yellow]")
"""

# ---- CHANGE 6: Update help command ----
# Update the help text to include the new commands:
"""
# Update the help text to include:
console.print("  [bold]/context[/bold] - Show current shell context")
console.print("  [bold]/suggest <prefix>[/bold] - Get command suggestions")
"""

"""
INSTALLATION STEPS:

1. Copy sentinel_context.py to contrib/
2. Copy sentinel_chat_context.py to contrib/
3. Copy sentinel_context.sh to bash_modules.d/sentchat/
4. Apply the patches in this file to sentinel_chat.py
5. Enable the module with: echo "sentchat/sentinel_context" >> ~/.bash_modules

These changes will create a seamless integration between the command learning
system and the chat system, providing context-aware responses and suggestions.
""" 