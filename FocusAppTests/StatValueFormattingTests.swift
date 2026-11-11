import Foundation
import Testing
@testable import FocusApp

struct StatValueFormattingTests {
    @Test func plainNumberHasNoUnit() {
        #expect(String(AttributedString.stat([(12, "")]).characters) == "12")
    }

    @Test func hoursAndMinutesAreSeparatedBySpace() {
        #expect(String(AttributedString.stat([(6, "h"), (24, "m")]).characters) == "6h 24m")
    }
}
