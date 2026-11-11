struct DailyGoal {
    var title: String       // "Keep Going!"
    var progress: Double    // 0...1
    var progressPercent: Int { Int((progress * 100).rounded()) }
}
