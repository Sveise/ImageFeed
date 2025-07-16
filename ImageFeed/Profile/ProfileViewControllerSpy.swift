//
//  ProfileViewControllerSpy.swift
//  ImageFeed
//
//  Created by Svetlana Varenova on 16.07.2025.
//

import ImageFeed
import Foundation

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    
    var presenter: ProfilePresenterProtocol?
    
    var updateProfileDetailsCalled: Bool = false
    var updateAvatarCalled: Bool = false
    var showLogoutAlertCalled: Bool = false
    var logoutCalled: Bool = false
    var receivedName: String?
    var receivedLogin: String?
    var receivedBio: String?
    var receivedAvatarURL: URL?
    
    func updateProfile(name: String, login: String, bio: String) {
        updateProfileDetailsCalled = true
        receivedName = name
        receivedLogin = login
        receivedBio = bio
    }
    
    func updateAvatar(with url: URL?) {
        updateAvatarCalled = true
        receivedAvatarURL = url
    }
    
    func showLogoutAlert() {
        showLogoutAlertCalled = true
    }
    
    func logout() {
        logoutCalled = true
    }
} 
