import Foundation
import SwiftUI

final class AppSettings: ObservableObject {
    @Published var isChefMode: Bool = false {
        didSet { saveSettings() }
    }
    
    @Published var voiceSpeedRecipes: Float = 0.47 {
        didSet { saveSettings() }
    }
    
    @Published var voiceSpeedIngredients: Float = 0.47 {
        didSet { saveSettings() }
    }
    
    @Published var voiceSpeedSteps: Float = 0.47 {
        didSet { saveSettings() }
    }
    
    private let settingsKey = "sarapio.appSettings"
    
    init() {
        loadSettings()
    }
    
    private func saveSettings() {
        let settings = SettingsData(
            isChefMode: isChefMode,
            voiceSpeedRecipes: voiceSpeedRecipes,
            voiceSpeedIngredients: voiceSpeedIngredients,
            voiceSpeedSteps: voiceSpeedSteps
        )
        
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: settingsKey)
        }
    }
    
    private func loadSettings() {
        guard let data = UserDefaults.standard.data(forKey: settingsKey),
              let decoded = try? JSONDecoder().decode(SettingsData.self, from: data) else {
            return
        }
        
        isChefMode = decoded.isChefMode
        voiceSpeedRecipes = decoded.voiceSpeedRecipes
        voiceSpeedIngredients = decoded.voiceSpeedIngredients
        voiceSpeedSteps = decoded.voiceSpeedSteps
    }
}

private struct SettingsData: Codable {
    var isChefMode: Bool
    var voiceSpeedRecipes: Float
    var voiceSpeedIngredients: Float
    var voiceSpeedSteps: Float
}

