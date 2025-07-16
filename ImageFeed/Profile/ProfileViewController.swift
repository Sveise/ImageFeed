//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Svetlana Varenova on 07.05.2025.
//

import UIKit
import Kingfisher
import SwiftKeychainWrapper

final class ProfileViewController: UIViewController & ProfileViewControllerProtocol {
    private var presenter: ProfilePresenterProtocol!
    
    // MARK: - Properties
    private let imageView = UIImageView()
    private let labelName = UILabel()
    private let labelLogin = UILabel()
    private let labelDescription = UILabel()
    private let buttonExit = UIButton(type: .system)
    private var profileImageServiceObserver: NSObjectProtocol?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        setupProfileImage()
        setupNameLabel()
        setupLoginLabel()
        setupDescriptionLabel()
        setupButtonExit()
        presenter.viewDidLoad()
    }
    
    // MARK: - Private methods
    private func setupProfileImage() {
        let profileImage = UIImage(resource: .photo)
        imageView.image = profileImage
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 35
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .clear
        
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.heightAnchor.constraint(equalToConstant: 70),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ])
    }
    
    private func setupNameLabel() {
        labelName.text = "Екатерина Новикова"
        labelName.textColor = .ypWhite
        labelName.font = .systemFont(ofSize: 23, weight: .bold)
        
        view.addSubview(labelName)
        labelName.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            labelName.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            labelName.leadingAnchor.constraint(equalTo: imageView.leadingAnchor)
        ])
    }
    
    private func setupLoginLabel() {
        labelLogin.text = "@ekaterina_nov"
        labelLogin.textColor = .ypGray
        labelLogin.font = .systemFont(ofSize: 13, weight: .regular)
        
        view.addSubview(labelLogin)
        labelLogin.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            labelLogin.topAnchor.constraint(equalTo: labelName.bottomAnchor, constant: 8),
            labelLogin.leadingAnchor.constraint(equalTo: imageView.leadingAnchor)
        ])
    }
    
    private func setupDescriptionLabel() {
        labelDescription.text = "Hello, world!"
        labelDescription.textColor = .ypWhite
        labelDescription.font = .systemFont(ofSize: 13, weight: .regular)
        
        view.addSubview(labelDescription)
        labelDescription.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            labelDescription.topAnchor.constraint(equalTo: labelLogin.bottomAnchor, constant: 8),
            labelDescription.leadingAnchor.constraint(equalTo: imageView.leadingAnchor)
        ])
    }
    
    private func setupButtonExit() {
        buttonExit.setImage(UIImage(resource: .exit), for: .normal)
        buttonExit.tintColor = .ypRed
        buttonExit.addTarget(self, action: #selector(didTapExitButton), for: .touchUpInside)
        
        view.addSubview(buttonExit)
        buttonExit.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            buttonExit.widthAnchor.constraint(equalToConstant: 44),
            buttonExit.heightAnchor.constraint(equalToConstant: 44),
            buttonExit.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            buttonExit.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 45)
        ])
    }
    
    func updateProfile(name: String, login: String, bio: String) {
        labelName.text = name
        labelLogin.text = login
        labelDescription.text = bio
    }

    func updateAvatar(with url: URL?) {
        imageView.kf.setImage(
            with: url,
            placeholder: UIImage(resource: .photo),
            options: [.transition(.fade(0.2))]
        )
    }

    func showLogoutAlert() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены что хотите выйти?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Да", style: .default) { _ in
            KeychainWrapper.standard.removeObject(forKey: "OAuthToken")
            ProfileLogoutService.shared.logout()
            guard let window = UIApplication.shared.windows.first else { return }
            let splashViewController = SplashViewController()
            window.rootViewController = splashViewController
        })
        alert.addAction(UIAlertAction(title: "Нет", style: .cancel))
        present(alert, animated: true)
    }

    
    @objc func didTapExitButton() {
        presenter.didTapLogoutButton()
    }
}

extension ProfileViewController {
    func configure(with presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
        self.presenter.view = self
    }
}
