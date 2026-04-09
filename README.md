# taskb0t.nvim

Distributed task management for Neovim with a dual-pane markdown file browser.

## Features

- 🗂️ **Dual-Pane Interface** - Side-by-side file picker and editor
- 📝 **Markdown-Based Tasks** - Store tasks in simple markdown files
- 🔒 **Secure File Operations** - Path validation prevents directory traversal
- ⌨️ **Vim-Style Navigation** - Navigate and edit with familiar keybindings
- 🎨 **Configurable** - Customize vault location, window sizes, and behavior
- 🚀 **Modern Neovim APIs** - Built with latest Neovim best practices

## Installation

### Using Native vim.pack (Neovim 0.12+)

**Recommended for Neovim 0.12+** - No external plugin manager required!

```lua
-- In your init.lua
vim.pack.add({
    source = 'landontr0n/taskb0t.nvim',
    hooks = {
        post_install = function()
            vim.cmd('helptags ALL')
        end,
    },
})

-- Configure after adding
require('taskb0t').setup({
    vault_dir = "~/.config/taskb0t/vault",
    window_width_percent = 0.4,
    window_height_percent = 0.8,
    auto_create_vault = true,
    confirm_delete = true,
})
```

**Manual Installation with vim.pack:**

```bash
# Clone into Neovim's pack directory
git clone https://github.com/landontr0n/taskb0t.nvim \
    ~/.local/share/nvim/site/pack/plugins/start/taskb0t.nvim

# Generate help tags
nvim -c "helptags ~/.local/share/nvim/site/pack/plugins/start/taskb0t.nvim/doc" -c "quit"
```

Then add to your `init.lua`:
```lua
require('taskb0t').setup()
```

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    'landontr0n/taskb0t.nvim',
    config = function()
        require('taskb0t').setup({
            vault_dir = "~/.config/taskb0t/vault",  -- Where to store task files
            window_width_percent = 0.4,              -- Width of each pane (40% of screen)
            window_height_percent = 0.8,             -- Height of windows (80% of screen)
            auto_create_vault = true,                -- Create vault dir if missing
            confirm_delete = true,                   -- Confirm before deleting files
        })
    end,
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
    'landontr0n/taskb0t.nvim',
    config = function()
        require('taskb0t').setup()
    end,
}
```

### Using Vim-Plug

```vim
Plug 'landontr0n/taskb0t.nvim'

" In your init.lua or init.vim (with lua heredoc)
lua << EOF
require('taskb0t').setup()
EOF
```

## Configuration

### Default Configuration

```lua
require('taskb0t').setup({
    vault_dir = "~/.config/taskb0t/vault",  -- Task vault directory
    window_width_percent = 0.4,              -- Width of picker/editor (0.0-1.0)
    window_height_percent = 0.8,             -- Height of windows (0.0-1.0)
    auto_create_vault = true,                -- Auto-create vault if missing
    confirm_delete = true,                   -- Confirm before file deletion
})
```

### Alternative: Using vim.g Variables

```vim
" In init.vim or init.lua
let g:taskb0t_config = {
    \ 'vault_dir': '~/Documents/tasks',
    \ 'window_width_percent': 0.5,
    \ }
```

## Usage

### Commands

| Command | Description |
|---------|-------------|
| `:Taskb0tList` | Open the task browser interface |
| `:Taskb0tFindTasks` | Search for tasks in vault (coming soon) |

### Keybindings

#### Picker Window (Left Pane)

| Key | Action |
|-----|--------|
| `j` | Move down and preview file |
| `k` | Move up and preview file |
| `<CR>` / `l` | Switch focus to editor |
| `c` | Create new task file |
| `d` | Delete selected file |
| `q` | Close task browser |

#### Editor Window (Right Pane)

| Key | Action |
|-----|--------|
| `q` | Switch focus back to picker |
| All standard Vim commands | Edit the file normally |

### Quick Start

1. **Open the task browser:**
   ```vim
   :Taskb0tList
   ```

2. **Create your first task:**
   - Press `c` in the picker window
   - Enter a task name (e.g., "todo-list")
   - A new markdown file is created with a header

3. **Navigate tasks:**
   - Use `j`/`k` to browse files
   - Files automatically preview in the editor pane

4. **Edit tasks:**
   - Press `<CR>` or `l` to focus the editor
   - Edit normally using Vim commands
   - Press `q` to return to the picker

5. **Delete tasks:**
   - Select a file in the picker
   - Press `d` and confirm deletion

## Architecture

taskb0t.nvim is built with a modular architecture:

```
lua/taskb0t/
├── init.lua          # Main entry point and public API
├── config.lua        # Configuration management
├── state.lua         # Window/buffer state management
├── files.lua         # File operations with security
└── ui/
    └── windows.lua   # Window creation and management
```

### Security Features

- **Path Injection Prevention** - Validates filenames to prevent `../` attacks
- **Command Injection Protection** - Escapes file paths before shell commands
- **Vault Confinement** - Ensures all operations stay within configured vault
- **Input Validation** - Rejects empty names, special characters, and path separators

## Development

### Project Structure

```
taskb0t.nvim/
├── lua/taskb0t/       # Lua modules
├── plugin/            # Vim plugin loader
├── doc/               # Help documentation
├── tests/             # Test suite
├── README.md          # This file
├── LICENSE            # MIT License
└── CLAUDE.md          # AI development guide
```

### Testing

Run tests with [busted](https://olivinelabs.com/busted/):

```bash
busted tests/
```

### Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes with conventional commits
4. Push to your branch
5. Open a Pull Request

## Roadmap

### Phase 3: Enhanced Testing & Documentation
- [ ] Comprehensive test suite for all modules
- [ ] Test coverage for edge cases (permissions, invalid paths)
- [ ] CI/CD pipeline with GitHub Actions
- [ ] API documentation generation

### Phase 4: Advanced Features
- [ ] **Tag-Based Organization** - Filter tasks by tags in frontmatter
- [ ] **Recursive Directory Support** - Browse nested task folders
- [ ] **Task Toggle** - Mark tasks complete with keybind (checkbox toggle)
- [ ] **Telescope Integration** - Search tasks with Telescope
- [ ] **Fzf Integration** - Alternative fuzzy finding
- [ ] **Statusline Integration** - Show task count in statusline
- [ ] **Autocommands** - Reload vault on external file changes
- [ ] **Custom Templates** - User-defined file templates
- [ ] **Search/Filter** - Real-time search in picker
- [ ] **Multi-Select** - Bulk operations on files
- [ ] **Git Integration** - Commit tasks from within plugin
- [ ] **Export Formats** - Export tasks to JSON, CSV, etc.
- [ ] **Favorites System** - Quick access to frequently used task contexts

### Phase 5: Polish & UX
- [ ] Custom highlight groups and theming
- [ ] Configurable keybindings
- [ ] Buffer-local commands
- [ ] Window animation/transitions
- [ ] Preview mode enhancements
- [ ] Command completion
- [ ] Help command (`:Taskb0tHelp`)

## Troubleshooting

### Vault directory not found

If you see "Vault directory not found" errors:

1. Check your configuration:
   ```lua
   :lua print(require('taskb0t.config').get().vault_dir)
   ```

2. Ensure `auto_create_vault = true` or create directory manually:
   ```bash
   mkdir -p ~/.config/taskb0t/vault
   ```

### Deprecated API warnings

taskb0t.nvim requires Neovim 0.7+. Update Neovim if you see API deprecation warnings.

### Windows won't open

Check for conflicts with other plugins that manage floating windows. Try:
```vim
:messages
```

## Credits

- Built by [landontr0n](https://github.com/landontr0n)
- Refactored with [Claude Code](https://claude.com/claude-code)

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Related Projects

- [Obsidian.nvim](https://github.com/epwalsh/obsidian.nvim) - Neovim plugin for Obsidian
- [Telekasten.nvim](https://github.com/renerocksai/telekasten.nvim) - Zettelkasten note-taking
- [Neorg](https://github.com/nvim-neorg/neorg) - Organization tool for Neovim

## Changelog

### v0.2.0 (2026-04-08) - Major Refactor
- ✨ Modular architecture with separated concerns
- 🔒 Security fixes for path/command injection
- 🚀 Modern Neovim APIs (vim.bo, vim.wo, vim.keymap.set)
- 📝 Comprehensive documentation
- ⚙️ Configuration system with defaults
- 🎯 Improved error handling and user feedback

### v0.1.0 - Initial Release
- Basic dual-pane task browser
- Create, delete, and edit markdown files
- Vim-style navigation
