import Foundation

@MainActor
class OpenAIService: ObservableObject {
    static let shared = OpenAIService()
    
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    private init() {
        // Load API key from plist file (not tracked in git)
        if let path = Bundle.main.path(forResource: "APIKeys", ofType: "plist"),
           let plist = NSDictionary(contentsOfFile: path),
           let key = plist["OpenAIAPIKey"] as? String {
            self.apiKey = key.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            // Fallback: try environment variable
            if let envKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] {
                self.apiKey = envKey.trimmingCharacters(in: .whitespacesAndNewlines)
            } else {
                // No API key found - app will show error when trying to use AI
                self.apiKey = ""
                print("[OpenAI] WARNING: No API key found. Please add APIKeys.plist or set OPENAI_API_KEY environment variable.")
            }
        }
        
        // Verify API key format
        if !apiKey.isEmpty && !apiKey.hasPrefix("sk-") {
            print("[OpenAI] WARNING: API key doesn't start with 'sk-'")
        }
    }
    
    func searchRecipes(ingredients: [String], query: String? = nil) async throws -> String {
        let ingredientsList = ingredients.joined(separator: ", ")
        let userQuery = query ?? "I have these ingredients: \(ingredientsList)"
        
        let systemPrompt = """
        You are a helpful Filipino recipe assistant for the Sarap.io app. Your role is to:
        1. Help users find recipes based on their available ingredients
        2. Suggest Filipino dishes they can make
        3. Provide cooking tips and variations
        4. Answer questions about Filipino cuisine
        
        When suggesting recipes, be specific about:
        - Recipe names (use common Filipino names like Adobo, Sinigang, Kare-Kare, etc.)
        - Key ingredients needed
        - Cooking methods
        - Estimated cooking time
        
        Keep responses friendly, helpful, and concise (2-3 sentences max). If the user has specific ingredients, prioritize recipes that use those ingredients. Always mention if a recipe is available in the app.
        """
        
        let messages: [[String: Any]] = [
            ["role": "system", "content": systemPrompt],
            ["role": "user", "content": userQuery]
        ]
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": messages,
            "temperature": 0.7,
            "max_tokens": 500
        ]
        
        guard let url = URL(string: baseURL) else {
            throw AIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Ensure API key is properly formatted
        let authHeader = "Bearer \(apiKey.trimmingCharacters(in: .whitespacesAndNewlines))"
        request.setValue(authHeader, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Debug: Print API key (first 10 chars only for security)
        print("[OpenAI] Using API key: \(String(apiKey.prefix(10)))...")
        print("[OpenAI] Auth header length: \(authHeader.count)")
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AIError.apiError("Invalid response from server")
            }
            
            guard httpResponse.statusCode == 200 else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                print("[OpenAI] Error \(httpResponse.statusCode): \(errorMessage)")
                
                // Parse OpenAI error response
                if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let error = errorJson["error"] as? [String: Any],
                   let message = error["message"] as? String {
                    print("[OpenAI] Parsed error: \(message)")
                    
                    // Handle specific errors
                    if message.contains("authentication") || message.contains("bearer") || message.contains("api key") {
                        throw AIError.apiError("Authentication failed. Please check the API key.")
                    } else if httpResponse.statusCode == 429 {
                        throw AIError.apiError("Rate limit exceeded. Please wait a moment and try again.")
                    } else {
                        throw AIError.apiError(message)
                    }
                }
                
                // Handle rate limiting (429) with a user-friendly message
                if httpResponse.statusCode == 429 {
                    throw AIError.apiError("Rate limit exceeded. Please wait a moment and try again.")
                }
                
                throw AIError.apiError("API error: \(httpResponse.statusCode) - \(errorMessage)")
            }
            
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let firstChoice = choices.first,
                  let message = firstChoice["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                print("[OpenAI] Invalid response structure")
                throw AIError.invalidResponse
            }
            
            return content
        } catch let error as AIError {
            throw error
        } catch {
            print("[OpenAI] Network error: \(error.localizedDescription)")
            throw AIError.networkError
        }
    }
    
    func chat(message: String, conversationHistory: [ChatMessage] = []) async throws -> String {
        let systemPrompt = """
        You are a helpful Filipino recipe assistant for the Sarap.io app. Help users find recipes, answer cooking questions, and provide tips about Filipino cuisine. Be friendly, concise, and helpful. Keep responses to 2-3 sentences when possible. If users ask about recipes, mention specific Filipino dish names like Adobo, Sinigang, Kare-Kare, Lechon Kawali, etc.
        """
        
        var messages: [[String: Any]] = [
            ["role": "system", "content": systemPrompt]
        ]
        
        // Add conversation history
        for chatMessage in conversationHistory {
            messages.append([
                "role": chatMessage.role.rawValue,
                "content": chatMessage.content
            ])
        }
        
        // Add current message
        messages.append([
            "role": "user",
            "content": message
        ])
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": messages,
            "temperature": 0.7,
            "max_tokens": 500
        ]
        
        guard let url = URL(string: baseURL) else {
            throw AIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Ensure API key is properly formatted
        let authHeader = "Bearer \(apiKey.trimmingCharacters(in: .whitespacesAndNewlines))"
        request.setValue(authHeader, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Debug: Print API key (first 10 chars only for security)
        print("[OpenAI] Using API key: \(String(apiKey.prefix(10)))...")
        print("[OpenAI] Auth header length: \(authHeader.count)")
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AIError.apiError("Invalid response from server")
            }
            
            guard httpResponse.statusCode == 200 else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                print("[OpenAI] Error \(httpResponse.statusCode): \(errorMessage)")
                
                // Parse OpenAI error response
                if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let error = errorJson["error"] as? [String: Any],
                   let message = error["message"] as? String {
                    print("[OpenAI] Parsed error: \(message)")
                    
                    // Handle specific errors
                    if message.contains("authentication") || message.contains("bearer") || message.contains("api key") {
                        throw AIError.apiError("Authentication failed. Please check the API key.")
                    } else if httpResponse.statusCode == 429 {
                        throw AIError.apiError("Rate limit exceeded. Please wait a moment and try again.")
                    } else {
                        throw AIError.apiError(message)
                    }
                }
                
                // Handle rate limiting (429) with a user-friendly message
                if httpResponse.statusCode == 429 {
                    throw AIError.apiError("Rate limit exceeded. Please wait a moment and try again.")
                }
                
                throw AIError.apiError("API error: \(httpResponse.statusCode) - \(errorMessage)")
            }
            
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let firstChoice = choices.first,
                  let message = firstChoice["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                print("[OpenAI] Invalid response structure")
                throw AIError.invalidResponse
            }
            
            return content
        } catch let error as AIError {
            throw error
        } catch {
            print("[OpenAI] Network error: \(error.localizedDescription)")
            throw AIError.networkError
        }
    }
}

enum AIError: LocalizedError {
    case invalidURL
    case apiError(String)
    case invalidResponse
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .apiError(let message):
            return message
        case .invalidResponse:
            return "Invalid response from AI service"
        case .networkError:
            return "Network connection error. Please check your internet connection."
        }
    }
}

struct ChatMessage: Identifiable, Codable {
    let id: UUID
    let role: MessageRole
    let content: String
    let timestamp: Date
    
    init(id: UUID = UUID(), role: MessageRole, content: String, timestamp: Date = Date()) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
    }
}

enum MessageRole: String, Codable {
    case user
    case assistant
    case system
}

