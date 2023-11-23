//
//  FlickrServer.swift
//  HelloReactorKit
//
//  Created by 김건우 on 11/23/23.
//

import Foundation

import RxCocoa
import RxSwift

enum MyError: Error {
    case error
}

class FlickrService {
    // MARK: - Singleton
    static let shared = FlickrService()
    private init() { }
    
    let baseUrl = "https://api.flickr.com/services/rest/"
    
    func requestQuery(_ query: String) -> Observable<[Photo]> {
        guard let urlRequest = searchUrl(query) else { return Observable.just([]) }
        
        return URLSession.shared.rx.data(request: urlRequest)
            .map { [weak self] data in
                guard let results = self?.decode(of: Welcome.self, from: data) else {
                    return []
                }
                return results.photos.photo
            }
            .catch { _ in Observable.just([]) }
    }
    
    private func searchUrl(_ query: String) -> URLRequest? {
        let parameters = [
            "method": "flickr.photos.search",
            "api_key": "f5745654ff073591e188df7032cc8688",
            "text": "\(query)",
            "format": "json",
            "per_page": "100",
            "nojsoncallback": "1"
        ]
        
        guard var urlComponents = URLComponents(string: baseUrl) else { return nil }
        urlComponents.queryItems = parameters.map { URLQueryItem(name: $0, value: $1) }
        urlComponents.queryItems?.append(URLQueryItem(name: "text", value: query))
        
        guard let url = urlComponents.url else { return nil }
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return urlRequest
    }
        
    private func decode<T: Decodable>(of type: T.Type, from data: Data) -> T? {
        let decoder = JSONDecoder()
        return try? decoder.decode(type, from: data)
    }
}
