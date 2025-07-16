//
//  ImagesListViewControllerSpy.swift
//  ImageFeed
//
//  Created by Svetlana Varenova on 16.07.2025.
//

import Foundation
@testable import ImageFeed

final class ImagesListViewControllerSpy: ImagesListViewProtocol {
    var updateTableViewCalled = false
    var reloadRowCalled = false
    var showSingleImageCalled = false
    var showLikeErrorCalled = false

    var receivedOldCount: Int?
    var receivedNewCount: Int?
    var receivedIndexPath: IndexPath?
    var receivedURL: URL?

    func updateTableView(oldCount: Int, newCount: Int) {
        updateTableViewCalled = true
        receivedOldCount = oldCount
        receivedNewCount = newCount
    }

    func reloadRow(at indexPath: IndexPath) {
        reloadRowCalled = true
        receivedIndexPath = indexPath
    }

    func showSingleImage(url: URL) {
        showSingleImageCalled = true
        receivedURL = url
    }

    func showLikeError() {
        showLikeErrorCalled = true
    }
}
