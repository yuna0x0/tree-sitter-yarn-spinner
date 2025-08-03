package tree_sitter_yarn_spinner_test

import (
	"testing"

	tree_sitter "github.com/tree-sitter/go-tree-sitter"
	tree_sitter_yarn_spinner "github.com/yuna0x0/tree-sitter-yarn-spinner/bindings/go"
)

func TestCanLoadGrammar(t *testing.T) {
	language := tree_sitter.NewLanguage(tree_sitter_yarn_spinner.Language())
	if language == nil {
		t.Errorf("Error loading Yarn Spinner grammar")
	}
}
