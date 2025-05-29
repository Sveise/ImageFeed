//
//  Constants.swift
//  ImageFeed
//
//  Created by Svetlana Varenova on 22.05.2025.
//
import Foundation

enum Constants {
    static let accessKey = "Xj0Q268920Nm15bC6uQNiDujq72FlJOptNbi6qAofgc"
    static let secretKey = "uz99zc3YcpGPAWG5w339v4F9j8ctIpUIq-HPyjH0j-s"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static var defaultBaseURL: URL {
        guard let url = URL(string: "https://api.unsplash.com") else {
            fatalError("Failed to create base URL")
        }
        return url
    }
}
