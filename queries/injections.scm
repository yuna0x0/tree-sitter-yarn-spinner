; Injections for Yarn Spinner (tree-sitter yarn_spinner)
; Compatible with nvim-treesitter language injections

; Currently, Yarn Spinner doesn't have direct language injections
; like embedded JavaScript in HTML or SQL in Python strings.
; However, we can potentially add injections for:

; 1. Comments could potentially contain other markup languages
; (This is commented out as it's not commonly needed)
; ((comment) @injection.content
;  (#set! injection.language "markdown"))

; 2. String literals could potentially contain other languages
; (This is commented out as it's not standard in Yarn Spinner)
; ((string) @injection.content
;  (#match? @injection.content "^(SELECT|INSERT|UPDATE|DELETE)")
;  (#set! injection.language "sql"))

; 3. Command text could potentially contain script snippets
; (This is commented out as Yarn Spinner commands are domain-specific)
; ((command_text) @injection.content
;  (#match? @injection.content "^(function|var|let|const)")
;  (#set! injection.language "javascript"))

; For now, we'll keep this file minimal as Yarn Spinner is primarily
; a standalone dialogue language without common embedded languages.
; Users can extend this file if they use custom extensions that embed
; other languages within Yarn Spinner files.
