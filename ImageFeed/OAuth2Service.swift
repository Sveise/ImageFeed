//
//  Untitled.swift
//  ImageFeed
//
//  Created by Svetlana Varenova on 26.05.2025.
//

import UIKit

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}
    private let tokenStorage = OAuth2TokenStorage()
    private var task: URLSessionTask?
    private var lastCode: String?
    private let session = URLSession.shared
    
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard
            let baseURL = URL(string: "https://unsplash.com"),
            let url = URL(
                string: "/oauth/token"
                + "?client_id=\(Constants.accessKey)"
                + "&&client_secret=\(Constants.secretKey)"
                + "&&redirect_uri=\(Constants.redirectURI)"
                + "&&code=\(code)"
                + "&&grant_type=authorization_code",
                relativeTo: baseURL
            )
        else {
            assertionFailure("Failed to create URL")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    struct OAuthTokenResponseBody: Decodable {
        let accessToken: String
        
        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
        }
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        print("➡️ fetchOAuthToken called with code: \(code)")
        assert(Thread.isMainThread)
        guard lastCode != code else {
            print("Повторный код, запрос не отправляется")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("Ошибка. Запрос не создан")
            completion(.failure(NSError(domain: "OAuth2Service", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid request"])))
            return
        }
        
        UIBlockingProgressHUD.show()
        
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
            }
            if let error {
                print("Ошибка сети: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data else {
                print("Ошибка. Нет данных")
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "OAuth2Service", code: -2, userInfo: [NSLocalizedDescriptionKey: "No data"])))
                }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                self?.tokenStorage.token = response.accessToken
                DispatchQueue.main.async {
                    completion(.success(response.accessToken))
                }
            } catch {
                print("Ошибка декодирования: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        self.task = task
        task.resume()
    }
}
