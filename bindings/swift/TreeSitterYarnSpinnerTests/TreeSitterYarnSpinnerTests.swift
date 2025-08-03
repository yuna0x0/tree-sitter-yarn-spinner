import XCTest
import SwiftTreeSitter
import TreeSitterYarnSpinner

final class TreeSitterYarnSpinnerTests: XCTestCase {
    func testCanLoadGrammar() throws {
        let parser = Parser()
        let language = Language(language: tree_sitter_yarn_spinner())
        XCTAssertNoThrow(try parser.setLanguage(language),
                         "Error loading Yarn Spinner grammar")
    }
}
