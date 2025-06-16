//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Svetlana Varenova on 03.06.2025.
//

import Foundation

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
}

struct ProfileResult: Codable {
    let id: String
    let username: String
    let firstName: String?
    let lastName: String?
    let bio: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}

final class ProfileService {
    static let shared = ProfileService()
    
    private var task: URLSessionTask?
    private(set) var profile: Profile?
    private let urlSession = URLSession.shared
    private let baseURL = URL(string: "https://api.unsplash.com")!
    
    private init() {}
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        task?.cancel()
        
        let request = makeRequest(token: token)
        
        task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self else { return }
            switch result {
            case .success(let profileResult):
                print("[ProfileService]: Успешно получен профиль для пользователя: \(profileResult.username)")
                let profile = ProfileService.convert(result: profileResult)
                self.profile = profile
                completion(.success(profile))
            case .failure(let error):
                print("[ProfileService]: FetchProfileError - \(error.localizedDescription), токен: \(token.prefix(10))…")
                completion(.failure(error))
            }
        }
        task?.resume()
    }
    
    private func makeRequest(token: String) -> URLRequest {
        let url = baseURL.appendingPathComponent("/me")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private static func convert(result: ProfileResult) -> Profile {
        let fullName = [result.firstName, result.lastName]
            .compactMap { $0 }
            .joined(separator: " ")
        return Profile(
            username: result.username,
            name: fullName,
            loginName: "@\(result.username)",
            bio: result.bio
        )
    }
}
