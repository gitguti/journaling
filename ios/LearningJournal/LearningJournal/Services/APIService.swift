import Foundation

class APIService {
    static let shared = APIService()

    // Change this to your deployed backend URL
    private let baseURL = "http://localhost:8000"

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
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

        let body = EntryCreateRequest(question1: question1, question2: question2)
        request.httpBody = try encoder.encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 201 else {
            throw APIError.serverError
        }
        return try decoder.decode(JournalEntry.self, from: data)
    }

    func listEntries() async throws -> [EntryListItem] {
        let url = URL(string: "\(baseURL)/entries")!
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw APIError.serverError
        }
        return try decoder.decode([EntryListItem].self, from: data)
    }

    func getEntry(id: String) async throws -> JournalEntry {
        let url = URL(string: "\(baseURL)/entries/\(id)")!
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw APIError.serverError
        }
        return try decoder.decode(JournalEntry.self, from: data)
    }

    func updateTags(entryId: String, tags: [String]) async throws -> JournalEntry {
        let url = URL(string: "\(baseURL)/entries/\(entryId)/tags")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = TagsUpdateRequest(tags: tags)
        request.httpBody = try encoder.encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw APIError.serverError
        }
        return try decoder.decode(JournalEntry.self, from: data)
    }

    // MARK: - Tags

    func listTags() async throws -> [Tag] {
        let url = URL(string: "\(baseURL)/tags")!
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw APIError.serverError
        }
        return try decoder.decode([Tag].self, from: data)
    }
}

enum APIError: LocalizedError {
    case serverError

    var errorDescription: String? {
        switch self {
        case .serverError:
            return "Server error. Please try again."
        }
    }
}
