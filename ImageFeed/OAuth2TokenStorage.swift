//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Svetlana Varenova on 28.05.2025.
//

import UIKit
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    
    private let tokenKey = "OAuth2AccessToken"
    
    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: tokenKey)
        } set {
            if let newValue = newValue {
                KeychainWrapper.standard.set(newValue, forKey: tokenKey)
                print("Токен сохранён в Keychain")
            } else {
                KeychainWrapper.standard.removeObject(forKey: tokenKey)
                print("Токен удалён из Keychain")
            }           
        }
    }
}
