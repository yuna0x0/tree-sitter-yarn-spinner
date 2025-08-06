; Highlights for Yarn Spinner (tree-sitter yarn_spinner)
; Compatible with nvim-treesitter highlight groups

; Comments
(comment) @comment

; File-level hashtags and inline hashtags
(file_hashtag
  (hashtag_marker) @punctuation.special
  (hashtag_text) @tag)

(hashtag
  (hashtag_marker) @punctuation.special
  (hashtag_text) @tag)

; Node headers
(title_header
  (title_kw) @keyword
  title: (rest_of_line) @markup.heading)

(when_header
  (when_kw) @keyword
  expr: (_) @expression)

(header
  key: (identifier) @property
  value: (rest_of_line)? @string)

(header_delimiter) @punctuation.delimiter

; Header when expression variants
(header_when_expression
  (always_kw) @keyword.conditional)

(header_when_expression
  (once_kw) @keyword.repeat
  (if_kw)? @keyword.conditional)

; Body delimiters
(body_start) @punctuation.special
(body_end) @punctuation.special

; Statements and structural arrows
(shortcut_arrow) @operator
(line_group_arrow) @operator

; Commands
(command_start) @punctuation.bracket
(command_end) @punctuation.bracket
(command_text) @string.special

; Control flow keywords
(if_kw) @keyword.conditional
(elseif_kw) @keyword.conditional
(else_kw) @keyword.conditional
(endif_kw) @keyword.conditional
(once_kw) @keyword.repeat
(endonce_kw) @keyword.repeat

; Declaration keywords
(enum_kw) @keyword.type
(endenum_kw) @keyword.type
(case_kw) @keyword.type
(declare_kw) @keyword.storage
(as_kw) @keyword.storage

; Action keywords
(set_kw) @keyword.operator
(call_kw) @keyword.function
(jump_kw) @keyword.return
(detour_kw) @keyword.return
(return_kw) @keyword.return

; Always keyword
(always_kw) @keyword.conditional

; Expression keywords and operators
(not_kw) @keyword.operator
(and_kw) @keyword.operator
(or_kw) @keyword.operator
(xor_kw) @keyword.operator
(is_kw) @keyword.operator
(eq_kw) @keyword.operator
(neq_kw) @keyword.operator
(lt_kw) @keyword.operator
(gt_kw) @keyword.operator
(lte_kw) @keyword.operator
(gte_kw) @keyword.operator

; Boolean and null literals
(true_kw) @boolean
(false_kw) @boolean
(null_kw) @constant.builtin

; If statements
(if_clause
  (if_kw) @keyword.conditional)

(else_if_clause
  (elseif_kw) @keyword.conditional)

(else_clause
  (else_kw) @keyword.conditional)

; Once statements
(once_clause
  (once_kw) @keyword.repeat
  (if_kw)? @keyword.conditional)

(once_alternate_clause
  (else_kw) @keyword.conditional)

; Enum statements
(enum_statement
  (enum_kw) @keyword.type
  name: (identifier) @type.definition)

(enum_case_statement
  (case_kw) @keyword.type
  name: (identifier) @constant
  operator: (_)? @operator
  value: (_)? @expression)

; Set statement
(set_statement
  (set_kw) @keyword.operator
  operator: (_) @operator)

; Call statement
(call_statement
  (call_kw) @keyword.function)

; Declare statement
(declare_statement
  (declare_kw) @keyword.storage
  (as_kw)? @keyword.storage
  type: (identifier)? @type)

; Jump statements
(jump_statement
  (jump_kw) @keyword.return
  destination: (identifier)? @function)

(jump_statement
  (detour_kw) @keyword.return
  destination: (identifier)? @function)

; Return statement
(return_statement
  (return_kw) @keyword.return)

; Line condition
(line_condition
  (if_kw) @keyword.conditional)

(line_condition
  (once_kw) @keyword.repeat
  (if_kw)? @keyword.conditional)

; Inline expressions
(expression_start) @punctuation.bracket
(expression_end) @punctuation.bracket

; Text content
(text) @string

; Variables and identifiers
(variable
  "$" @punctuation.delimiter
  (identifier) @variable)

(identifier) @identifier

; Numbers and strings
(number) @number
(string) @string

; Binary expressions and operators
(binary_expression
  operator: ("*") @operator)
(binary_expression
  operator: ("/") @operator)
(binary_expression
  operator: ("%") @operator)
(binary_expression
  operator: ("+") @operator)
(binary_expression
  operator: ("-") @operator)
(binary_expression
  operator: ("<=") @operator)
(binary_expression
  operator: (">=") @operator)
(binary_expression
  operator: ("<") @operator)
(binary_expression
  operator: (">") @operator)
(binary_expression
  operator: ("==") @operator)
(binary_expression
  operator: ("!=") @operator)
(binary_expression
  operator: ("&&") @operator)
(binary_expression
  operator: ("||") @operator)
(binary_expression
  operator: ("^") @operator)

; Unary expressions
(unary_expression
  operator: ("-") @operator)
(unary_expression
  operator: ("!") @operator)

; Assignment operators
"=" @operator
"to" @operator
"+=" @operator
"-=" @operator
"*=" @operator
"/=" @operator
"%=" @operator

; Parenthesized expressions
(paren_expression
  "(" @punctuation.bracket
  ")" @punctuation.bracket)

; Function calls
(function_call
  function: (identifier) @function.call
  "(" @punctuation.bracket
  "," @punctuation.delimiter
  ")" @punctuation.bracket)

; Member expressions
(member_expression
  type: (identifier)? @type
  "." @punctuation.delimiter
  member: (identifier) @property)

; Generic command statement highlighting
(command_statement
  (command_start) @punctuation.bracket
  (command_end) @punctuation.bracket)

; Error highlighting for debugging
(ERROR) @error
