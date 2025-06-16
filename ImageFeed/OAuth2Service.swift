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
        print("[OAuth2Service]: fetchOAuthToken called with code: \(code)")
        assert(Thread.isMainThread)
        guard lastCode != code else {
            print("[OAuth2Service]: DuplicateRequestError - попытка повторной отправки кода: \(code)")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("[OAuth2Service]: RequestCreationError - не удалось создать URLRequest, код: \(code)")
            completion(.failure(NSError(domain: "OAuth2Service", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid request"])))
            return
        }
        
        UIBlockingProgressHUD.show()
        
        task = session.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
            }
            switch result {
            case .success(let response):
                print("[OAuth2Service]: Success - токен успешно получен")
                self?.tokenStorage.token = response.accessToken
                completion(.success(response.accessToken))
            case .failure(let error):
                print("[OAuth2Service]: TokenRequestError - \(error.localizedDescription), код: \(code)")
                completion(.failure(error))
            }
        }
        task?.resume()
    }
}
