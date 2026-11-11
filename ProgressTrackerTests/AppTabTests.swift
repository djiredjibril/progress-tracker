import Testing
@testable import ProgressTracker

struct AppTabTests {
    @Test func tabsAreInDisplayOrder() {
        #expect(AppTab.allCases == [.home, .calendar, .analytics, .profile])
    }

    @Test func everyTabHasTitleAndIcon() {
        for tab in AppTab.allCases {
            #expect(!tab.title.isEmpty)
            #expect(!tab.systemImage.isEmpty)
        }
    }

    @Test func idsAreUnique() {
        #expect(Set(AppTab.allCases.map(\.id)).count == AppTab.allCases.count)
    }
}
