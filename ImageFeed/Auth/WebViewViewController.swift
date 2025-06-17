//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Svetlana Varenova on 23.05.2025.
//

@preconcurrency import WebKit
import UIKit

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewViewController: UIViewController {
    
    @IBOutlet weak private var webView: WKWebView!
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBAction private func didTapBackButton(_ sender: Any) {
        delegate?.webViewViewControllerDidCancel(self)
    }
    
    // MARK: - Properties
    weak var delegate: WebViewViewControllerDelegate?
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadAuthRequest()
        webView.navigationDelegate = self
        
        estimatedProgressObservation = webView.observe(\.estimatedProgress, options: [], changeHandler: { [weak self ] _, _ in
            guard let self else { return }
            self.updateProgress()
        })
    }
    
    // MARK: - Private methods
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
    
    private func loadAuthRequest() {
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else {
            print("Ошибка. Не удалось создать URLComponents")
            return
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        guard let url = urlComponents.url else {
            print("Ошибка")
            return
        }
        let request = URLRequest(url: url)
        webView.load(request)
        
        updateProgress()
    }
}

extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
}

enum WebViewConstants {
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}
