//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Svetlana Varenova on 28.05.2025.
//

import UIKit

final class OAuth2TokenStorage {
    private let tokenKey = "OAuth2AccessToken"
    
    var token: String? {
        get {
            UserDefaults.standard.string(forKey: tokenKey)
        } set {
            UserDefaults.standard.set(newValue, forKey: tokenKey)
            print("✅ Токен сохранён: \(String(describing: newValue))")
        }
    }
}
