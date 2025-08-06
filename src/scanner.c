#include "tree_sitter/parser.h"
#include <string.h>
#include <stdbool.h>
#include <stdio.h>

enum TokenType {
    INDENT,
    DEDENT,
    BLANK_LINE_FOLLOWING_OPTION,
};

typedef struct {
    uint32_t *indents;
    uint32_t indent_count;
    uint32_t indent_capacity;
    bool in_when_clause;
    bool line_contains_indent_tracking_token;
    int32_t last_indent;
    int32_t last_seen_indent_tracking_content;
    int32_t current_line;
    bool hit_eof;
} Scanner;

static void advance(TSLexer *lexer) {
    lexer->advance(lexer, false);
}

static void skip(TSLexer *lexer) {
    lexer->advance(lexer, true);
}

static bool is_whitespace(int32_t c) {
    return c == ' ' || c == '\t';
}

static bool is_newline(int32_t c) {
    return c == '\n' || c == '\r';
}

static uint32_t get_indent_length(TSLexer *lexer) {
    uint32_t length = 0;
    bool saw_spaces = false;
    bool saw_tabs = false;

    while (is_whitespace(lexer->lookahead)) {
        if (lexer->lookahead == ' ') {
            length += 1;
            saw_spaces = true;
        } else if (lexer->lookahead == '\t') {
            length += 8;  // Tab counts as 8 spaces
            saw_tabs = true;
        }
        advance(lexer);
    }

    // Warning: mixed tabs and spaces (would be handled in real implementation)
    if (saw_spaces && saw_tabs) {
        // In a real implementation, you might want to emit a warning
    }

    return length;
}

static void push_indent(Scanner *scanner, uint32_t indent) {
    if (scanner->indent_count >= scanner->indent_capacity) {
        scanner->indent_capacity = scanner->indent_capacity > 0 ? scanner->indent_capacity * 2 : 4;
        scanner->indents = realloc(scanner->indents, scanner->indent_capacity * sizeof(uint32_t));
    }
    scanner->indents[scanner->indent_count++] = indent;
}

static uint32_t pop_indent(Scanner *scanner) {
    if (scanner->indent_count > 0) {
        return scanner->indents[--scanner->indent_count];
    }
    return 0;
}

static uint32_t peek_indent(Scanner *scanner) {
    if (scanner->indent_count > 0) {
        return scanner->indents[scanner->indent_count - 1];
    }
    return 0;
}

static bool scan_indent_dedent(Scanner *scanner, TSLexer *lexer, const bool *valid_symbols) {
    // Only handle indentation when specifically requested and be very conservative
    if (!valid_symbols[INDENT] && !valid_symbols[DEDENT]) {
        return false;
    }

    // Skip any whitespace at the beginning of the line
    while (is_whitespace(lexer->lookahead)) {
        skip(lexer);
    }

    // If we hit a newline or EOF, don't emit indent/dedent
    if (is_newline(lexer->lookahead) || lexer->eof(lexer)) {
        return false;
    }

    uint32_t current_indent = lexer->get_column(lexer);

    // Be very conservative - only emit INDENT when absolutely necessary
    // and when we're explicitly after shortcut arrows or line group arrows
    if (valid_symbols[INDENT] && current_indent > scanner->last_indent &&
        scanner->line_contains_indent_tracking_token && current_indent > 0) {
        push_indent(scanner, current_indent);
        scanner->last_indent = current_indent;
        scanner->line_contains_indent_tracking_token = false;
        lexer->result_symbol = INDENT;
        return true;
    }

    // Only emit DEDENT when we have pending indents and significant decrease
    if (valid_symbols[DEDENT] && scanner->indent_count > 0 &&
        current_indent < peek_indent(scanner)) {
        pop_indent(scanner);
        scanner->last_indent = current_indent;
        lexer->result_symbol = DEDENT;
        return true;
    }

    return false;
}

static bool scan_blank_line_following_option(Scanner *scanner, TSLexer *lexer, const bool *valid_symbols) {
    if (!valid_symbols[BLANK_LINE_FOLLOWING_OPTION]) {
        return false;
    }

    // Look for a blank line (newline followed by optional whitespace and another newline)
    if (is_newline(lexer->lookahead)) {
        advance(lexer);

        // Skip any carriage return
        if (lexer->lookahead == '\n' && lexer->lookahead != '\r') {
            advance(lexer);
        }

        // Skip whitespace
        while (is_whitespace(lexer->lookahead)) {
            advance(lexer);
        }

        // If we find another newline or EOF, this is a blank line
        if (is_newline(lexer->lookahead) || lexer->eof(lexer)) {
            lexer->result_symbol = BLANK_LINE_FOLLOWING_OPTION;
            return true;
        }
    }

    return false;
}

void *tree_sitter_yarn_spinner_external_scanner_create() {
    Scanner *scanner = calloc(1, sizeof(Scanner));
    scanner->indents = NULL;
    scanner->indent_count = 0;
    scanner->indent_capacity = 0;
    scanner->in_when_clause = false;
    scanner->line_contains_indent_tracking_token = false;
    scanner->last_indent = 0;
    scanner->last_seen_indent_tracking_content = -1;
    scanner->current_line = 0;
    scanner->hit_eof = false;
    return scanner;
}

void tree_sitter_yarn_spinner_external_scanner_destroy(void *payload) {
    Scanner *scanner = (Scanner *)payload;
    if (scanner->indents) {
        free(scanner->indents);
    }
    free(scanner);
}

unsigned tree_sitter_yarn_spinner_external_scanner_serialize(void *payload, char *buffer) {
    Scanner *scanner = (Scanner *)payload;

    if (scanner->indent_count * sizeof(uint32_t) + sizeof(Scanner) > TREE_SITTER_SERIALIZATION_BUFFER_SIZE) {
        return 0;
    }

    size_t size = 0;

    // Serialize the scanner state
    memcpy(buffer + size, &scanner->indent_count, sizeof(uint32_t));
    size += sizeof(uint32_t);

    memcpy(buffer + size, &scanner->in_when_clause, sizeof(bool));
    size += sizeof(bool);

    memcpy(buffer + size, &scanner->line_contains_indent_tracking_token, sizeof(bool));
    size += sizeof(bool);

    memcpy(buffer + size, &scanner->last_indent, sizeof(int32_t));
    size += sizeof(int32_t);

    memcpy(buffer + size, &scanner->last_seen_indent_tracking_content, sizeof(int32_t));
    size += sizeof(int32_t);

    memcpy(buffer + size, &scanner->current_line, sizeof(int32_t));
    size += sizeof(int32_t);

    memcpy(buffer + size, &scanner->hit_eof, sizeof(bool));
    size += sizeof(bool);

    // Serialize the indentation stack
    for (uint32_t i = 0; i < scanner->indent_count; i++) {
        memcpy(buffer + size, &scanner->indents[i], sizeof(uint32_t));
        size += sizeof(uint32_t);
    }

    return size;
}

void tree_sitter_yarn_spinner_external_scanner_deserialize(void *payload, const char *buffer, unsigned length) {
    Scanner *scanner = (Scanner *)payload;

    if (length == 0) {
        scanner->indent_count = 0;
        scanner->in_when_clause = false;
        scanner->line_contains_indent_tracking_token = false;
        scanner->last_indent = 0;
        scanner->last_seen_indent_tracking_content = -1;
        scanner->current_line = 0;
        scanner->hit_eof = false;
        return;
    }

    size_t size = 0;

    // Deserialize the scanner state
    memcpy(&scanner->indent_count, buffer + size, sizeof(uint32_t));
    size += sizeof(uint32_t);

    memcpy(&scanner->in_when_clause, buffer + size, sizeof(bool));
    size += sizeof(bool);

    memcpy(&scanner->line_contains_indent_tracking_token, buffer + size, sizeof(bool));
    size += sizeof(bool);

    memcpy(&scanner->last_indent, buffer + size, sizeof(int32_t));
    size += sizeof(int32_t);

    memcpy(&scanner->last_seen_indent_tracking_content, buffer + size, sizeof(int32_t));
    size += sizeof(int32_t);

    memcpy(&scanner->current_line, buffer + size, sizeof(int32_t));
    size += sizeof(int32_t);

    memcpy(&scanner->hit_eof, buffer + size, sizeof(bool));
    size += sizeof(bool);

    // Deserialize the indentation stack
    if (scanner->indent_count > 0) {
        scanner->indent_capacity = scanner->indent_count;
        scanner->indents = malloc(scanner->indent_capacity * sizeof(uint32_t));

        for (uint32_t i = 0; i < scanner->indent_count; i++) {
            memcpy(&scanner->indents[i], buffer + size, sizeof(uint32_t));
            size += sizeof(uint32_t);
        }
    }
}

bool tree_sitter_yarn_spinner_external_scanner_scan(void *payload, TSLexer *lexer, const bool *valid_symbols) {
    Scanner *scanner = (Scanner *)payload;

    // Try to scan for blank line following option first
    if (scan_blank_line_following_option(scanner, lexer, valid_symbols)) {
        return true;
    }

    // Try to scan for indent/dedent tokens - be very conservative
    if (scan_indent_dedent(scanner, lexer, valid_symbols)) {
        return true;
    }

    return false;
}
