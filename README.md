# tree-sitter-yarn-spinner

A [tree-sitter](https://tree-sitter.github.io/tree-sitter/) grammar for [Yarn Spinner](https://yarnspinner.dev/), a dialogue system for interactive fiction and games.

⚠️ This tree-sitter parser is in early development and almost certainly not ready for production use.

## Features

- **Syntax highlighting** for Yarn Spinner dialogue files (.yarn)
- **Automatic indentation** for nested structures
- **Code folding** for nodes and control blocks
- **Symbol analysis** for variables and functions
- **Text objects** for efficient navigation and editing

## Editor Support

### Neovim (nvim-treesitter)

Full support via nvim-treesitter with syntax highlighting, indentation, folding, and text objects.

**Quick Setup:**
1. Install the parser and copy query files:
   ```bash
   # Run from the tree-sitter-yarn-spinner directory
   ./install-nvim.sh
   ```

2. Add to your `init.lua`:
   ```lua
   local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
   parser_config.yarn_spinner = {
     install_info = {
       url = "/path/to/tree-sitter-yarn-spinner",
       files = {"src/parser.c", "src/scanner.c"},
     },
     filetype = "yarn",
   }
   vim.treesitter.language.register('yarn_spinner', 'yarn')
   ```

3. Install the parser: `:TSInstall yarn_spinner`

For detailed setup instructions, see [NVIM_SETUP.md](NVIM_SETUP.md).

### Other Editors

The query files in the `queries/` directory follow standard tree-sitter conventions and should work with any tree-sitter compatible editor with minimal modifications.

## Installation

### Building from Source

```bash
git clone https://github.com/yuna0x0/tree-sitter-yarn-spinner.git
cd tree-sitter-yarn-spinner
npm install
npm run build
```

### Testing

```bash
# Test parsing on example files
npm test

# Parse a specific file
npx tree-sitter parse examples/yarn/BasicYarnExample.yarn
```

## Yarn Spinner Language Support

This grammar supports the core Yarn Spinner language features:

- **Nodes** with headers and body content
- **Commands** (`<<if>>`, `<<set>>`, `<<call>>`, `<<jump>>`, etc.)
- **Variables** (`$variable_name`)
- **Expressions** with operators and function calls
- **Shortcut options** (`->`)
- **Line groups** (`=>`)
- **Comments** (`// comment`)
- **Hashtags** (`#tag`)
- **Conditional statements** and control flow
- **String interpolation** with `{expressions}`

## Contributing

Contributions are welcome! Please feel free to:

- Report bugs or parsing issues
- Suggest improvements to the grammar
- Add support for additional editors
- Improve query files for better highlighting

## License

This project is licensed under the [MIT License](LICENSE).
