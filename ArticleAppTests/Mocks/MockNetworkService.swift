import Foundation
@testable import ArticleApp

class MockNetworkService: NetworkServiceProtocol {

    var mostPopularResult: Result<[Article], Error>?
    var searchResult: Result<[ArticleSearchDoc], Error>?

    func fetchMostPopularArticles(type: ArticleType, period: Int, completion: @escaping (Result<[Article], Error>) -> Void) {
        if let result = mostPopularResult {
            completion(result)
        }
    }

    func searchArticles(query: String, page: Int, completion: @escaping (Result<[ArticleSearchDoc], Error>) -> Void) {
        if let result = searchResult {
            completion(result)
        }
    }
} 