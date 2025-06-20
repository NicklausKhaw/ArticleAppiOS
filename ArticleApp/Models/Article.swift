import Foundation

// MARK: - Article Models
struct Article: Codable {
    let id: Int
    let title: String
    let abstract: String
    let url: String
    let publishedDate: String
    let section: String
    let subsection: String?
    let byline: String?
    let media: [Media]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case abstract
        case url
        case publishedDate = "published_date"
        case section
        case subsection
        case byline
        case media
    }
}

struct Media: Codable {
    let type: String
    let subtype: String?
    let caption: String?
    let copyright: String?
    let mediaMetadata: [MediaMetadata]
    
    enum CodingKeys: String, CodingKey {
        case type
        case subtype
        case caption
        case copyright
        case mediaMetadata = "media-metadata"
    }
}

struct MediaMetadata: Codable {
    let url: String
    let format: String
    let height: Int
    let width: Int
}

// MARK: - API Response Models
struct MostPopularResponse: Codable {
    let status: String
    let copyright: String
    let numResults: Int
    let results: [Article]
    
    enum CodingKeys: String, CodingKey {
        case status
        case copyright
        case numResults = "num_results"
        case results
    }
}

struct ArticleSearchResponse: Codable {
    let status: String
    let copyright: String
    let response: ArticleSearchResponseData
}

struct ArticleSearchResponseData: Codable {
    let docs: [ArticleSearchDoc]
    let meta: Meta?
}

struct ArticleSearchDoc: Codable {
    let webUrl: String
    let snippet: String
    let leadParagraph: String?
    let abstract: String?
    let printPage: String?
    let source: String?
    let multimedia: [Multimedia]?
    let headline: Headline
    let keywords: [Keyword]?
    let pubDate: String
    let documentType: String
    let newsDesk: String?
    let sectionName: String?
    let subsectionName: String?
    let byline: Byline?
    let typeOfMaterial: String?
    let id: String
    let wordCount: Int?
    let uri: String?
    
    enum CodingKeys: String, CodingKey {
        case webUrl = "web_url"
        case snippet
        case leadParagraph = "lead_paragraph"
        case abstract
        case printPage = "print_page"
        case source
        case multimedia
        case headline
        case keywords
        case pubDate = "pub_date"
        case documentType = "document_type"
        case newsDesk = "news_desk"
        case sectionName = "section_name"
        case subsectionName = "subsection_name"
        case byline
        case typeOfMaterial = "type_of_material"
        case id = "_id"
        case wordCount = "word_count"
        case uri
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        webUrl = try container.decode(String.self, forKey: .webUrl)
        snippet = try container.decode(String.self, forKey: .snippet)
        leadParagraph = try container.decodeIfPresent(String.self, forKey: .leadParagraph)
        abstract = try container.decodeIfPresent(String.self, forKey: .abstract)
        printPage = try container.decodeIfPresent(String.self, forKey: .printPage)
        source = try container.decodeIfPresent(String.self, forKey: .source)
        headline = try container.decode(Headline.self, forKey: .headline)
        keywords = try container.decodeIfPresent([Keyword].self, forKey: .keywords)
        pubDate = try container.decode(String.self, forKey: .pubDate)
        documentType = try container.decode(String.self, forKey: .documentType)
        newsDesk = try container.decodeIfPresent(String.self, forKey: .newsDesk)
        sectionName = try container.decodeIfPresent(String.self, forKey: .sectionName)
        subsectionName = try container.decodeIfPresent(String.self, forKey: .subsectionName)
        byline = try container.decodeIfPresent(Byline.self, forKey: .byline)
        typeOfMaterial = try container.decodeIfPresent(String.self, forKey: .typeOfMaterial)
        id = try container.decode(String.self, forKey: .id)
        wordCount = try container.decodeIfPresent(Int.self, forKey: .wordCount)
        uri = try container.decodeIfPresent(String.self, forKey: .uri)

        // Custom decoding for 'multimedia'
        if let multimediaArray = try? container.decode([Multimedia].self, forKey: .multimedia) {
            self.multimedia = multimediaArray
        } else if let singleMultimedia = try? container.decode(Multimedia.self, forKey: .multimedia) {
            self.multimedia = [singleMultimedia]
        } else {
            self.multimedia = nil
        }
    }
}

struct Headline: Codable {
    let main: String
    let kicker: String?
    let contentKicker: String?
    let printHeadline: String?
    let name: String?
    let seo: String?
    let sub: String?
    
    enum CodingKeys: String, CodingKey {
        case main
        case kicker
        case contentKicker = "content_kicker"
        case printHeadline = "print_headline"
        case name
        case seo
        case sub
    }
}

struct Byline: Codable {
    let original: String?
    let person: [Person]?
    let organization: String?
}

struct Person: Codable {
    let firstname: String?
    let middlename: String?
    let lastname: String?
    let qualifier: String?
    let title: String?
    let role: String?
    let organization: String?
    let rank: Int?
}

struct Keyword: Codable {
    let name: String
    let value: String
    let rank: Int
    let major: String?
}

struct Multimedia: Codable {
    let rank: Int
    let subtype: String
    let caption: String?
    let credit: String?
    let type: String
    let url: String
    let height: Int
    let width: Int
    let legacy: Legacy?
    let cropName: String?
    
    enum CodingKeys: String, CodingKey {
        case rank
        case subtype
        case caption
        case credit
        case type
        case url
        case height
        case width
        case legacy
        case cropName = "crop_name"
    }
}

struct Legacy: Codable {
    let xlarge: String?
    let xlargewidth: Int?
    let xlargeheight: Int?
}

struct Meta: Codable {
    let hits: Int
    let offset: Int
    let time: Int
}

// MARK: - Article Type Enum
enum ArticleType: String, CaseIterable {
    case mostViewed = "viewed"
    case mostShared = "shared"
    case mostEmailed = "emailed"
    
    var displayName: String {
        switch self {
        case .mostViewed:
            return "Most Viewed"
        case .mostShared:
            return "Most Shared"
        case .mostEmailed:
            return "Most Emailed"
        }
    }
} 