//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Svetlana Varenova on 04.06.2025.
//

import Foundation

struct UserResult: Codable {
    let profileImage: ProfileImage
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
    
    struct ProfileImage: Codable {
        let small: String
    }
}

final class ProfileImageService {
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    static let shared = ProfileImageService()
    private init() {}
    private(set) var avaterURL: String?
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    private let baseURL = URL(string: "https://api.unsplash.com")!
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        task?.cancel()
        
        let request = makeRequest(username: username)
        
        task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let userResult):
                    let imageURL = userResult.profileImage.small
                    self.avaterURL = imageURL
                    print("[ProfileImageService]: Success - получен URL аватара: \(imageURL)")
                    completion(.success(imageURL))
                    
                    NotificationCenter.default.post(name: ProfileImageService.didChangeNotification, object: self, userInfo: ["URL": imageURL])
                case .failure(let error):
                    print("[ProfileImageService]: FetchImageError - \(error.localizedDescription), параметры: username = \(username)")
                    completion(.failure(error))
                }
            }
        }
        task?.resume()
    }
    
    private func makeRequest(username: String) -> URLRequest {
        let url = baseURL.appendingPathComponent("users/\(username)")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let token = OAuth2TokenStorage().token
        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
}
