/**
 * @file Yarn Spinner grammer for tree-sitter
 * @author yuna0x0 <yuna@yuna0x0.com>
 * @license MIT
 */

/// <reference types="tree-sitter-cli/dsl" />
// @ts-check

// This is an initial, non-indentation-aware subset of the Yarn Spinner grammar.
// It is designed to successfully parse the provided test.yarn without using
// external scanners. It supports:
// - File-level hashtags
// - Node headers: title, when (as opaque text), and generic headers
// - Body delimiters: --- and ===
// - Lines of text containing inline expressions {...}
// - Hashtags at end of lines
// - Commands: << ... >>
// - Shortcut options: ->
// - Line group items: =>
// - Basic expression language: numbers, strings, variables ($id), identifiers,
//   simple binary operators, parentheses, and function calls
//
// Notes:
// - No indentation-sensitive constructs (INDENT/DEDENT) are included.
// - "when" header expression is parsed as generic expression text in this phase.
// - Keywords are not reserved; we keep the grammar simple and permissive.

module.exports = grammar({
  name: "yarn_spinner",

  conflicts: ($) => [[$.shortcut_option_statement], [$.line_group_statement]],

  // Keep default whitespace as extras and also allow comments
  extras: ($) => [/\s/, $.comment],

  word: ($) => $.identifier,

  rules: {
    source_file: ($) => seq(repeat($.file_hashtag), repeat1($.node)),

    // // comments starting with //
    comment: (_) => token(seq("//", /[^\r\n]*/)),

    // File-global hashtags at top of file (before any node)
    file_hashtag: ($) =>
      seq($.hashtag_marker, field("text", $.hashtag_text), $.newline),

    // Node
    node: ($) =>
      seq(
        repeat1(choice($.title_header, $.when_header, $.header)),
        field("body_start", alias("---", $.body_start)),
        $.body,
        field("body_end", alias("===", $.body_end)),
      ),

    // Headers
    title_header: ($) =>
      seq(
        alias("title", $.header_title_kw),
        $.header_delimiter,
        field("title", $.identifier),
        $.newline,
      ),

    when_header: ($) =>
      seq(
        alias("when", $.header_when_kw),
        $.header_delimiter,
        field("expr", $.expression),
        $.newline,
      ),

    header: ($) =>
      seq(
        field("key", $.identifier),
        $.header_delimiter,
        optional(field("value", $.rest_of_line)),
        $.newline,
      ),

    header_delimiter: (_) =>
      token(seq(optional(/[ \t]+/), ":", optional(/[ \t]+/))),
    rest_of_line: (_) => token(/[^\r\n]+/),

    // Body: sequence of statements until body_end (must be non-empty)
    body: ($) => repeat1($.statement),

    // Statements
    statement: ($) =>
      choice(
        $.line_statement,
        $.shortcut_option_statement,
        $.line_group_statement,
        $.command_statement,
      ),

    // Line: text/expressions, optional hashtags, newline
    line_statement: ($) =>
      seq(
        $.line_formatted_text,
        optional($.line_condition), // allow simple condition forms using commands
        repeat($.hashtag),
        $.newline,
      ),

    // inline text with embedded expressions
    line_formatted_text: ($) =>
      repeat1(
        choice($.text, seq($.expression_start, $.expression, $.expression_end)),
      ),

    // Simple condition forms on a line like <<if expr>> or <<once ...>>
    line_condition: ($) =>
      choice(
        seq(
          $.command_start,
          alias("if", $.command_if_kw),
          $.expression,
          $.command_end,
        ),
        seq(
          $.command_start,
          alias("once", $.command_once_kw),
          optional(seq(alias("if", $.command_if_kw), $.expression)),
          $.command_end,
        ),
      ),

    // Hashtag
    hashtag: ($) => seq($.hashtag_marker, field("text", $.hashtag_text)),
    hashtag_marker: (_) => token("#"),
    hashtag_text: (_) => token(/[^\s#<>{}\r\n][^#<>{}\r\n]*/),

    // Commands
    command_statement: ($) =>
      seq(
        $.command_start,
        $.command_formatted_text,
        $.command_end,
        repeat($.hashtag),
        $.newline,
      ),

    command_formatted_text: ($) =>
      repeat1(
        choice(
          $.command_text_chunk,
          seq($.expression_start, $.expression, $.expression_end),
        ),
      ),

    // Shortcut options group
    shortcut_option_statement: ($) =>
      seq(repeat($.shortcut_option), $.shortcut_option),

    shortcut_option: ($) =>
      seq(alias("->", $.shortcut_arrow), $.line_statement),

    // Line group
    line_group_statement: ($) =>
      seq(repeat($.line_group_item), $.line_group_item),

    line_group_item: ($) =>
      seq(alias("=>", $.line_group_arrow), $.line_statement),

    // Newline token (named for clarity)
    newline: (_) => token(seq(optional("\r"), "\n")),

    // Text chunks for a line: any chars stopping at control markers
    text: (_) =>
      token(prec(-1, repeat1(/[^#<>{}\r\n\\]+|\\[\\{}#/<>\[\]]|[</]/))),

    // Command delimiters and text
    command_start: (_) => token("<<"),
    command_end: (_) => token(">>"),
    command_text_chunk: (_) => token(repeat1(/[^>{\r\n]+/)),

    // Expression delimiters
    expression_start: (_) => token("{"),
    expression_end: (_) => token("}"),

    // Expression language (very small subset but enough for test file)
    expression: ($) =>
      choice(
        $.paren_expression,
        $.binary_expression,
        $.unary_expression,
        $.call_expression,
        $.member_expression,
        $.number,
        $.string,
        $.variable,
        $.identifier,
      ),

    paren_expression: ($) => seq("(", $.expression, ")"),

    unary_expression: ($) =>
      prec.right(
        7,
        seq(
          field("operator", choice("-", "!", alias("not", $.kw_not))),
          $.expression,
        ),
      ),

    // Binary operators with precedence and associativity
    binary_expression: ($) =>
      choice(
        prec.left(
          6,
          seq(
            $.expression,
            field("operator", choice("*", "/", "%")),
            $.expression,
          ),
        ),
        prec.left(
          5,
          seq($.expression, field("operator", choice("+", "-")), $.expression),
        ),
        prec.left(
          4,
          seq(
            $.expression,
            field(
              "operator",
              choice(
                "<=",
                ">=",
                "<",
                ">",
                alias("lte", $.kw_lte),
                alias("gte", $.kw_gte),
                alias("lt", $.kw_lt),
                alias("gt", $.kw_gt),
              ),
            ),
            $.expression,
          ),
        ),
        prec.left(
          3,
          seq(
            $.expression,
            field(
              "operator",
              choice(
                "==",
                "!=",
                alias("is", $.kw_is),
                alias("eq", $.kw_eq),
                alias("neq", $.kw_neq),
              ),
            ),
            $.expression,
          ),
        ),
        prec.left(
          2,
          seq(
            $.expression,
            field(
              "operator",
              choice(
                alias("and", $.kw_and),
                "&&",
                alias("or", $.kw_or),
                "||",
                alias("xor", $.kw_xor),
                "^",
              ),
            ),
            $.expression,
          ),
        ),
      ),

    call_expression: ($) =>
      seq(
        field("function", $.identifier),
        "(",
        optional(seq($.expression, repeat(seq(",", $.expression)))),
        ")",
      ),

    member_expression: ($) =>
      seq(
        optional(field("type", $.identifier)),
        ".",
        field("member", $.identifier),
      ),

    // Literals and identifiers
    number: (_) => token(choice(/[0-9]+/, /[0-9]+\.[0-9]+/)),

    // double-quoted string with simple escapes
    string: (_) =>
      token(seq('"', repeat(choice(/[^"\\\r\n]/, /\\"/, /\\\\/)), '"')),

    variable: ($) => seq("$", $.identifier),

    identifier: (_) =>
      token(
        new RegExp(
          [
            "[A-Za-z_\\u00A8\\u00AA\\u00AD\\u00AF\\u00B2-\\u00B5\\u00B7-\\u00BA",
            "\\u00BC-\\u00BE\\u00C0-\\u00D6\\u00D8-\\u00F6\\u00F8-\\u00FF",
            "\\u0100-\\u02FF\\u0370-\\u167F\\u1681-\\u180D\\u180F-\\u1DBF",
            "\\u1E00-\\u1FFF",
            "\\u200B-\\u200D\\u202A-\\u202E\\u203F-\\u2040\\u2054\\u2060-\\u206F",
            "\\u2070-\\u20CF\\u2100-\\u218F\\u2460-\\u24FF\\u2776-\\u2793",
            "\\u2C00-\\u2DFF\\u2E80-\\u2FFF",
            "\\u3004-\\u3007\\u3021-\\u302F\\u3031-\\u303F\\u3040-\\uD7FF",
            "\\uF900-\\uFD3D\\uFD40-\\uFDCF\\uFDF0-\\uFE1F\\uFE30-\\uFE44",
            "\\uFE47-\\uFFFD]",
            "[0-9\\u0300-\\u036F\\u1DC0-\\u1DFF\\u20D0-\\u20FF\\uFE20-\\uFE2F",
            "A-Za-z_\\u00A8\\u00AA\\u00AD\\u00AF\\u00B2-\\u00B5\\u00B7-\\u00BA",
            "\\u00BC-\\u00BE\\u00C0-\\u00D6\\u00D8-\\u00F6\\u00F8-\\u00FF",
            "\\u0100-\\u02FF\\u0370-\\u167F\\u1681-\\u180D\\u180F-\\u1DBF",
            "\\u1E00-\\u1FFF",
            "\\u200B-\\u200D\\u202A-\\u202E\\u203F-\\u2040\\u2054\\u2060-\\u206F",
            "\\u2070-\\u20CF\\u2100-\\u218F\\u2460-\\u24FF\\u2776-\\u2793",
            "\\u2C00-\\u2DFF\\u2E80-\\u2FFF",
            "\\u3004-\\u3007\\u3021-\\u302F\\u3031-\\u303F\\u3040-\\uD7FF",
            "\\uF900-\\uFD3D\\uFD40-\\uFDCF\\uFDF0-\\uFE1F\\uFE30-\\uFE44",
            "\\uFE47-\\uFFFD]*",
          ].join(""),
        ),
      ),
  },
});
