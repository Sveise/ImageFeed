//
//  WebViewViewControllerSpy.swift
//  ImageFeed
//
//  Created by Svetlana Varenova on 15.07.2025.
//

import Foundation

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var presenter: ImageFeed.WebViewPresenterProtocol?
    
    var loadRequestCalled: Bool = false
    
    func load(request: URLRequest) {
        loadRequestCalled = true
    }
    
    func setProgressValue(_ newValue: Float) {

    }
    
    func setProgressHidden(_ hidden: Bool) {
        
    }
}
