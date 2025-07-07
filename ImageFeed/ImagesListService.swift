//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Svetlana Varenova on 29.06.2025.
//

import Foundation

final class ImagesListService {
    static let shared = ImagesListService()
    
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var isFetching = false
    private let perPage = 10
    
    func fetchPhotosNextPage() {
        guard !isFetching else { return }
        
        isFetching = true
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        let urlString = "https://api.unsplash.com/photos?page=\(nextPage)&per_page=\(perPage)"
        guard let url = URL(string: urlString) else {
            isFetching = false
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Client-ID Xj0Q268920Nm15bC6uQNiDujq72FlJOptNbi6qAofgc", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            defer { self.isFetching = false }
            
            if let error = error {
                print("Network error: \(error)")
                return
            }
            
            guard
                let data = data,
                let photoResults = try? JSONDecoder().decode([PhotoResult].self, from: data)
            else {
                print("Failed to decode photo results")
                return
            }
            
            let newPhotos = photoResults.map { $0.toPhoto() }
            
            DispatchQueue.main.async {
                self.photos.append(contentsOf: newPhotos)
                self.lastLoadedPage = nextPage
                NotificationCenter.default.post(name: Self.didChangeNotification, object: self)
            }
        }.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        let urlString = "https://api.unsplash.com/photos/\(photoId)/like"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        request.setValue("Bearer \(OAuth2TokenStorage.shared.token ?? "")", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                let oldPhoto = self.photos[index]
                let newPhoto = Photo(
                    id: oldPhoto.id,
                    size: oldPhoto.size,
                    createdAt: oldPhoto.createdAt,
                    welcomeDescription: oldPhoto.welcomeDescription,
                    thumbImageURL: oldPhoto.thumbImageURL,
                    largeImageURL: oldPhoto.largeImageURL,
                    isLiked: !oldPhoto.isLiked
                )
                self.photos = self.photos.withReplaced(itemAt: index, newValue: newPhoto)
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Self.didChangeNotification, object: self)
                    completion(.success(()))
                }
            } else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Photo not found"])))
                }
            }
        }.resume()
    }
    
    func reset() {
        photos = []
        lastLoadedPage = nil
    }
}

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

struct PhotoResult: Decodable {
    let id: String
    let createdAt: String?
    let width: Int
    let height: Int
    let description: String?
    let likedByUser: Bool
    let urls: UrlsResult
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width
        case height
        case description
        case likedByUser = "liked_by_user"
        case urls
    }
}

struct UrlsResult: Decodable {
    let thumb: String
    let full: String
}

extension PhotoResult {
    func toPhoto() -> Photo {
        let size = CGSize(width: width, height: height)
        let date = ISO8601DateFormatter().date(from: createdAt ?? "")
        
        return Photo(
            id: id,
            size: size,
            createdAt: date,
            welcomeDescription: description,
            thumbImageURL: urls.thumb,
            largeImageURL: urls.full,
            isLiked: likedByUser
        )
    }
}

extension Array {
    func withReplaced(itemAt index: Int, newValue: Element) -> [Element] {
        var newArray = self
        newArray[index] = newValue
        return newArray
    }
}
