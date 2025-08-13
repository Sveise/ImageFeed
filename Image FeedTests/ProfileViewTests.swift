//
//  ProfileViewTests.swift
//  ImageFeed
//
//  Created by Svetlana Varenova on 16.07.2025.
//

@testable import ImageFeed
import XCTest


final class ProfileViewTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        //given
        let viewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        viewController.configure(with: presenter)
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsUpdateProfileDetails() {
        //given
        let viewController = ProfileViewControllerSpy()
        let profileServiceMock = ProfileServiceMock()
        let testProfile = Profile(username: "test", name: "Test Name", loginName: "@test", bio: "Test Bio")
        profileServiceMock.setProfile(testProfile)
        let presenter = ProfileViewPresenter(profileService: profileServiceMock)
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        presenter.viewDidLoad()
        
        //then
        XCTAssertTrue(viewController.updateProfileDetailsCalled)
        XCTAssertEqual(viewController.receivedName, "Test Name")
        XCTAssertEqual(viewController.receivedLogin, "@test")
        XCTAssertEqual(viewController.receivedBio, "Test Bio")
    }
    
    func testPresenterCallsShowLogoutAlert() {
        //given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfileViewPresenter()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        presenter.didTapLogoutButton()
        
        //then
        XCTAssertTrue(viewController.showLogoutAlertCalled)
    }
    
    func testViewControllerCallsDidTapLogoutButton() {
        //given
        let viewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        viewController.configure(with: presenter)
        
        //when
        viewController.didTapExitButton()
        
        //then
        XCTAssertTrue(presenter.didTapLogoutButtonCalled)
    }
}
