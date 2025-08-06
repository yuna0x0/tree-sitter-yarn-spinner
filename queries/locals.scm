; Locals rules for Yarn Spinner (tree-sitter yarn_spinner)
; Compatible with nvim-treesitter locals analysis

; Variable declarations
(declare_statement
  (variable
    (identifier) @local.definition.var))

; Variable assignments
(set_statement
  (variable
    (identifier) @local.definition.var))

; Variable references
(variable
  (identifier) @local.reference)

; Function calls - function name references
(function_call
  function: (identifier) @local.reference)

; Node titles act as labels/targets for jumps
(title_header
  title: (rest_of_line) @local.definition.label)

; Jump destinations
(jump_statement
  destination: (identifier) @local.reference)

; Detour destinations
(jump_statement
  destination: (identifier) @local.reference)

; Enum declarations
(enum_statement
  name: (identifier) @local.definition.type)

; Enum case declarations
(enum_case_statement
  name: (identifier) @local.definition.constant)

; Member expressions - type references
(member_expression
  type: (identifier)? @local.reference
  member: (identifier) @local.reference)

; Type annotations in declare statements
(declare_statement
  type: (identifier)? @local.reference)

; Scopes
(node) @local.scope
(if_statement) @local.scope
(once_statement) @local.scope
(enum_statement) @local.scope
(function_call) @local.scope
