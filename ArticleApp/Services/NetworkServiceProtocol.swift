import Foundation

protocol NetworkServiceProtocol {
    func fetchMostPopularArticles(type: ArticleType, period: Int, completion: @escaping (Result<[Article], Error>) -> Void)
    func searchArticles(query: String, page: Int, completion: @escaping (Result<[ArticleSearchDoc], Error>) -> Void)
} 