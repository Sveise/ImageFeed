//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Svetlana Varenova on 23.05.2025.
//

import UIKit
import ProgressHUD

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController {
    // MARK: - Properties
    private let showWebViewSegueID = "ShowWebView"
    weak var delegate: AuthViewControllerDelegate?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueID {
            guard let webViewViewController = segue.destination as? WebViewViewController
            else {
                assertionFailure("Failed to prepare for \(showWebViewSegueID)")
                return
            }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - Private methods
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(resource: .chevronBackward)
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(resource: .chevronBackward)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(resource: .ypBlack)
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
   
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        print("Получен code: \(code)")
        vc.dismiss(animated: true) {
            UIBlockingProgressHUD.show()
                    self.delegate?.authViewController(self, didAuthenticateWithCode: code)
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        UIBlockingProgressHUD.dismiss()
        vc.dismiss(animated: true)
    }
    
}
