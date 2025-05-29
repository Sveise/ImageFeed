//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Svetlana Varenova on 28.05.2025.
//

import UIKit

final class SplashViewController: UIViewController {
  
    
    private let storage = OAuth2TokenStorage()
    private let showAuthenticationScreenSegueIdentifier = "showAuthenticationScreen"
    private let oauth2Service = OAuth2Service.shared
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("token:", storage.token as Any)
        if let token = storage.token {
            print("Есть токен!")
            switchToTabBarController()
        } else {
            print("Отсутствует токен! Требуется авторизация")
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
}

    extension SplashViewController {
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == showAuthenticationScreenSegueIdentifier {
                guard
                    let navigationController = segue.destination as? UINavigationController,
                    let viewController = navigationController.viewControllers[0] as? AuthViewController
                else {
                    assertionFailure("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")
                    return
                }
                viewController.delegate = self
            } else {
                super.prepare(for: segue, sender: sender)
            }
        }
    }

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true) { [weak self] in
            guard let self else { return }
            self.fetchOAuthToken(code)
        }
    }
    
    private func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.switchToTabBarController()
            case .failure:
                // TODO [Sprint 11]
                break
            }
        }
    }
}
