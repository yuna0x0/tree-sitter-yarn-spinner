/**
 * @file Yarn Spinner grammar for tree-sitter
 * @author yuna0x0 <yuna@yuna0x0.com>
 * @license MIT
 */

/// <reference types="tree-sitter-cli/dsl" />
// @ts-check

module.exports = grammar({
  name: "yarn_spinner",

  conflicts: ($) => [
    [$.shortcut_option_statement],
    [$.line_group_statement],
    [$.if_clause],
    [$.else_if_clause],
    [$.else_clause],
    [$.shortcut_option],
    [$.line_group_item],
    [$.once_clause],
    [$.once_alternate_clause],
  ],

  externals: ($) => [$.indent, $.dedent, $.blank_line_following_option],

  extras: ($) => [/\s/, $.comment],

  word: ($) => $.identifier,

  rules: {
    source_file: ($) => seq(repeat($.file_hashtag), repeat1($.node)),

    comment: (_) => token(seq("//", /[^\r\n]*/)),

    // File-global hashtags at top of file (before any node)
    file_hashtag: ($) =>
      seq($.hashtag_marker, field("text", $.hashtag_text), $.newline),

    // Node
    node: ($) =>
      seq(
        repeat1(choice($.title_header, $.when_header, $.header)),
        field("body_start", alias("---", $.body_start)),
        repeat($.statement),
        field("body_end", alias("===", $.body_end)),
      ),

    // Headers
    title_header: ($) =>
      seq(
        $.title_kw,
        $.header_delimiter,
        field("title", $.rest_of_line),
        $.newline,
      ),

    when_header: ($) =>
      seq(
        $.when_kw,
        $.header_delimiter,
        field("expr", $.header_when_expression),
        $.newline,
      ),

    header_when_expression: ($) =>
      choice(
        $.expression,
        $.always_kw,
        seq($.once_kw, optional(seq($.if_kw, $.expression))),
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

    // Statements
    statement: ($) =>
      choice(
        $.line_statement,
        $.shortcut_option_statement,
        $.line_group_statement,
        $.if_statement,
        $.set_statement,
        $.call_statement,
        $.declare_statement,
        $.enum_statement,
        $.jump_statement,
        $.return_statement,
        $.once_statement,
        $.command_statement,
        seq($.indent, repeat($.statement), $.dedent),
      ),

    // Line: text/expressions, optional hashtags, newline
    line_statement: ($) =>
      seq(
        $.line_formatted_text,
        optional($.line_condition),
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
        seq($.command_start, $.if_kw, $.expression, $.command_end),
        seq(
          $.command_start,
          $.once_kw,
          optional(seq($.if_kw, $.expression)),
          $.command_end,
        ),
      ),

    // If statements
    if_statement: ($) =>
      seq(
        $.if_clause,
        repeat($.else_if_clause),
        optional($.else_clause),
        $.command_start,
        $.endif_kw,
        $.command_end,
      ),

    if_clause: ($) =>
      seq(
        $.command_start,
        $.if_kw,
        $.expression,
        $.command_end,
        repeat($.statement),
      ),

    else_if_clause: ($) =>
      seq(
        $.command_start,
        $.elseif_kw,
        $.expression,
        $.command_end,
        repeat($.statement),
      ),

    else_clause: ($) =>
      seq($.command_start, $.else_kw, $.command_end, repeat($.statement)),

    // Once statements
    once_statement: ($) =>
      seq(
        $.once_clause,
        optional($.once_alternate_clause),
        $.command_start,
        $.endonce_kw,
        $.command_end,
      ),

    once_clause: ($) =>
      seq(
        $.command_start,
        $.once_kw,
        optional(seq($.if_kw, $.expression)),
        $.command_end,
        repeat($.statement),
      ),

    once_alternate_clause: ($) =>
      seq($.command_start, $.else_kw, $.command_end, repeat($.statement)),

    // Enum statements
    enum_statement: ($) =>
      seq(
        $.command_start,
        $.enum_kw,
        field("name", $.identifier),
        $.command_end,
        repeat1($.enum_case_statement),
        $.command_start,
        $.endenum_kw,
        $.command_end,
      ),

    enum_case_statement: ($) =>
      seq(
        optional($.indent),
        $.command_start,
        $.case_kw,
        field("name", $.identifier),
        optional(
          seq(
            field("operator", choice("=", "to")),
            field("value", $.expression),
          ),
        ),
        $.command_end,
        optional($.dedent),
      ),

    // Set statement
    set_statement: ($) =>
      seq(
        $.command_start,
        $.set_kw,
        $.variable,
        field("operator", choice("=", "to", "+=", "-=", "*=", "/=", "%=")),
        $.expression,
        $.command_end,
        $.newline,
      ),

    // Call statement
    call_statement: ($) =>
      seq(
        $.command_start,
        $.call_kw,
        $.function_call,
        $.command_end,
        $.newline,
      ),

    // Declare statement
    declare_statement: ($) =>
      seq(
        $.command_start,
        $.declare_kw,
        $.variable,
        choice("=", "to"),
        $.expression,
        optional(seq($.as_kw, field("type", $.identifier))),
        $.command_end,
        $.newline,
      ),

    // Jump statements
    jump_statement: ($) =>
      choice(
        seq(
          $.command_start,
          $.jump_kw,
          field("destination", $.identifier),
          $.command_end,
          $.newline,
        ),
        seq(
          $.command_start,
          $.jump_kw,
          $.expression_start,
          $.expression,
          $.expression_end,
          $.command_end,
          $.newline,
        ),
        seq(
          $.command_start,
          $.detour_kw,
          field("destination", $.identifier),
          $.command_end,
          $.newline,
        ),
        seq(
          $.command_start,
          $.detour_kw,
          $.expression_start,
          $.expression,
          $.expression_end,
          $.command_end,
          $.newline,
        ),
      ),

    // Return statement
    return_statement: ($) =>
      seq($.command_start, $.return_kw, $.command_end, $.newline),

    // Hashtag
    hashtag: ($) => seq($.hashtag_marker, field("text", $.hashtag_text)),
    hashtag_marker: (_) => token("#"),
    hashtag_text: (_) => token(/[^\s#<>{}\r\n][^#<>{}\r\n]*/),

    // Commands - generic commands that don't match specific patterns
    command_statement: ($) =>
      prec(
        -1,
        seq(
          $.command_start,
          repeat1(
            choice(
              $.command_text,
              seq($.expression_start, $.expression, $.expression_end),
            ),
          ),
          $.command_end,
          repeat($.hashtag),
          $.newline,
        ),
      ),

    // Generic command text - matches anything except >> and { and keywords
    command_text: (_) => token(prec(-1, /[^>{\r\n]+/)),

    // Shortcut options group
    shortcut_option_statement: ($) =>
      seq(
        repeat($.shortcut_option),
        $.shortcut_option,
        optional($.blank_line_following_option),
      ),

    shortcut_option: ($) =>
      seq(
        $.shortcut_arrow,
        $.line_statement,
        optional(seq($.indent, repeat($.statement), $.dedent)),
      ),

    // Line group
    line_group_statement: ($) =>
      seq(
        repeat($.line_group_item),
        $.line_group_item,
        optional($.blank_line_following_option),
      ),

    line_group_item: ($) =>
      seq(
        $.line_group_arrow,
        $.line_statement,
        optional(seq($.indent, repeat($.statement), $.dedent)),
      ),

    // Newline token (named for clarity)
    newline: (_) => token(seq(optional("\r"), "\n")),

    // Text chunks for a line: any chars stopping at control markers
    text: (_) => token(/[^#<>{}\r\n\\]+/),

    // Command delimiters
    command_start: (_) => token("<<"),
    command_end: (_) => token(">>"),

    // Shortcut and line group arrows
    shortcut_arrow: (_) => token("->"),
    line_group_arrow: (_) => token("=>"),

    // Expression delimiters
    expression_start: (_) => token("{"),
    expression_end: (_) => token("}"),

    // Keywords - using token with regex to ensure they are recognized as separate tokens
    title_kw: (_) => token("title"),
    when_kw: (_) => token("when"),
    always_kw: (_) => token("always"),
    once_kw: (_) => token("once"),
    if_kw: (_) => token("if"),
    elseif_kw: (_) => token("elseif"),
    else_kw: (_) => token("else"),
    endif_kw: (_) => token("endif"),
    endonce_kw: (_) => token("endonce"),
    enum_kw: (_) => token("enum"),
    endenum_kw: (_) => token("endenum"),
    case_kw: (_) => token("case"),
    set_kw: (_) => token("set"),
    call_kw: (_) => token("call"),
    declare_kw: (_) => token("declare"),
    jump_kw: (_) => token("jump"),
    detour_kw: (_) => token("detour"),
    return_kw: (_) => token("return"),
    as_kw: (_) => token("as"),
    not_kw: (_) => token("not"),
    and_kw: (_) => token("and"),
    or_kw: (_) => token("or"),
    xor_kw: (_) => token("xor"),
    lte_kw: (_) => token("lte"),
    gte_kw: (_) => token("gte"),
    lt_kw: (_) => token("lt"),
    gt_kw: (_) => token("gt"),
    is_kw: (_) => token("is"),
    eq_kw: (_) => token("eq"),
    neq_kw: (_) => token("neq"),
    true_kw: (_) => token("true"),
    false_kw: (_) => token("false"),
    null_kw: (_) => token("null"),

    // Expression language
    expression: ($) =>
      choice(
        $.paren_expression,
        $.binary_expression,
        $.unary_expression,
        $.function_call,
        $.member_expression,
        $.number,
        $.string,
        $.variable,
        $.identifier,
        $.true_kw,
        $.false_kw,
        $.null_kw,
      ),

    paren_expression: ($) => seq("(", $.expression, ")"),

    unary_expression: ($) =>
      prec.right(
        7,
        seq(field("operator", choice("-", "!", $.not_kw)), $.expression),
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
                $.lte_kw,
                $.gte_kw,
                $.lt_kw,
                $.gt_kw,
              ),
            ),
            $.expression,
          ),
        ),
        prec.left(
          3,
          seq(
            $.expression,
            field("operator", choice("==", "!=", $.is_kw, $.eq_kw, $.neq_kw)),
            $.expression,
          ),
        ),
        prec.left(
          2,
          seq(
            $.expression,
            field(
              "operator",
              choice($.and_kw, "&&", $.or_kw, "||", $.xor_kw, "^"),
            ),
            $.expression,
          ),
        ),
      ),

    function_call: ($) =>
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

    identifier: (_) => token(/[A-Za-z_][A-Za-z0-9_]*/),
  },
});
