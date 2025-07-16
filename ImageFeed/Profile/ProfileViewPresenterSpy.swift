//
//  ProfileViewPresenterSpy.swift
//  ImageFeed
//
//  Created by Svetlana Varenova on 16.07.2025.
//

import ImageFeed
import Foundation

final class ProfileViewPresenterSpy: ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol?
    
    var viewDidLoadCalled: Bool = false
    var didTapLogoutButtonCalled: Bool = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didTapLogoutButton() {
        didTapLogoutButtonCalled = true
    }
}
