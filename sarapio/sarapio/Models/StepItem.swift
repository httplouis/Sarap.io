import Foundation

struct StepItem: Identifiable, Equatable, Hashable, Codable {
    let id = UUID()
    var order: Int
    var text: String
    var timerMinutes: Int? = nil // optional timer for this step
    var imageData: Data? = nil // optional step image
    var tip: String? = nil // optional tip for this step

    init(_ order: Int, _ text: String, timerMinutes: Int? = nil, tip: String? = nil) {
        self.order = order
        self.text = text
        self.timerMinutes = timerMinutes
        self.tip = tip
    }
    
    var hasTimer: Bool {
        timerMinutes != nil && timerMinutes! > 0
    }
}
