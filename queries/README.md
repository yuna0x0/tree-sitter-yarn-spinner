# Yarn Spinner Tree-sitter Query Files

This directory contains query files for tree-sitter that enable various editor features for Yarn Spinner (.yarn) files in Neovim and other tree-sitter compatible editors.

## Query Files

### `highlights.scm`
Defines syntax highlighting rules for Yarn Spinner language constructs:
- Keywords (`if`, `else`, `set`, `call`, `jump`, etc.)
- Node titles and headers
- Variables (`$variable_name`)
- Functions and expressions
- Comments and hashtags
- Operators and literals
- Command blocks and delimiters

### `indents.scm`
Provides automatic indentation rules for:
- Node bodies (between `---` and `===`)
- Control flow blocks (`if/endif`, `once/endonce`)
- Shortcut options and line groups
- Nested expressions and function calls
- Command blocks

### `folds.scm`
Enables code folding for:
- Complete nodes
- Control flow statements
- Shortcut option groups
- Line group statements
- Multi-line commands and expressions

### `locals.scm`
Supports local symbol analysis including:
- Variable declarations and references
- Function call tracking
- Node title definitions (jump targets)
- Enum and type declarations
- Scope management

### `textobjects.scm`
Defines text objects for navigation and selection:
- Functions (`af`/`if` for function calls)
- Blocks (`ab`/`ib` for control structures)
- Classes (`ac`/`ic` for nodes and enums)
- Parameters (`aa`/`ia` for function arguments)
- Statements and expressions

### `injections.scm`
Language injection rules (currently minimal as Yarn Spinner is typically standalone)

## Usage

### For Neovim Users

1. Copy these files to your Neovim queries directory:
   ```bash
   mkdir -p ~/.config/nvim/queries/yarn_spinner
   cp *.scm ~/.config/nvim/queries/yarn_spinner/
   ```

2. Set up the parser in your `init.lua` (see `NVIM_SETUP.md` for details)

3. Register the filetype:
   ```lua
   vim.treesitter.language.register('yarn_spinner', 'yarn')
   ```

### For Other Editors

These query files follow the standard tree-sitter query format and should work with any editor that supports tree-sitter, though the specific capture names may need adjustment for different highlighting themes.

## Customization

You can extend or modify these queries to:
- Add custom highlight groups
- Define additional text objects
- Create specialized folding rules
- Support custom Yarn Spinner extensions

## Query Language Reference

For more information about tree-sitter queries, see:
- [Tree-sitter Query Documentation](https://tree-sitter.github.io/tree-sitter/using-parsers#query-syntax)
- [Neovim Tree-sitter Documentation](https://neovim.io/doc/user/treesitter.html)

## Contributing

If you find issues with these queries or have suggestions for improvements, please open an issue or pull request in the main repository.