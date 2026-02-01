import Foundation

struct JournalEntry: Codable, Identifiable {
    let id: String
    let title: String
    let date: Date
    let question1: String
    let question2: String
    let tags: [String]
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, title, date, tags
        case question1 = "question_1"
        case question2 = "question_2"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct EntryListItem: Codable, Identifiable {
    let id: String
    let title: String
    let date: Date
    let tags: [String]
    let preview: String
}

struct EntryCreateRequest: Codable {
    let question1: String
    let question2: String

    enum CodingKeys: String, CodingKey {
        case question1 = "question_1"
        case question2 = "question_2"
    }
}

struct TagsUpdateRequest: Codable {
    let tags: [String]
}

struct Tag: Codable, Identifiable {
    let id: String
    let name: String
    let color: String
}
