import AVFoundation
import Foundation

@MainActor
final class RecipeNarrator: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    private let synthesizer = AVSpeechSynthesizer()
    @Published private(set) var isSpeaking = false
    var settings: AppSettings?
    
    var recipeSpeed: Float {
        settings?.voiceSpeedRecipes ?? 0.47
    }
    
    var ingredientSpeed: Float {
        settings?.voiceSpeedIngredients ?? 0.47
    }
    
    var stepSpeed: Float {
        settings?.voiceSpeedSteps ?? 0.47
    }

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func speak(_ text: String, rate: Float? = nil) {
        stop()
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = rate ?? recipeSpeed
        utterance.voice = AVSpeechSynthesisVoice(language: "en-PH")
        synthesizer.speak(utterance)
    }

    func append(_ text: String, rate: Float? = nil) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = rate ?? recipeSpeed
        utterance.voice = AVSpeechSynthesisVoice(language: "en-PH")
        synthesizer.speak(utterance)
    }
    
    func speakIngredients(_ text: String) {
        stop()
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = ingredientSpeed
        utterance.voice = AVSpeechSynthesisVoice(language: "en-PH")
        synthesizer.speak(utterance)
    }
    
    func speakSteps(_ text: String) {
        stop()
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = stepSpeed
        utterance.voice = AVSpeechSynthesisVoice(language: "en-PH")
        synthesizer.speak(utterance)
    }

    func stop() {
        if synthesizer.isSpeaking { synthesizer.stopSpeaking(at: .immediate) }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        isSpeaking = true
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        if !synthesizer.isSpeaking { isSpeaking = false }
    }
}
