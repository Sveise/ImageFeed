//
//  ImageListPresenter.swift
//  ImageFeed
//
//  Created by Svetlana Varenova on 16.07.2025.
//

import UIKit

protocol ImagesListViewProtocol: AnyObject {
    func updateTableView(oldCount: Int, newCount: Int)
    func showLikeError()
    func reloadRow(at indexPath: IndexPath)
    func showSingleImage(url: URL)
}

protocol ImagesListPresenterProtocol {
    var view: ImagesListViewProtocol? { get set }
    var photosCount: Int { get }
    var dateFormatter: DateFormatter { get }
    func viewDidLoad()
    func willDisplayCell(at index: Int)
    func photo(at index: Int) -> Photo
    func cellHeight(for photo: Photo, tableViewWidth: CGFloat) -> CGFloat
    func didTapLike(at index: Int)
    func didSelectImage(at index: Int)
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewProtocol?
    private let imagesListService: ImagesListService
    private var photos: [Photo] = []
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    init(imagesListService: ImagesListService = ImagesListService.shared) {
        self.imagesListService = imagesListService
    }
    
    var photosCount: Int {
        photos.count
    }
    
    func viewDidLoad() {
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handlePhotosUpdate()
        }
        imagesListService.fetchPhotosNextPage()
    }
    
    func willDisplayCell(at index: Int) {
        let testMode = ProcessInfo.processInfo.arguments.contains("testMode")
        if !testMode && index + 1 == photos.count {
            imagesListService.fetchPhotosNextPage()
        }
    }
    
    func photo(at index: Int) -> Photo {
        photos[index]
    }
    
    func cellHeight(for photo: Photo, tableViewWidth: CGFloat) -> CGFloat {
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableViewWidth - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / photo.size.width
        return photo.size.height * scale + imageInsets.top + imageInsets.bottom
    }
    
    func didTapLike(at index: Int) {
        let photo = photos[index]
        
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            switch result {
            case .success:
                self.photos = self.imagesListService.photos
                self.view?.reloadRow(at: IndexPath(row: index, section: 0))
            case .failure:
                self.view?.showLikeError()
            }
        }
    }
    
    func didSelectImage(at index: Int) {
        let photo = photos[index]
        guard let url = URL(string: photo.largeImageURL) else { return }
        view?.showSingleImage(url: url)
    }
    
    private func handlePhotosUpdate() {
        let oldCount = photos.count
        let newPhotos = imagesListService.photos
        let newCount = newPhotos.count
        
        guard newCount > oldCount else { return }
        photos = newPhotos
        view?.updateTableView(oldCount: oldCount, newCount: newCount)
    }
}

