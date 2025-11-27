<div align="center">

# 🌐 Live Preview for Neovim

**Professional real-time preview for Markdown, HTML, AsciiDoc & SVG**

[![Lua](https://img.shields.io/badge/Made%20with-Lua-blueviolet.svg?style=for-the-badge&logo=lua)](https://lua.org)
[![Neovim](https://img.shields.io/badge/Neovim-%E2%89%A50.10.1-green.svg?style=for-the-badge&logo=neovim)](https://neovim.io)
[![License](https://img.shields.io/github/license/cabrera-evil/live-preview.nvim?style=for-the-badge)](LICENSE.md)

_Forked from [brianhuster/live-preview.nvim](https://github.com/brianhuster/live-preview.nvim)_

</div>

---

**live-preview.nvim** is a powerful Neovim plugin that provides instant browser preview for [Markdown](https://en.wikipedia.org/wiki/Markdown), [HTML](https://en.wikipedia.org/wiki/HTML), [AsciiDoc](https://asciidoc.org/) and [SVG](https://en.wikipedia.org/wiki/SVG) files with live updates as you type. Built entirely in Lua with zero external dependencies—no NodeJS, Python, or external runtimes required.

## ✨ Features

- **⚡ Real-time Preview**: Instant browser updates as you type (Markdown, AsciiDoc, SVG)
- **🔄 Auto-refresh HTML**: Live updates on file save for HTML with CSS/JavaScript
- **🧮 Math & Diagrams**: Built-in KaTeX and Mermaid support for equations and flowcharts
- **🎨 Syntax Highlighting**: Beautiful code block rendering in previews
- **📍 Synchronized Scrolling**: Browser automatically scrolls with your Neovim cursor
- **🔍 Picker Integration**: Works seamlessly with:
  - [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
  - [fzf-lua](https://github.com/ibhagwan/fzf-lua)
  - [mini.pick](https://github.com/echasnovski/mini.pick)
  - [snacks.nvim](https://github.com/folke/snacks.nvim)
  - Native `vim.ui.select`

## 🚀 Quick Start

### Essential Commands

Add these convenient keybindings to your configuration:

```lua
-- Recommended keybindings for quick access
vim.keymap.set('n', '<leader>lp', ':LivePreview start<CR>', { desc = 'Start Live Preview' })
vim.keymap.set('n', '<leader>ls', ':LivePreview close<CR>', { desc = 'Stop Live Preview' })
vim.keymap.set('n', '<leader>lf', ':LivePreview pick<CR>', { desc = 'Pick file to preview' })
```

### Core Commands

- `:LivePreview start` — Begin live preview for current file
- `:LivePreview close` — Stop the preview server
- `:LivePreview pick` — Select file to preview with picker

## 📽️ Demo

https://github.com/user-attachments/assets/865112c1-8514-4920-a531-b2204194f749

## 📋 Release Notes

See [RELEASE.md](RELEASE.md) for detailed changelog.

> **⚠️ Note:** Clear your browser cache after updates to ensure proper functionality.

## 📦 Installation

### Prerequisites

| Requirement        | Version  | Platform     |
| ------------------ | -------- | ------------ |
| **Neovim**         | ≥ 0.10.1 | All          |
| **Modern Browser** | Any      | All          |
| **PowerShell**     | Any      | Windows only |

### Package Managers

<details>
<summary><b>lazy.nvim</b> (Recommended)</summary>

```lua
{
    'cabrera-evil/live-preview.nvim',
    dependencies = {
        -- Choose your preferred picker (optional)
        'nvim-telescope/telescope.nvim',     -- OR
        'ibhagwan/fzf-lua',                  -- OR
        'echasnovski/mini.pick',             -- OR
        'folke/snacks.nvim',                 -- OR
    },
    keys = {
        { '<leader>lp', ':LivePreview start<CR>', desc = 'Start Live Preview' },
        { '<leader>ls', ':LivePreview close<CR>', desc = 'Stop Live Preview' },
        { '<leader>lf', ':LivePreview pick<CR>', desc = 'Pick file to preview' },
    },
    config = function()
        -- Optional: Additional configuration
        require('livepreview.config').set({
            port = 5500,
            browser = 'default',
            dynamic_root = false,
            sync_scroll = true,
        })
    end,
}
```

</details>

<details>
<summary><b>mini.deps</b></summary>

```lua
MiniDeps.add({
    source = 'cabrera-evil/live-preview.nvim',
    depends = {
        -- Optional picker dependencies
        'nvim-telescope/telescope.nvim',
        'ibhagwan/fzf-lua',
        'echasnovski/mini.pick',
        'folke/snacks.nvim',
    },
})
```

</details>

<details>
<summary><b>vim-plug</b></summary>

```vim
Plug 'cabrera-evil/live-preview.nvim'

" Optional picker support
Plug 'nvim-telescope/telescope.nvim'
Plug 'ibhagwan/fzf-lua'
Plug 'echasnovski/mini.pick'
Plug 'folke/snacks.nvim'
```

</details>

<details>
<summary><b>Manual Installation</b></summary>

```bash
# Clone the repository
git clone --depth 1 https://github.com/cabrera-evil/live-preview.nvim \
    ~/.local/share/nvim/site/pack/live-preview/start/live-preview.nvim

# Generate help tags
nvim -c 'helptags ~/.local/share/nvim/site/pack/live-preview/start/live-preview.nvim/doc' -c 'q'
```

</details>

> **Note:** Run `:helptags ALL` if your plugin manager doesn't automatically generate help tags.

### 📝 HTML Auto-save Setup

HTML files require saving to trigger preview updates. Enable auto-save for seamless editing:

<details>
<summary><b>Lua Configuration</b></summary>

```lua
-- Enable auto-save for HTML files
vim.opt.autowriteall = true
vim.api.nvim_create_autocmd({ 'InsertLeavePre', 'TextChanged', 'TextChangedP' }, {
    pattern = '*.html',
    callback = function()
        vim.cmd('silent! write')
    end,
    desc = 'Auto-save HTML files for live preview'
})
```

</details>

<details>
<summary><b>Vimscript Configuration</b></summary>

```vim
" Enable auto-save for HTML files
set autowriteall
autocmd InsertLeavePre,TextChanged,TextChangedP *.html silent! write
```

</details>

## ⚙️ Configuration

Configure the plugin using the setup function:

```lua
require('livepreview.config').set({
    port = 5500,                    -- Preview server port
    browser = 'default',            -- Browser command ('firefox', 'chrome', etc.)
    dynamic_root = false,           -- Use parent dir of current file as root
    sync_scroll = true,             -- Sync browser scroll with Neovim
    picker = 'telescope',           -- Preferred picker: 'telescope', 'fzf-lua', 'mini.pick', 'snacks'
    address = '127.0.0.1',         -- Server bind address
})
```

For comprehensive documentation, see [`:h livepreview`](./doc/livepreview.txt).

## 🤝 Contributing

We welcome contributions to improve live-preview.nvim! Whether it's bug reports, feature requests, or code contributions, your help is appreciated.

### How to Contribute

1. **Fork** the repository
2. **Create** a feature branch
3. **Make** your changes
4. **Test** thoroughly
5. **Submit** a pull request

## 🎯 Roadmap

See our [project milestones](https://github.com/cabrera-evil/live-preview.nvim/milestones) for planned features and improvements.

## 🙏 Acknowledgements

This project builds upon excellent open-source work:

### Original Project

- **[brianhuster/live-preview.nvim](https://github.com/brianhuster/live-preview.nvim)** - Original implementation and core architecture

### Inspiration & Dependencies

- **[Live Server](https://marketplace.visualstudio.com/items?itemName=ritwickdey.LiveServer)** & **[Live Preview](https://marketplace.visualstudio.com/items?itemName=ms-vscode.live-server)** - VSCode extensions that inspired this project
- **[glacambre/firenvim](https://github.com/glacambre/firenvim)** - SHA1 function implementation reference
- **[sindresorhus/github-markdown-css](https://github.com/sindresorhus/github-markdown-css)** - Beautiful GitHub-style CSS for Markdown
- **[markdown-it/markdown-it](https://github.com/markdown-it/markdown-it)** - Robust Markdown parser
- **[asciidoctor/asciidoctor.js](https://github.com/asciidoctor/asciidoctor.js)** - AsciiDoc processing engine
- **[KaTeX](https://github.com/KaTeX/KaTeX)** - Fast math typesetting library
- **[mermaid-js/mermaid](https://github.com/mermaid-js/mermaid)** - Diagram and flowchart generation
- **[digitalmoksha/markdown-it-inject-linenumbers](https://github.com/digitalmoksha/markdown-it-inject-linenumbers)** - Line number injection for enhanced scrolling

## 💖 Support the Project

If you find this fork useful, consider supporting the ongoing maintenance and development:

<div align="center">

[![PayPal](https://img.shields.io/badge/PayPal-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://www.paypal.com/paypalme/cabreraevil)
[![Buy Me A Coffee](https://img.shields.io/badge/Buy_Me_A_Coffee-FFDD00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://buymeacoffee.com/cabrera.dev)

</div>

---

<div align="center">

**Star ⭐ this repository if you find it useful!**

</div>
