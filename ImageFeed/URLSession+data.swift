//
//  URLSession+data.swift
//  ImageFeed
//
//  Created by Svetlana Varenova on 28.05.2025.
//

import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data, let response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if (200 ..< 300).contains(statusCode) {
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                    print("[dataTask]: NetworkError.httpStatusCode - код ошибки \(statusCode), URL: \(request.url?.absoluteString ?? "")")
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error {
                print("[dataTask]: NetworkError.urlRequestError - \(error.localizedDescription), URL: \(request.url?.absoluteString ?? "")")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
            } else {
                print("[dataTask]: NetworkError.urlSessionError - неизвестная ошибка сессии, URL: \(request.url?.absoluteString ?? "")")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
            }
        })
        
        return task
    }
    
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        
        let task = data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let decodedObject = try decoder.decode(T.self, from: data)
                    completion(.success(decodedObject))
                } catch {
                    let dataString = String(data: data, encoding: .utf8) ?? "некорректные данные"
                    print("[objectTask]: Ошибка декодирования - \(error.localizedDescription), Тип: \(T.self), Данные: \(dataString), URL: \(request.url?.absoluteString ?? "")")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("[objectTask]: Ошибка сети - \(error.localizedDescription), Тип: \(T.self), URL: \(request.url?.absoluteString ?? "")")
                completion(.failure(error))
            }
        }
        return task
    }
}
