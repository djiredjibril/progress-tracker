import Foundation
import Testing
@testable import ProgressTracker

struct SettingsOptionsTests {
    @Test(arguments: [(1, "1 task"), (5, "5 tasks"), (10, "10 tasks")])
    func dailyGoalLabels(count: Int, expected: String) {
        #expect(SettingsOptions.dailyGoalLabel(count) == expected)
    }

    @Test func focusLabelAndOptions() {
        #expect(SettingsOptions.focusLabel(25) == "25 min")
        #expect(SettingsOptions.focusMinuteOptions.contains(SettingsOptions.defaultFocusMinutes))
        #expect(SettingsOptions.dailyGoalRange.contains(SettingsOptions.defaultDailyGoal))
    }

    @Test func settingsKeysAreUnique() {
        let keys = [SettingsKey.notificationsEnabled, SettingsKey.dailyGoal, SettingsKey.focusMinutes]
        #expect(Set(keys).count == keys.count)
    }

    @Test func focusSessionConfigUsesTheChosenMinutes() {
        let config = FocusSessionConfig(focusMinutes: 45)
        #expect(config.focusDuration == 45 * 60)
        #expect(config.breakDuration == 5 * 60)
        #expect(config.sessionCount == 4)
    }

    @Test func defaultFocusSessionConfigIsThePomodoro() {
        #expect(FocusSessionConfig() == FocusSessionConfig(focusMinutes: 25))
    }
}
