import Foundation

struct Profile: Codable, Identifiable {
    let id: String
    let firstName: String
    let lastName: String
    let headshot: Headshot
    let jobTitle: String?
    let slug: String?
    let type: String?
    let socialLinks: [SocialLink]?
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    enum CodingKeys: String, CodingKey {
        case id, firstName, lastName, headshot, jobTitle, slug, type, socialLinks
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastName)
        headshot = try container.decode(Headshot.self, forKey: .headshot)
        jobTitle = try container.decodeIfPresent(String.self, forKey: .jobTitle)
        slug = try container.decodeIfPresent(String.self, forKey: .slug)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        socialLinks = try container.decodeIfPresent([SocialLink].self, forKey: .socialLinks) ?? []
    }
}

struct SocialLink: Codable {
    let callToAction: String?
    let type: String?
    let url: String?
}

struct Headshot: Codable {
    let url: String?
    let alt: String?
    let height: Int?
    let width: Int?
    let id: String?
    let mimeType: String?
    let type: String?
    
    var displayURL: String {
        return url ?? "https://via.placeholder.com/100x100?text=No+Image"
    }
}
