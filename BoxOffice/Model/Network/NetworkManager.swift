//
//  Network.swift
//  BoxOffice
//
//  Created by 임채윤 on 2023/01/03.
//

import Foundation

class NetworkManager {
    func getFilmData(completion: @escaping (Result<FilmDetails, Error>) -> Void) {
        self.getData(url: "https://www.kobis.or.kr/kobisopenapi/webservice/rest/movie/searchMovieInfo.json?key=635cb0b1404820f91c8a45fcdf831615&movieCd=20225061", completion: completion)
    }
}

extension NetworkManager {
    func getData<T: Decodable>(url: String, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: url) else {
            return
        }
        
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                return
            }
            
            guard (200...299).contains(response.statusCode) else {
                return
            }
            
            if let data = data {
                do {
                    let data = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(data))
                } catch {
                    completion(.failure(error))
                }
            }
            
            
        }
        task.resume()
    }
}