//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Svetlana Varenova on 28.05.2025.
//

import UIKit
import SwiftKeychainWrapper
import Network

final class SplashViewController: UIViewController {
    
    // MARK: - Properties
    private let tokenKey = "OAuthToken"
    private let showAuthenticationScreenSegueIdentifier = "showAuthenticationScreen"
    private let oauth2Service = OAuth2Service.shared
    private var isFetchingToken = false
    private var hasSwitched = false
    private var hasAlreadyPresentedAuth = false
    private let profileService = ProfileService.shared
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "auth_screen_logo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypBlack
        setupLogo()
        
        DispatchQueue.main.async {
            [weak self] in
            self?.handleAuthorizationFlow()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    // MARK: - Private methods
    private func handleAuthorizationFlow() {
        guard !isFetchingToken, !hasSwitched else { return }
        
        if let token = KeychainWrapper.standard.string(forKey: tokenKey) {
            print("Есть токен:\(token)")
            fetchProfile(token: token)
        } else {
            presentAuthIfNeeded()
        }
    }
    
    private func presentAuthIfNeeded() {
        guard !hasAlreadyPresentedAuth, presentedViewController == nil else { return }
        hasAlreadyPresentedAuth = true
        
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let authVC = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
            assertionFailure("Не удалось загрузить AuthViewController из storyboard")
            return
        }
        
        authVC.delegate = self
        let navigationController = UINavigationController(rootViewController: authVC)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true) {
            self.checkInternetConnection { isConnected in
                guard !isConnected,
                      let navController = self.presentedViewController as? UINavigationController,
                      let authVC = navController.viewControllers.first as? AuthViewController
                else { return }
                authVC.showAuthErrorAlert()
            }
        }
    }
    
    private func checkInternetConnection(completion: @escaping (Bool) -> Void) {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "NetworkMonitor")
        
        monitor.pathUpdateHandler = { path in
            monitor.cancel()
            DispatchQueue.main.async {
                completion(path.status == .satisfied)
            }
        }
        
        monitor.start(queue: queue)
    }
    
    
    private func setupLogo() {
        view.addSubview(logoImageView)
        
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    private func switchToTabBarController() {
        guard !hasSwitched else { return }
        hasSwitched = true
        
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
}

// MARK: - AuthViewControllerDelegate

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        vc.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            self.fetchOAuthToken(code)
        }
    }
    
    private func fetchOAuthToken(_ code: String) {
        guard !isFetchingToken else { return }
        self.isFetchingToken = true
        UIBlockingProgressHUD.show()
        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            guard let self else { return }
            isFetchingToken = false
            switch result {
            case .success(let token):
                KeychainWrapper.standard.set(token, forKey: self.tokenKey)
                self.fetchProfile(token: token)
            case .failure(let error):
                print("[SplashViewController]: Ошибка получения токена - \(error.localizedDescription)")
                if let navController = self.presentedViewController as? UINavigationController,
                   let authVC = navController.viewControllers.first as? AuthViewController {
                    authVC.showAuthErrorAlert()
                }
                self.presentAuthIfNeeded()
            }
        }
    }
    
    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success(let profile):
                    print("Профиль получен: \(profile)")
                    ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { result in
                        DispatchQueue.main.async {
                            UIBlockingProgressHUD.dismiss()
                            
                            switch result {
                            case .success(let url):
                                print("URL аватара: \(url)")
                            case .failure(let error):
                                print("Ошибка загрузки аватара: \(error.localizedDescription)")
                            }
                            self.switchToTabBarController()
                        }
                    }
                case .failure:
                    UIBlockingProgressHUD.dismiss()
                    print("Не удалось получить профиль: \(result)")
                }
            }
        }
    }
}
