import Foundation
import UserNotifications
import Combine

@MainActor
final class RecipeTimerManager: ObservableObject {
    @Published var activeTimers: [RecipeTimer] = []
    
    struct RecipeTimer: Identifiable {
        let id: UUID
        let recipeId: UUID?
        let stepOrder: Int?
        let name: String
        let duration: TimeInterval
        var startTime: Date
        var isPaused: Bool = false
        var pausedTime: TimeInterval = 0
        
        var remainingTime: TimeInterval {
            if isPaused {
                return duration - pausedTime
            }
            let elapsed = Date().timeIntervalSince(startTime) + pausedTime
            return max(0, duration - elapsed)
        }
        
        var isFinished: Bool {
            remainingTime <= 0
        }
        
        var formattedTime: String {
            let totalSeconds = Int(remainingTime)
            let minutes = totalSeconds / 60
            let seconds = totalSeconds % 60
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    func startTimer(name: String, duration: TimeInterval, recipeId: UUID? = nil, stepOrder: Int? = nil) -> UUID {
        let timerId = UUID()
        let timer = RecipeTimer(
            id: timerId,
            recipeId: recipeId,
            stepOrder: stepOrder,
            name: name,
            duration: duration,
            startTime: Date()
        )
        activeTimers.append(timer)
        scheduleNotification(for: timer)
        return timerId
    }
    
    func pauseTimer(_ timerId: UUID) {
        guard let index = activeTimers.firstIndex(where: { $0.id == timerId }) else { return }
        if !activeTimers[index].isPaused {
            let elapsed = Date().timeIntervalSince(activeTimers[index].startTime)
            activeTimers[index].pausedTime = elapsed
            activeTimers[index].isPaused = true
        }
    }
    
    func resumeTimer(_ timerId: UUID) {
        guard let index = activeTimers.firstIndex(where: { $0.id == timerId }) else { return }
        if activeTimers[index].isPaused {
            activeTimers[index].startTime = Date()
            activeTimers[index].isPaused = false
        }
    }
    
    func cancelTimer(_ timerId: UUID) {
        activeTimers.removeAll { $0.id == timerId }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [timerId.uuidString])
    }
    
    func cancelAllTimers() {
        let ids = activeTimers.map { $0.id.uuidString }
        activeTimers.removeAll()
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }
    
    private func scheduleNotification(for timer: RecipeTimer) {
        let content = UNMutableNotificationContent()
        content.title = "Timer Finished"
        content.body = "\(timer.name) is ready!"
        content.sound = .default
        content.categoryIdentifier = "TIMER"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timer.duration, repeats: false)
        let request = UNNotificationRequest(identifier: timer.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                print("Notification permission granted")
            }
        }
    }
    
    init() {
        requestNotificationPermission()
    }
}

