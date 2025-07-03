//
//  ViewController.swift
//  ImageFeed
//
//  Created by Svetlana Varenova on 24.04.2025.
//

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak private var tableView: UITableView!
    
    // MARK: - Properties

    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    var photos: [Photo] = []
    private let imagesListService = ImagesListService()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceivePhotosUpdate(_:)), name: ImagesListService.didChangeNotification, object: nil)
        
        imagesListService.fetchPhotosNextPage()
    }
    
    @objc private func didReceivePhotosUpdate(_ notification: Notification) {
        let oldCount = photos.count
        photos = imagesListService.photos
        let newCount = photos.count
        
        guard newCount > oldCount else {
            return
        }
        let newIndexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0)}
        tableView.performBatchUpdates {
            self.photos = photos
            tableView.insertRows(at: newIndexPaths, with: .automatic)
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier,
           let viewController = segue.destination as? SingleImageViewController,
           let indexPath = sender as? IndexPath {
            let photo = photos[indexPath.row]
            viewController.imageURL = URL(string: photo.largeImageURL)
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }

        let photo = photos[indexPath.row]
        imageListCell.configure(with: photo, dateFormatter: dateFormatter)
        imageListCell.onImageLoad = { [weak self] in
            self?.tableView.performBatchUpdates(nil)
        }

        return imageListCell
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            imagesListService.fetchPhotosNextPage()
        }
    }
}

