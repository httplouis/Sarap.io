import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var settings: AppSettings
    @Environment(\.dismiss) private var dismiss
    
    init() {}
    
    var body: some View {
        List {
            Section {
                Toggle(isOn: $settings.isChefMode) {
                    VStack(alignment: .leading, spacing: 4) {
                        Label("Chef Mode", systemImage: "chef.hat.fill")
                            .font(.headline)
                        Text("Enhanced cooking experience with advanced features")
                            .font(.caption)
                            .foregroundStyle(Theme.subtext)
                    }
                }
                .tint(Theme.olive)
            } header: {
                Text("Cooking Mode")
            } footer: {
                Text("Chef Mode unlocks advanced recipe features and professional cooking tools.")
            }
            
            Section {
                VoiceSpeedRow(
                    title: "Recipe Speed",
                    icon: "book.fill",
                    speed: $settings.voiceSpeedRecipes
                )
                
                VoiceSpeedRow(
                    title: "Ingredients Speed",
                    icon: "list.bullet",
                    speed: $settings.voiceSpeedIngredients
                )
                
                VoiceSpeedRow(
                    title: "Steps Speed",
                    icon: "list.number",
                    speed: $settings.voiceSpeedSteps
                )
            } header: {
                Text("Voice Commands")
            } footer: {
                Text("Adjust the speaking speed for recipe narration. Lower values are slower, higher values are faster.")
            }
            
            Section {
                HStack {
                    Label("App Version", systemImage: "info.circle")
                    Spacer()
                    Text("1.0.0")
                        .foregroundStyle(Theme.subtext)
                }
                
                HStack {
                    Label("Build", systemImage: "hammer.fill")
                    Spacer()
                    Text("1")
                        .foregroundStyle(Theme.subtext)
                }
            } header: {
                Text("About")
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .background(Theme.bg.ignoresSafeArea())
    }
}

private struct VoiceSpeedRow: View {
    let title: String
    let icon: String
    @Binding var speed: Float
    
    private var speedLabel: String {
        if speed < 0.3 {
            return "Very Slow"
        } else if speed < 0.4 {
            return "Slow"
        } else if speed < 0.5 {
            return "Normal"
        } else if speed < 0.6 {
            return "Fast"
        } else {
            return "Very Fast"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(title, systemImage: icon)
                    .font(.headline)
                Spacer()
                Text(speedLabel)
                    .font(.subheadline)
                    .foregroundStyle(Theme.olive)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Theme.oliveSoft))
            }
            
            HStack {
                Text("0.0")
                    .font(.caption)
                    .foregroundStyle(Theme.subtext)
                Slider(value: $speed, in: 0.0...0.75, step: 0.05)
                    .tint(Theme.olive)
                Text("0.75")
                    .font(.caption)
                    .foregroundStyle(Theme.subtext)
            }
            
            Text(String(format: "Current: %.2f", speed))
                .font(.caption2)
                .foregroundStyle(Theme.subtext)
        }
        .padding(.vertical, 4)
    }
}

