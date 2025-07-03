//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Svetlana Varenova on 09.05.2025.
//

import UIKit
import Kingfisher

// MARK: - SingleImageViewController
final class SingleImageViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak private var scrollView: UIScrollView!
    @IBOutlet weak private var imageView: UIImageView!
    
    // MARK: - Properties
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }
            displayImage(image)
        }
    }
    
    var imageURL: URL? {
        didSet {
            guard isViewLoaded, image == nil, let url = imageURL else { return }
            loadImage(from: url)
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        if let image = image {
            displayImage(image)
        } else if let url = imageURL {
            loadImage(from: url)
        }
    }
        
    private func displayImage(_ image: UIImage) {
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.frame.size = image.size
        rescaleAndCenterImageInScrollView(image: image)
    }
    
    private func loadImage(from url: URL) {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(indicator)
        
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor)
        ])
        
        indicator.startAnimating()
        
        imageView.kf.setImage(with: url, placeholder: nil, options: nil) { [weak self] result in
            DispatchQueue.main.async {
                indicator.removeFromSuperview()
                switch result {
                case .success(let value):
                    self?.displayImage(value.image)
                case .failure(let error):
                    print("Ошибка загрузки изображения: \(error)")
        
                }
            }
        }
    }
    
    // MARK: - Private methods
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    // MARK: - IBActions
    @IBAction private func didTapShareButton(_ sender: UIButton) {
        print("Share button tapped")
        guard let image = imageView.image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    
    @IBAction private func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UIScrollViewDelegate
extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}

