#include "tree_sitter/parser.h"
#include "tree_sitter/alloc.h"
#include "tree_sitter/array.h"
#include <string.h>

enum TokenType {
  INDENT,
  DEDENT,
  BLANK_LINE_FOLLOWING_OPTION
};

typedef struct {
  Array(uint16_t) indents;
} Scanner;

void *tree_sitter_yarn_spinner_external_scanner_create() {
  Scanner *scanner = ts_calloc(1, sizeof(Scanner));
  array_init(&scanner->indents);
  return scanner;
}

void tree_sitter_yarn_spinner_external_scanner_destroy(void *payload) {
  Scanner *scanner = (Scanner *)payload;
  array_delete(&scanner->indents);
  ts_free(scanner);
}

unsigned tree_sitter_yarn_spinner_external_scanner_serialize(
  void *payload,
  char *buffer
) {
  Scanner *scanner = (Scanner *)payload;

  size_t size = 0;
  size_t indent_count = scanner->indents.size;

  if (size + sizeof(indent_count) > TREE_SITTER_SERIALIZATION_BUFFER_SIZE) return 0;
  memcpy(&buffer[size], &indent_count, sizeof(indent_count));
  size += sizeof(indent_count);

  if (size + indent_count * sizeof(uint16_t) > TREE_SITTER_SERIALIZATION_BUFFER_SIZE) return 0;
  memcpy(&buffer[size], scanner->indents.contents, indent_count * sizeof(uint16_t));
  size += indent_count * sizeof(uint16_t);

  return size;
}

void tree_sitter_yarn_spinner_external_scanner_deserialize(
  void *payload,
  const char *buffer,
  unsigned length
) {
  Scanner *scanner = (Scanner *)payload;

  array_delete(&scanner->indents);
  array_init(&scanner->indents);

  if (length == 0) return;

  size_t size = 0;
  size_t indent_count = 0;

  if (size + sizeof(indent_count) <= length) {
    memcpy(&indent_count, &buffer[size], sizeof(indent_count));
    size += sizeof(indent_count);

    if (size + indent_count * sizeof(uint16_t) <= length) {
      array_reserve(&scanner->indents, indent_count);
      scanner->indents.size = indent_count;
      memcpy(scanner->indents.contents, &buffer[size], indent_count * sizeof(uint16_t));
    }
  }
}

bool tree_sitter_yarn_spinner_external_scanner_scan(
  void *payload,
  TSLexer *lexer,
  const bool *valid_symbols
) {
  Scanner *scanner = (Scanner *)payload;

  // Skip whitespace
  while (lexer->lookahead == ' ' || lexer->lookahead == '\t') {
    lexer->advance(lexer, true);
  }

  // Only handle indentation at the start of a line
  if (lexer->get_column(lexer) != 0) {
    return false;
  }

  // Handle blank line following option - simplified
  if (valid_symbols[BLANK_LINE_FOLLOWING_OPTION]) {
    if (lexer->lookahead == '\n' || lexer->lookahead == '\r' || lexer->eof(lexer)) {
      lexer->result_symbol = BLANK_LINE_FOLLOWING_OPTION;
      return true;
    }
  }

  // Skip empty lines
  if (lexer->lookahead == '\n' || lexer->lookahead == '\r' || lexer->eof(lexer)) {
    return false;
  }

  // Calculate indentation level
  uint16_t indent_size = 0;
  int32_t lookahead = lexer->lookahead;
  while (lookahead == ' ' || lookahead == '\t') {
    if (lookahead == ' ') {
      indent_size++;
    } else {
      indent_size += 8; // Tab = 8 spaces
    }
    lexer->advance(lexer, false);
    lookahead = lexer->lookahead;
  }

  lexer->mark_end(lexer);

  // Get current indentation level
  uint16_t current_indent = 0;
  if (scanner->indents.size > 0) {
    current_indent = scanner->indents.contents[scanner->indents.size - 1];
  }

  // Handle INDENT
  if (valid_symbols[INDENT] && indent_size > current_indent) {
    array_push(&scanner->indents, indent_size);
    lexer->result_symbol = INDENT;
    return true;
  }

  // Handle DEDENT
  if (valid_symbols[DEDENT] && indent_size < current_indent) {
    // Pop one level of indentation
    if (scanner->indents.size > 0) {
      array_pop(&scanner->indents);
    }
    lexer->result_symbol = DEDENT;
    return true;
  }

  return false;
}
