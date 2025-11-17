import AVFoundation
import Foundation

final class RecipeNarrator: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    private let synthesizer = AVSpeechSynthesizer()
    @Published private(set) var isSpeaking = false
    @Published private(set) var isPaused = false
    @Published private(set) var currentStepIndex = 0
    @Published var isChefModeActive = false
    
    // Voice preferences (stored in UserDefaults)
    @Published var speechRate: Float {
        didSet {
            UserDefaults.standard.set(speechRate, forKey: "voice.speechRate")
        }
    }
    
    @Published var autoAdvanceSteps: Bool {
        didSet {
            UserDefaults.standard.set(autoAdvanceSteps, forKey: "voice.autoAdvance")
        }
    }
    
    private var queuedSteps: [String] = []
    private var currentStepCount = 0
    
    override init() {
        // Load saved preferences
        self.speechRate = UserDefaults.standard.object(forKey: "voice.speechRate") as? Float ?? 0.52
        self.autoAdvanceSteps = UserDefaults.standard.bool(forKey: "voice.autoAdvance")
        
        super.init()
        synthesizer.delegate = self
        
        // Setup audio session
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.duckOthers])
            try audioSession.setActive(true)
        } catch {
            print("⚠️ Audio session setup failed: \(error)")
        }
    }
    
    // Get best available voice
    private func getBestVoice() -> AVSpeechSynthesisVoice? {
        let voices = AVSpeechSynthesisVoice.speechVoices()
        // Prefer high-quality voices
        if let samantha = voices.first(where: { $0.name.contains("Samantha") || $0.name.contains("Siri") }) {
            return samantha
        }
        return AVSpeechSynthesisVoice(language: "en-US")
    }

    // MARK: - Basic Speech
    func speak(_ text: String, rate: Float? = nil) {
        if !isPaused {
            stop()
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = rate ?? speechRate
        utterance.voice = getBestVoice()
        utterance.pitchMultiplier = 1.05
        utterance.volume = 1.0
        utterance.preUtteranceDelay = 0.1
        utterance.postUtteranceDelay = 0.1
        
        synthesizer.speak(utterance)
    }

    func append(_ text: String, rate: Float? = nil) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = rate ?? speechRate
        utterance.voice = getBestVoice()
        utterance.pitchMultiplier = 1.05
        synthesizer.speak(utterance)
    }
    
    // MARK: - Playback Controls
    func pause() {
        if synthesizer.isSpeaking {
            synthesizer.pauseSpeaking(at: .word)
            isPaused = true
        }
    }
    
    func resume() {
        if isPaused {
            synthesizer.continueSpeaking()
            isPaused = false
        }
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        DispatchQueue.main.async { [weak self] in
            self?.isSpeaking = false
            self?.isPaused = false
        }
    }
    
    // MARK: - Chef Mode (Auto-advance through steps)
    func startChefMode(steps: [String], recipeName: String) {
        stop()
        queuedSteps = steps
        currentStepIndex = 0
        currentStepCount = steps.count
        isChefModeActive = true
        
        let intro = "Starting Chef Mode for \(recipeName). I'll guide you through \(steps.count) steps. Let's begin."
        speak(intro)
        
        if !steps.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
                self?.speakCurrentStep()
            }
        }
    }
    
    func speakCurrentStep() {
        guard isChefModeActive, currentStepIndex < queuedSteps.count else {
            completeChefMode()
            return
        }
        
        let stepNumber = currentStepIndex + 1
        let stepText = queuedSteps[currentStepIndex]
        let announcement = "Step \(stepNumber) of \(currentStepCount). \(stepText)"
        speak(announcement)
    }
    
    func nextStep() {
        guard isChefModeActive else { return }
        stop()
        
        if currentStepIndex < queuedSteps.count - 1 {
            currentStepIndex += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.speakCurrentStep()
            }
        } else {
            completeChefMode()
        }
    }
    
    func previousStep() {
        guard isChefModeActive, currentStepIndex > 0 else { return }
        stop()
        currentStepIndex -= 1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.speakCurrentStep()
        }
    }
    
    func repeatStep() {
        guard isChefModeActive else { return }
        stop()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.speakCurrentStep()
        }
    }
    
    func exitChefMode() {
        stop()
        isChefModeActive = false
        queuedSteps = []
        currentStepIndex = 0
    }
    
    private func completeChefMode() {
        isChefModeActive = false
        speak("All steps complete! Your dish is ready. Enjoy your meal!")
        queuedSteps = []
        currentStepIndex = 0
    }

    // MARK: - AVSpeechSynthesizerDelegate
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        isSpeaking = true
        isPaused = false
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        if !synthesizer.isSpeaking {
            isSpeaking = false
            
            // Auto-advance in Chef Mode if enabled
            if isChefModeActive && autoAdvanceSteps {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                    self?.nextStep()
                }
            }
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        isPaused = true
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        isPaused = false
    }
}
