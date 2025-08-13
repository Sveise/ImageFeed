//
//  ImageListPresenterSpy.swift
//  ImageFeed
//
//  Created by Svetlana Varenova on 16.07.2025.
//

import Foundation

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    weak var view: ImagesListViewProtocol?
    var photosCount: Int = 0
    var dateFormatter = DateFormatter()
    
    var viewDidLoadCalled = false
    var didTapLikeIndex: Int?

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func willDisplayCell(at index: Int) {}

    func photo(at index: Int) -> Photo {
        return Photo(id: "1", size: CGSize(width: 100, height: 100), createdAt: nil, welcomeDescription: nil, thumbImageURL: "", largeImageURL: "", isLiked: false)
    }

    func cellHeight(for photo: Photo, tableViewWidth: CGFloat) -> CGFloat {
        return 100
    }

    func didTapLike(at index: Int) {
        didTapLikeIndex = index
    }

    func didSelectImage(at index: Int) {}
}
