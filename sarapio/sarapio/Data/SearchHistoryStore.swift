import Foundation

final class SearchHistoryStore: ObservableObject {
    @Published var recentSearches: [String] = [] {
        didSet {
            saveSearches()
        }
    }
    
    @Published var suggestions: [String] = []
    
    private let searchesKey = "sarapio.recentSearches"
    private let maxRecentSearches = 10
    
    init() {
        loadSearches()
        generateSuggestions()
    }
    
    func addSearch(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty else { return }
        
        recentSearches.removeAll { $0.lowercased() == trimmed }
        recentSearches.insert(trimmed, at: 0)
        
        if recentSearches.count > maxRecentSearches {
            recentSearches = Array(recentSearches.prefix(maxRecentSearches))
        }
    }
    
    func clearHistory() {
        recentSearches.removeAll()
    }
    
    func removeSearch(_ query: String) {
        recentSearches.removeAll { $0 == query }
    }
    
    func getSuggestions(for query: String) -> [String] {
        let lowerQuery = query.lowercased()
        guard !lowerQuery.isEmpty else { return suggestions }
        
        return suggestions.filter { $0.lowercased().contains(lowerQuery) }
    }
    
    private func generateSuggestions() {
        suggestions = [
            "Chicken Adobo",
            "Sinigang",
            "Kare-Kare",
            "Lechon",
            "Pancit",
            "Lumpia",
            "Halo-Halo",
            "Bibingka",
            "Garlic Shrimp",
            "Beef Steak",
            "Pork Sisig",
            "Tinolang Manok",
            "Pinakbet",
            "Bicol Express",
            "Adobong Kangkong",
            "Quick Meals",
            "Vegetarian",
            "Desserts",
            "Breakfast",
            "Dinner Ideas"
        ]
    }
    
    private func saveSearches() {
        UserDefaults.standard.set(recentSearches, forKey: searchesKey)
    }
    
    private func loadSearches() {
        if let saved = UserDefaults.standard.array(forKey: searchesKey) as? [String] {
            recentSearches = saved
        }
    }
}

