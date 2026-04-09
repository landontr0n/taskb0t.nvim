# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

taskb0t.nvim is a Neovim plugin for distributed task management using markdown files. It provides a dual-pane interface (picker + editor) for browsing and editing task files stored in a vault directory.

## Development Commands

**Testing:**
```bash
# Run tests with busted (Lua testing framework)
busted tests/taskb0t_spec.lua
```

## Architecture

### Dual Window System

The plugin creates two floating windows side-by-side:

1. **Picker Window** (left, 40% width): File browser for vault contents
   - Buffer: `buf_picker` (scratch buffer, filetype='taskb0t')
   - Window: `win_picker`
   - Lists files from vault directory
   - Navigation keys: j/k for up/down, l/<cr> to open file

2. **Editor Window** (right, 40% width): File editor for selected task
   - Buffer: `buf_editor` (initially scratch, replaced with file buffer)
   - Window: `win_editor`
   - Displays selected file content
   - q key toggles back to picker

### Window and Buffer Lifecycle

**Critical Pattern:** The editor buffer is replaced on file selection, NOT reused:
- `open_file()` calls `edit <filepath>` in editor window context
- New buffer replaces `buf_editor` scratch buffer
- Old buffer is deleted with `bd!#` if it's not the picker/editor
- `buf_editor` variable is updated to new buffer handle
- Mappings are re-applied to new buffer via `set_editor_mappings()`

This pattern ensures each file gets its own buffer while managing cleanup.

### Vault Directory Resolution

Files are stored in a vault directory with triple-fallback resolution:
```lua
dir or settings.vault_dir or '~/.config/taskb0t/vault/'
```

Configuration via: `vim.g.taskb0t_settings = { vault_dir = "/custom/path/" }`

### Key Functions

**Entry Point:**
- `M.taskb0t()` - Main command that orchestrates window creation, mappings, and initial file load

**Window Management:**
- `open_files_window()` / `open_editor_window()` - Create floating windows with calculated positions
- `set_win()` - Toggle focus between picker and editor windows
- `close_window()` - Cleanup both windows and buffers

**File Operations:**
- `create_file()` - Prompts for name, creates markdown file with h1 header
- `delete_file()` - Confirmation prompt, deletes selected file
- `open_file()` - Loads file into editor window (replaces buffer)
- `update_view()` - Refreshes picker with current vault contents

**Navigation:**
- `editor_nav(direction)` - j/k navigation that moves cursor in picker AND auto-opens file in editor
- Enables browsing through files without manual selection

### Keymappings

**Picker Window:**
- `<cr>`, `l` - Open file in editor / switch to editor
- `q` - Close both windows
- `j`, `k` - Navigate down/up (auto-opens files)
- `c` - Create new file
- `d` - Delete selected file

**Editor Window:**
- `q` - Switch back to picker window

Mappings are buffer-local and reapplied when editor buffer changes.

## Known TODOs in Code

- Remove default editor creation from `update_view()` (line 10-11)
- Improve `close_window()` implementation (line 156)
- Verify triple-or statement in `get_files()` works correctly (line 100)
- Window management in `set_win()` could be cleaner (line 196)

## Plugin Loading

Standard Vim plugin structure:
- `plugin/taskb0t.vim` - Defines commands (`:Taskb0tList`, `:Taskb0tFindTasks`)
- `lua/taskb0t/init.lua` - Main Lua module with all functionality
- Commands call into Lua module: `lua require("taskb0t").taskb0t()`
