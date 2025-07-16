//
//  ViewController.swift
//  ImageFeed
//
//  Created by Svetlana Varenova on 24.04.2025.
//

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController, ImagesListViewProtocol {

    @IBOutlet private weak var tableView: UITableView!

    var presenter: ImagesListPresenterProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if presenter == nil {
            presenter = ImagesListPresenter()
        }
        
        presenter.view = self
        setupTableView()
        presenter.viewDidLoad()
    }

    func updateTableView(oldCount: Int, newCount: Int) {
        let newIndexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
        tableView.performBatchUpdates {
            tableView.insertRows(at: newIndexPaths, with: .automatic)
        }
    }
    
    func showLikeError() {
        let alert = UIAlertController(
            title: "Ошибка",
            message: "Не удалось поставить лайк. Попробуйте ещё раз.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)
    }
    
    func reloadRow(at indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func showSingleImage(url: URL) {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let vc = storyboard.instantiateViewController(withIdentifier: "SingleImageViewController") as! SingleImageViewController
        vc.imageURL = url
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.photosCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as? ImagesListCell else {
            return UITableViewCell()
        }
        
        let photo = presenter.photo(at: indexPath.row)
        cell.configure(with: photo, dateFormatter: presenter.dateFormatter)
        cell.delegate = self
        cell.onImageLoad = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.beginUpdates()
                self?.tableView.endUpdates()
            }
        }
        
        return cell
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didSelectImage(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = presenter.photo(at: indexPath.row)
        return presenter.cellHeight(for: photo, tableViewWidth: tableView.bounds.width)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter.willDisplayCell(at: indexPath.row)
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        presenter.didTapLike(at: indexPath.row)
    }
    
    func imageListCellDidTapImage(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        presenter.didSelectImage(at: indexPath.row)
    }
}
