; Text objects for Yarn Spinner (tree-sitter yarn_spinner)
; Compatible with nvim-treesitter text objects

; Function-like objects
(function_call) @function.outer
(function_call
  function: (identifier)
  "("
  ")"
) @function.inner

; Class-like objects (enums and types)
(enum_statement) @class.outer
(enum_statement
  (enum_kw)
  name: (identifier)
  (command_end)
  (enum_case_statement)*
  (command_start)
  (endenum_kw)
) @class.inner

; Block objects (control structures)
(if_statement) @block.outer
(if_clause
  (command_end)
  (statement)*
) @block.inner

(else_if_clause
  (command_end)
  (statement)*
) @block.inner

(else_clause
  (command_end)
  (statement)*
) @block.inner

(once_statement) @block.outer
(once_clause
  (command_end)
  (statement)*
) @block.inner

(once_alternate_clause
  (command_end)
  (statement)*
) @block.inner

; Node objects (top-level dialogue nodes)
(node) @class.outer
(node
  (body_start)
  (statement)*
  (body_end)
) @class.inner

; Conditional objects
(if_statement) @conditional.outer
(if_clause) @conditional.inner
(else_if_clause) @conditional.inner
(else_clause) @conditional.inner

(line_condition) @conditional.outer

; Loop-like objects (once statements)
(once_statement) @loop.outer
(once_clause) @loop.inner

; Comment objects
(comment) @comment.outer

; Assignment objects
(set_statement) @assignment.outer
(declare_statement) @assignment.outer

; Parameter objects (function call arguments)
(function_call
  "("
  (expression) @parameter.inner
  ")"
) @parameter.outer

; Call objects
(call_statement) @call.outer
(function_call) @call.outer
(function_call
  function: (identifier)
  "("
  (expression)*
  ")"
) @call.inner

; String-like objects
(string) @string.outer
(text) @string.outer

; Statement objects
(line_statement) @statement.outer
(set_statement) @statement.outer
(call_statement) @statement.outer
(declare_statement) @statement.outer
(jump_statement) @statement.outer
(return_statement) @statement.outer
(command_statement) @statement.outer

; Shortcut option objects
(shortcut_option) @block.outer
(shortcut_option
  (shortcut_arrow)
  (line_statement)
  (indent)
  (statement)*
  (dedent)
) @block.inner

; Line group objects
(line_group_item) @block.outer
(line_group_item
  (line_group_arrow)
  (line_statement)
  (indent)
  (statement)*
  (dedent)
) @block.inner

; Expression objects
(binary_expression) @expression.outer
(unary_expression) @expression.outer
(paren_expression) @expression.outer
(member_expression) @expression.outer
(variable) @expression.outer
(number) @expression.outer
(string) @expression.outer
