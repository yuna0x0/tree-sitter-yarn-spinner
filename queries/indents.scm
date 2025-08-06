; Indentation rules for Yarn Spinner (tree-sitter yarn_spinner)
; Compatible with nvim-treesitter indentation

; Node body content - indent statements between body_start and body_end
[
  (statement)
] @indent @extend

; If statement blocks
(if_clause
  (command_end) @indent.begin)

(else_if_clause
  (command_end) @indent.begin)

(else_clause
  (command_end) @indent.begin)

; Once statement blocks
(once_clause
  (command_end) @indent.begin)

(once_alternate_clause
  (command_end) @indent.begin)

; Enum case statements
(enum_statement
  (command_end) @indent.begin
  (command_start) @indent.end)

; Shortcut options - indent content after the arrow
(shortcut_option
  (shortcut_arrow) @indent.begin)

; Line group items - indent content after the arrow
(line_group_item
  (line_group_arrow) @indent.begin)

; Parenthesized expressions
(paren_expression
  "(" @indent.begin
  ")" @indent.end)

; Function calls
(function_call
  "(" @indent.begin
  ")" @indent.end)

; Expression interpolation braces
[
  (expression_start)
  "{"
] @indent.begin

[
  (expression_end)
  "}"
] @indent.end

; Command blocks
(command_start) @indent.begin
(command_end) @indent.end

; Body delimiters
(body_start) @indent.begin
(body_end) @indent.end

; Keywords that end blocks
[
  (endif_kw)
  (endonce_kw)
  (endenum_kw)
] @indent.end

; Handle explicit indent/dedent tokens from external scanner
(indent) @indent.begin
(dedent) @indent.end
