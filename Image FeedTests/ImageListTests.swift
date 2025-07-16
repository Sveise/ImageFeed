//
//  ImageListTests.swift
//  ImageFeed
//
//  Created by Svetlana Varenova on 16.07.2025.
//

@testable import ImageFeed
import XCTest

final class ImageListTests: XCTestCase {
    func testViewDidLoadCallsPresenter() {
        // given
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        // when
        viewController.loadViewIfNeeded()
        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsUpdateTableView() {
        // given
        let view = ImagesListViewControllerSpy()
        let presenter = ImagesListPresenter()
        presenter.view = view
        // when
        presenter.view?.updateTableView(oldCount: 0, newCount: 1)
        // then
        XCTAssertTrue(view.updateTableViewCalled)
        XCTAssertEqual(view.receivedOldCount, 0)
        XCTAssertEqual(view.receivedNewCount, 1)
    }

    
    func testPresenterCallsReloadRow() {
        // given
        let view = ImagesListViewControllerSpy()
        let presenter = ImagesListPresenter()
        presenter.view = view
        let indexPath = IndexPath(row: 0, section: 0)
        // when
        presenter.view?.reloadRow(at: indexPath)
        // then
        XCTAssertTrue(view.reloadRowCalled)
        XCTAssertEqual(view.receivedIndexPath, indexPath)
    }

    
    func testPresenterCallsShowLikeError() {
        // given
        let viewController = ImagesListViewControllerSpy()
        let presenter = ImagesListPresenter()
        presenter.view = viewController
        // when
        presenter.view?.showLikeError()
        // then
        XCTAssertTrue(viewController.showLikeErrorCalled)
    }
    
    func testViewControllerCallsDidTapLike() {
        // given
        let presenter = ImagesListPresenterSpy()
        // when
        presenter.didTapLike(at: 0)
        // then
        XCTAssertEqual(presenter.didTapLikeIndex, 0)
    }
}

