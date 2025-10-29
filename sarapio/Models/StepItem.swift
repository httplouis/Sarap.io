import Foundation

struct StepItem: Identifiable, Equatable, Hashable {
    let id = UUID()
    var order: Int
    var text: String

    init(_ order: Int, _ text: String) {
        self.order = order
        self.text = text
    }
}
