//
//  Image_FeedUITests.swift
//  Image FeedUITests
//
//  Created by Svetlana Varenova on 16.07.2025.
//

import XCTest

class Image_FeedUITests: XCTestCase {
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["testMode"]
        app.launch()
    }
    
    func testAuth() throws {
        app.buttons["Authenticate"].tap()
        let webView = app.webViews.element(boundBy: 0)
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 10))
        loginTextField.tap()
        loginTextField.typeText("логин")
        webView.swipeUp()
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        passwordTextField.tap()
        UIPasteboard.general.string = "пароль"
        passwordTextField.doubleTap()
        if app.menuItems["Paste"].exists {
            app.menuItems["Paste"].tap()
        }
        let allowPasteAlert = app.alerts.firstMatch
        if allowPasteAlert.waitForExistence(timeout: 2) {
            allowPasteAlert.buttons["Allow Paste"].tap()
        }
        let loginButton = webView.buttons["Login"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5))
        if !loginButton.isHittable {
            webView.swipeUp()
        }
        loginButton.tap()
        let tablesQuery = app.tables
        let tableView = tablesQuery.firstMatch
        XCTAssertTrue(tableView.waitForExistence(timeout: 10))
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    
    func testFeed() throws {
        let tablesQuery = app.tables
        let tableView = tablesQuery.firstMatch
        XCTAssertTrue(tableView.waitForExistence(timeout: 10))
        sleep(3)
        let firstCell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10))
        let likeButton = firstCell.buttons["likeButton"]
        XCTAssertTrue(likeButton.waitForExistence(timeout: 5))
        let initialValue = likeButton.value as? String ?? "Active"
        likeButton.tap()
        sleep(3)
        let newValue = likeButton.value as? String ?? "Active"
        XCTAssertNotEqual(initialValue, newValue)
        likeButton.tap()
        sleep(3)
        firstCell.tap()
        sleep(3)
        let image = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(image.waitForExistence(timeout: 10))
        image.pinch(withScale: 3, velocity: 1)
        sleep(2)
        image.pinch(withScale: 0.5, velocity: -1)
        sleep(2)
        let navBackButton = app.buttons["nav back button white"]
        XCTAssertTrue(navBackButton.waitForExistence(timeout: 5))
        navBackButton.tap()
        XCTAssertTrue(tableView.waitForExistence(timeout: 5))
        tableView.swipeUp()
        sleep(3)
        XCTAssertTrue(tableView.exists)
    }
    
    
    func testProfile() throws {
        sleep(3)
        app.tabBars.buttons.element(boundBy: 1).tap()
        XCTAssertTrue(app.staticTexts["labelName"].exists)
        XCTAssertTrue(app.staticTexts["labelLogin"].exists)
        app.buttons["exitButton"].tap()
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
    }
}

