import Foundation

class NetworkService: NetworkServiceProtocol {
    static let shared = NetworkService()
    
    private let baseURL = "https://api.nytimes.com/svc"
    private let apiKey = "znYM3W6EIOqWVxFqTrBruQfGVxdDKxvk" // Replace with your actual API key
    
    private init() {}
    
    // MARK: - Most Popular Articles API
    func fetchMostPopularArticles(type: ArticleType, period: Int = 7, completion: @escaping (Result<[Article], Error>) -> Void) {
        let urlString = "\(baseURL)/mostpopular/v2/\(type.rawValue)/\(period).json?api-key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(MostPopularResponse.self, from: data)
                completion(.success(response.results))
            } catch {
                if let decodingError = error as? DecodingError {
                    print("--- DECODING ERROR (Most Popular) ---")
                    print(decodingError)
                    print("------------------------------------")
                }
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - Article Search API
    func searchArticles(query: String, page: Int = 0, completion: @escaping (Result<[ArticleSearchDoc], Error>) -> Void) {
        var components = URLComponents(string: "\(baseURL)/search/v2/articlesearch.json")
        components?.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "api-key", value: apiKey)
        ]
        
        guard let url = components?.url else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(ArticleSearchResponse.self, from: data)
                completion(.success(response.response.docs))
            } catch {
                if let decodingError = error as? DecodingError {
                    print("--- DECODING ERROR (Article Search) ---")
                    print(decodingError)
                    print("---------------------------------------")
                }
                completion(.failure(error))
            }
        }.resume()
    }
}

// MARK: - Network Errors
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        }
    }
} 
