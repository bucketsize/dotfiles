# Neovim Configuration Specification

## Project Structure

```
nvim/
├── init.lua                 # Main configuration file
├── lua/
│   └── user/
│       ├── keymaps.lua      # Key mappings
│       └── toggleterm.lua   # Toggleterm configuration (created)
└── lazy-lock.json          # Plugin lock file
```

## Core Components

### 1. Initialization (`init.lua`)
- **Primary Configuration**: Main Neovim setup and plugin management
- **Plugin Management**: Uses Lazy.nvim for plugin management
- **Global Settings**: Leader keys, editor options, and basic configuration
- **Plugin Setup**: Configures plugins including toggleterm, treesitter, lsp, etc.

### 2. Key Mappings (`lua/user/keymaps.lua`)
- **Mode-Specific Mappings**: 
  - Normal mode mappings for various operations
  - Terminal mode mappings for terminal control
- **Plugin Integration**: Keybindings for various plugins and tools
- **Custom Functions**: User-defined keybindings for productivity

### 3. Toggleterm Configuration (`lua/user/toggleterm.lua`)
- **Vertical Terminal**: Right-side terminal window (80 character width)
- **Toggle Functionality**: Properly configured toggle behavior in both normal and terminal modes
- **Keybindings**: 
  - `<C-t>`: Toggle terminal (works in both normal and terminal modes)
  - `<leader>tr`: Toggle terminal (backup binding)
  - `<Esc><Esc>`: Exit terminal mode

## Plugin Configuration

### Essential Plugins
- **toggleterm.nvim**: Terminal management
- **lazy.nvim**: Plugin manager
- **treesitter**: Syntax highlighting and parsing
- **lsp**: Language server protocol support

## Key Features

### Terminal Management
- Vertical terminal on the right side (80 characters wide)
- Toggle functionality in both normal and terminal modes
- Proper exit sequences for terminal mode

### Navigation & Productivity
- Leader key mappings for common operations
- Custom keybindings for enhanced workflow
- Mode-appropriate keybindings

## Constraints & Design Principles

### File Organization
- Plugin initialization code resides exclusively in `init.lua`
- Key mappings reside exclusively in `lua/user/keymaps.lua`
- No cross-file contamination of responsibilities

### Configuration Philosophy
- Minimal, focused configuration
- Consistent keybinding patterns
- Proper mode handling for all keymaps
- Backward compatibility with existing workflows

## Usage Patterns

### Terminal Operations
1. **Normal Mode**: Press `<C-t>` to toggle terminal
2. **Terminal Mode**: Press `<C-t>` again to hide terminal
3. **Exit Terminal**: Press `<Esc><Esc>` to return to normal mode

### General Navigation
- Leader key (`space`) for extended functionality
- Consistent keybinding patterns throughout the configuration