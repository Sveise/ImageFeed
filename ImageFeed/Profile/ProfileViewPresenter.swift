//
//  ProfileViewPresenter.swift
//  ImageFeed
//
//  Created by Svetlana Varenova on 16.07.2025.
//

import UIKit

public protocol ProfileViewControllerProtocol: AnyObject {
    func updateProfile(name: String, login: String, bio: String)
    func updateAvatar(with url: URL?)
    func showLogoutAlert()
}

public protocol ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func didTapLogoutButton()
}

final class ProfileViewPresenter: ProfilePresenterProtocol {
    
    weak var view: ProfileViewControllerProtocol?
    private let profileService: ProfileServiceProtocol
    private let profileImageService: ProfileImageService
    private var profileObserver: NSObjectProtocol?

    init(profileService: ProfileServiceProtocol = ProfileService.shared as ProfileServiceProtocol, profileImageService: ProfileImageService = .shared) {
        self.profileService = profileService
        self.profileImageService = profileImageService
    }
    
    func viewDidLoad() {
        if let profile = profileService.profile {
            view?.updateProfile(
                name: profile.name,
                login: profile.loginName,
                bio: profile.bio ?? ""
            )
        }

        view?.updateAvatar(with: avatarURL())

        profileObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.view?.updateAvatar(with: self?.avatarURL())
        }
    }

    private func avatarURL() -> URL? {
        guard let urlString = ProfileImageService.shared.avatarURL else { return nil }
        return URL(string: urlString)
    }

    deinit {
        if let observer = profileObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    func didTapLogoutButton() {
        view?.showLogoutAlert()
    }
}

