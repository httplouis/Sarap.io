import AVFoundation
import Foundation

final class SpeechAssistant: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    @Published private(set) var isSpeaking = false
    @Published private(set) var nextStepIndex = 0

    private let synthesizer = AVSpeechSynthesizer()

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func speak(_ text: String) {
        guard !text.isEmpty else { return }
        stop()
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        synthesizer.speak(utterance)
        isSpeaking = true
    }

    func speakIngredients(_ ingredients: [Ingredient]) {
        let joined = ingredients.map { $0.display }.joined(separator: ". ")
        speak("Ingredients: \(joined)")
    }

    func speakSteps(_ steps: [StepItem]) {
        let sorted = steps.sorted { $0.order < $1.order }
        let message = sorted.map { "Step \($0.order): \($0.text)" }.joined(separator: ". ")
        speak(message)
        nextStepIndex = sorted.first?.order ?? 0
    }

    func speakNextStep(from steps: [StepItem]) {
        let sorted = steps.sorted { $0.order < $1.order }
        guard !sorted.isEmpty else { return }
        if nextStepIndex == 0 { nextStepIndex = sorted.first?.order ?? 1 }
        guard let step = sorted.first(where: { $0.order >= nextStepIndex }) else {
            speak("All steps complete. Great job!")
            nextStepIndex = 0
            return
        }
        speak("Next, Step \(step.order): \(step.text)")
        nextStepIndex = step.order + 1
    }

    func stop() {
        if synthesizer.isSpeaking { synthesizer.stopSpeaking(at: .immediate) }
        isSpeaking = false
    }

    func reset() {
        stop()
        nextStepIndex = 0
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        isSpeaking = false
    }
}
