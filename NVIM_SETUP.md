# Neovim Tree-sitter Setup for Yarn Spinner

This guide helps you set up tree-sitter support for Yarn Spinner (.yarn files) in Neovim using nvim-treesitter.

## Prerequisites

- Neovim 0.10 or later
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) plugin installed
- A C compiler (gcc, clang, or MSVC on Windows)
- `git` and either `curl` or `tar` in your PATH

## Installation Methods

### Method 1: Manual Parser Installation (Recommended)

1. **Clone this repository** to a location accessible by nvim-treesitter:
   ```bash
   git clone https://github.com/yuna0x0/tree-sitter-yarn-spinner.git
   ```

2. **Add the parser configuration** to your Neovim config (`init.lua`):
   ```lua
   local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
   
   parser_config.yarn_spinner = {
     install_info = {
       url = "/path/to/tree-sitter-yarn-spinner", -- Update this path
       files = {"src/parser.c", "src/scanner.c"},
       branch = "main",
       generate_requires_npm = false,
       requires_generate_from_grammar = false,
     },
     filetype = "yarn",
   }
   ```

3. **Register the filetype** to use the yarn_spinner parser:
   ```lua
   vim.treesitter.language.register('yarn_spinner', 'yarn')
   ```

4. **Install the parser**:
   ```vim
   :TSInstall yarn_spinner
   ```

5. **Copy query files** to your Neovim runtime directory:
   ```bash
   # Create the directory if it doesn't exist
   mkdir -p ~/.config/nvim/queries/yarn_spinner
   
   # Copy query files
   cp tree-sitter-yarn-spinner/queries/*.scm ~/.config/nvim/queries/yarn_spinner/
   ```

6. **Set up filetype detection** by adding to your `init.lua`:
   ```lua
   vim.filetype.add({
     extension = {
       yarn = 'yarn',
     },
   })
   ```

### Method 2: Using a Plugin Manager

If you're using a plugin manager like `lazy.nvim` or `packer.nvim`, you can set this up as a dependency:

#### With lazy.nvim:
```lua
{
  "nvim-treesitter/nvim-treesitter",
  dependencies = {
    {
      "yuna0x0/tree-sitter-yarn-spinner",
      config = function()
        -- Parser configuration
        local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
        parser_config.yarn_spinner = {
          install_info = {
            url = "https://github.com/yuna0x0/tree-sitter-yarn-spinner",
            files = {"src/parser.c", "src/scanner.c"},
            branch = "main",
          },
          filetype = "yarn",
        }
        
        -- Filetype registration
        vim.treesitter.language.register('yarn_spinner', 'yarn')
        vim.filetype.add({
          extension = {
            yarn = 'yarn',
          },
        })
      end,
    }
  },
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = { "yarn_spinner" }, -- Add to your existing list
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = {
        enable = true,
      },
      fold = {
        enable = true,
      },
    })
  end,
}
```

## Configuration

### Basic nvim-treesitter Setup

Add Yarn Spinner to your nvim-treesitter configuration:

```lua
require("nvim-treesitter.configs").setup({
  ensure_installed = {
    -- your other languages
    "yarn_spinner",
  },
  
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  
  indent = {
    enable = true,
  },
  
  fold = {
    enable = true,
  },
  
  -- Optional: Enable incremental selection
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "gnn",
      node_incremental = "grn",
      scope_incremental = "grc",
      node_decremental = "grm",
    },
  },
  
  -- Optional: Enable text objects
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
        ["ab"] = "@block.outer",
        ["ib"] = "@block.inner",
        ["aa"] = "@parameter.outer",
        ["ia"] = "@parameter.inner",
      },
    },
    move = {
      enable = true,
      set_jumps = true,
      goto_next_start = {
        ["]m"] = "@function.outer",
        ["]]"] = "@class.outer",
      },
      goto_next_end = {
        ["]M"] = "@function.outer",
        ["]["] = "@class.outer",
      },
      goto_previous_start = {
        ["[m"] = "@function.outer",
        ["[["] = "@class.outer",
      },
      goto_previous_end = {
        ["[M"] = "@function.outer",
        ["[]"] = "@class.outer",
      },
    },
  },
})
```

### Enable Folding

To enable tree-sitter based folding for Yarn Spinner files:

```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = "yarn",
  callback = function()
    vim.wo.foldmethod = "expr"
    vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
  end,
})
```

### Custom Highlight Groups

You can customize the highlighting by overriding the highlight groups in your config:

```lua
-- Example custom highlighting
vim.api.nvim_set_hl(0, "@markup.heading.yarn_spinner", { link = "Title" })
vim.api.nvim_set_hl(0, "@keyword.conditional.yarn_spinner", { link = "Conditional" })
vim.api.nvim_set_hl(0, "@keyword.function.yarn_spinner", { link = "Function" })
vim.api.nvim_set_hl(0, "@variable.yarn_spinner", { link = "Identifier" })
vim.api.nvim_set_hl(0, "@tag.yarn_spinner", { link = "Tag" })
```

## Features

Once set up, you'll have the following features for `.yarn` files:

### Syntax Highlighting
- **Keywords**: `if`, `else`, `elseif`, `endif`, `once`, `endonce`, `set`, `call`, `jump`, `detour`, `return`, etc.
- **Node titles**: Highlighted as headings
- **Variables**: `$variable_name` highlighted distinctly
- **Functions**: Function calls highlighted
- **Comments**: `// comment` support
- **Hashtags**: `#tag` highlighting
- **Operators**: All Yarn Spinner operators
- **Literals**: Numbers, strings, booleans

### Code Folding
- **Node bodies**: Fold between `---` and `===`
- **Control structures**: Fold `if/endif`, `once/endonce` blocks
- **Shortcut options**: Fold option groups
- **Command blocks**: Fold multi-line commands

### Indentation
- **Automatic indentation** for:
  - Node bodies
  - Control structure contents
  - Shortcut option contents
  - Line group contents
  - Expression blocks

### Text Objects
- **Functions**: `af`/`if` for function calls
- **Blocks**: `ab`/`ib` for control structures and nodes
- **Classes**: `ac`/`ic` for nodes and enums
- **Parameters**: `aa`/`ia` for function arguments
- **Conditionals**: For if/else blocks
- **Statements**: Various statement types

### Local Symbol Analysis
- **Variable tracking**: Declarations and references
- **Function references**: Track function calls
- **Node references**: Track jump destinations
- **Scope analysis**: Proper scoping for variables

## Troubleshooting

### Parser Not Found
If you get "parser not found" errors:
1. Make sure the parser is installed: `:TSInstall yarn_spinner`
2. Check that the filetype is correctly detected: `:echo &filetype` (should show "yarn")
3. Verify the parser configuration is correct

### Highlighting Issues
If syntax highlighting doesn't work:
1. Enable tree-sitter highlighting: `:TSBufEnable highlight`
2. Check for errors: `:checkhealth nvim-treesitter`
3. Verify query files are in the correct location

### Installation Issues
If installation fails:
1. Make sure you have a C compiler installed
2. Check that git and curl/tar are available
3. Try updating nvim-treesitter: `:TSUpdate`

### Query File Issues
If you get query errors:
1. Make sure query files are copied to `~/.config/nvim/queries/yarn_spinner/`
2. Restart Neovim after copying query files
3. Check query syntax with `:TSPlaygroundToggle` (if you have playground installed)

## Verifying Installation

After setup, open a `.yarn` file and run:
```vim
:echo &filetype                  " Should show 'yarn'
:TSBufEnable highlight          " Enable highlighting
:TSPlaygroundToggle             " Open syntax tree viewer (if available)
```

## Additional Tools

Consider installing these complementary plugins:
- [nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects) for enhanced text objects
- [playground.nvim](https://github.com/nvim-treesitter/playground) for syntax tree inspection
- [nvim-treesitter-context](https://github.com/nvim-treesitter/nvim-treesitter-context) for showing current context

## Contributing

If you find issues with the tree-sitter grammar or query files, please report them at:
https://github.com/yuna0x0/tree-sitter-yarn-spinner/issues

## License

This tree-sitter grammar is licensed under the MIT License.