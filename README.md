# tree-sitter-yarn-spinner

A [tree-sitter](https://tree-sitter.github.io/tree-sitter/) grammar for [Yarn Spinner](https://www.yarnspinner.dev), a dialogue system for interactive fiction and games.

⚠️ This tree-sitter parser is in early development and might have incomplete or incorrect grammar rules.

The grammar rules are based on the Yarn Spinner ANTLR 4 grammar files `YarnSpinnerLexer.g4` and `YarnSpinnerParser.g4` from the [Yarn Spinner repository](https://github.com/YarnSpinnerTool/YarnSpinner/tree/main/YarnSpinner.Compiler/Grammars).

The grammar file in this repository is `grammar.js` with the external scanner in `src/scanner.c` and a generated `src/grammar.json` file.

## Bindings
This parser can be used with various programming languages that support tree-sitter. Here are some examples:

Rust:
```bash
cargo add tree-sitter-yarn-spinner
```

JavaScript / TypeScript / Node.js:
```bash
pnpm install tree-sitter-yarn-spinner
```

Python:
```bash
uv add tree-sitter-yarn-spinner
```

## Build
To build the parser, you need to have a JavaScript runtime like [Node.js](https://nodejs.org/) and a C compiler (like `gcc`, `clang`, or MSVC on Windows) installed.

Then, run the following command in the root directory of this repository, to install dependencies and generate the parser:
```bash
pnpm install
tree-sitter generate
```

To test the parser, you can run:
```bash
tree-sitter parse YOUR_FILE.yarn
```

Details can be found in the [tree-sitter documentation](https://tree-sitter.github.io/tree-sitter/creating-parsers/1-getting-started.html).

## License

This project is licensed under the [MIT License](LICENSE).
