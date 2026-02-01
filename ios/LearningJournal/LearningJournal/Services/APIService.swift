import Foundation

class APIService {
    static let shared = APIService()

    // Change this to your deployed backend URL
    // Use ngrok for mobile testing: ngrok http 8000
    private let baseURL = "https://brachial-unaccordant-venus.ngrok-free.dev"

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        // Custom date decoding to handle Python's microsecond precision
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        d.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            // Try with fractional seconds first (Python format)
            if let date = formatter.date(from: dateString) {
                return date
            }
            
            // Fallback to standard ISO8601
            formatter.formatOptions = [.withInternetDateTime]
            if let date = formatter.date(from: dateString) {
                return date
            }
            
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
        }
        return d
    }()

    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }()

    // MARK: - Entries

    func createEntry(question1: String, question2: String) async throws -> JournalEntry {
        let url = URL(string: "\(baseURL)/entries")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        // Bypass ngrok browser warning
        request.setValue("1", forHTTPHeaderField: "ngrok-skip-browser-warning")
        request.setValue("iOS App", forHTTPHeaderField: "User-Agent")

        let body = EntryCreateRequest(question1: question1, question2: question2)
        request.httpBody = try encoder.encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        
        #if DEBUG
        if let responseString = String(data: data, encoding: .utf8) {
            print("CREATE Response: \(responseString)")
        }
        #endif
        
        guard let http = response as? HTTPURLResponse, http.statusCode == 201 else {
            throw APIError.serverError
        }
        
        do {
            return try decoder.decode(JournalEntry.self, from: data)
        } catch {
            print("Decoding error: \(error)")
            throw APIError.decodingError(error)
        }
    }

    func listEntries() async throws -> [EntryListItem] {
        let url = URL(string: "\(baseURL)/entries")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        // Bypass ngrok browser warning
        request.setValue("1", forHTTPHeaderField: "ngrok-skip-browser-warning")
        request.setValue("iOS App", forHTTPHeaderField: "User-Agent")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Debug: Print response for troubleshooting
        #if DEBUG
        if let responseString = String(data: data, encoding: .utf8) {
            print("Response from /entries: \(responseString)")
        }
        print("Status code: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
        #endif
        
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw APIError.serverError
        }
        
        do {
            return try decoder.decode([EntryListItem].self, from: data)
        } catch {
            print("Decoding error: \(error)")
            throw APIError.decodingError(error)
        }
    }

    func getEntry(id: String) async throws -> JournalEntry {
        let url = URL(string: "\(baseURL)/entries/\(id)")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        // Bypass ngrok browser warning
        request.setValue("1", forHTTPHeaderField: "ngrok-skip-browser-warning")
        request.setValue("iOS App", forHTTPHeaderField: "User-Agent")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw APIError.serverError
        }
        
        do {
            return try decoder.decode(JournalEntry.self, from: data)
        } catch {
            print("Decoding error: \(error)")
            throw APIError.decodingError(error)
        }
    }

    func updateTags(entryId: String, tags: [String]) async throws -> JournalEntry {
        let url = URL(string: "\(baseURL)/entries/\(entryId)/tags")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        // Bypass ngrok browser warning
        request.setValue("1", forHTTPHeaderField: "ngrok-skip-browser-warning")
        request.setValue("iOS App", forHTTPHeaderField: "User-Agent")

        let body = TagsUpdateRequest(tags: tags)
        request.httpBody = try encoder.encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw APIError.serverError
        }
        
        do {
            return try decoder.decode(JournalEntry.self, from: data)
        } catch {
            print("Decoding error: \(error)")
            throw APIError.decodingError(error)
        }
    }

    // MARK: - Tags

    func listTags() async throws -> [Tag] {
        let url = URL(string: "\(baseURL)/tags")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        // Bypass ngrok browser warning
        request.setValue("1", forHTTPHeaderField: "ngrok-skip-browser-warning")
        request.setValue("iOS App", forHTTPHeaderField: "User-Agent")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw APIError.serverError
        }
        
        do {
            return try decoder.decode([Tag].self, from: data)
        } catch {
            print("Decoding error: \(error)")
            throw APIError.decodingError(error)
        }
    }
}

enum APIError: LocalizedError {
    case serverError
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .serverError:
            return "Server error. Please try again."
        case .decodingError(let error):
            return "Data format error: \(error.localizedDescription)"
        }
    }
}
