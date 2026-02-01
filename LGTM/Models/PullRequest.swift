import Foundation

nonisolated struct PullRequest: Codable, Sendable {
    let id: Int
    let number: Int
    let title: String
    let repository: String
    let author: String
    let url: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case number
        case title
        case repository
        case author
        case url
        case updatedAt = "updated_at"
    }
}

// GitHub API Response Models
nonisolated struct GitHubSearchResponse: Codable, Sendable {
    let items: [GitHubIssue]
}

nonisolated struct GitHubIssue: Codable, Sendable {
    let id: Int
    let number: Int
    let title: String
    let htmlUrl: String
    let updatedAt: String
    let user: GitHubUser
    let repositoryUrl: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case number
        case title
        case htmlUrl = "html_url"
        case updatedAt = "updated_at"
        case user
        case repositoryUrl = "repository_url"
    }
}

nonisolated struct GitHubUser: Codable, Sendable {
    let login: String
}

nonisolated struct GitHubUserResponse: Codable, Sendable {
    let login: String
}

