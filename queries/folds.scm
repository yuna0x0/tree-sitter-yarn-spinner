; Folding rules for Yarn Spinner (tree-sitter yarn_spinner)
; Compatible with nvim-treesitter folding

; Node bodies - fold between --- and ===
(node
  (body_start) @fold.begin
  (body_end) @fold.end) @fold

; If statement blocks
(if_statement) @fold

(if_clause
  (command_end) @fold.begin)

(else_if_clause
  (command_end) @fold.begin)

(else_clause
  (command_end) @fold.begin)

; Once statement blocks
(once_statement) @fold

(once_clause
  (command_end) @fold.begin)

(once_alternate_clause
  (command_end) @fold.begin)

; Enum statements
(enum_statement
  (command_end) @fold.begin
  (command_start) @fold.end) @fold

; Shortcut option groups
(shortcut_option_statement) @fold

; Line group statements
(line_group_statement) @fold

; Individual shortcut options with nested content
(shortcut_option
  (indent) @fold.begin
  (dedent) @fold.end) @fold

; Individual line group items with nested content
(line_group_item
  (indent) @fold.begin
  (dedent) @fold.end) @fold

; Multi-line command statements
(command_statement) @fold

; Multi-line function calls
(function_call
  "(" @fold.begin
  ")" @fold.end) @fold

; Comments (for long comment blocks)
(comment) @fold
