//  APIManager.swift
//  Posts
//
//  Created  on 11/01/20.
//
//

import Foundation


let endPoint: String = "https://hn.algolia.com/api/v1/search_by_date?tags=story&page="
enum APIError: Error {
    case invalidUrl
    case invalidResponse
    case endPointError
}

class APIManager {
    static let shared =  APIManager()
    private init() {}
    
    
    func fetchPostsRequest(pageNumber: Int = 1,  completion :  @escaping ( (Result<[Post]?, APIError>) -> Void)) {
        
        let urlString: String =  endPoint + "\(pageNumber)"
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidUrl))
            return
        }
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let _ = error  {
                completion(.failure(.endPointError))
                return
            }
            
            guard let response =  response as? HTTPURLResponse , 200...299 ~= response.statusCode, let data = data else {
                completion(.failure(.invalidResponse))
                return
            }
            
            
            
            do {
                 let json =  try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
                if let jsonObject = json {
                   let posts =  parse(json: jsonObject )
                   completion(.success(posts))
                   return
                } else {
                    completion(.failure(.invalidResponse))
                }
            
            } catch {
                completion(.failure(.invalidResponse))
            }
                    
        }.resume()
                    
    }

}


fileprivate func parse(json:[String: Any] ) -> [Post] {
    var posts: [Post] = []
    if let hits = json["hits"] as? [[String: Any]] {
        for postDict in hits {
            let post =  Post(dict: postDict)
            posts.append(post)
        }
    }
    return posts
}
