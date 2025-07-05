//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Svetlana Varenova on 30.04.2025.
//

import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var cellDateLabel: UILabel!
    @IBOutlet weak var cellLikeButton: UIButton!
    
    var onImageLoad: (() -> Void)?
    weak var delegate: ImagesListCellDelegate?
    
    func configure(with photo: Photo, dateFormatter: DateFormatter) {
        
        if let date = photo.createdAt {
            cellDateLabel.text = dateFormatter.string(from: date)
        } else {
            cellDateLabel.text = ""
        }
        
        let likeImage = photo.isLiked ? UIImage(named: "Active") : UIImage(named: "noActive")
        cellLikeButton.setImage(likeImage, for: .normal)
        
        cellImageView.kf.indicatorType = .activity
        
        let placeholder = UIImage(named: "stub")
        cellImageView.contentMode = .center
        cellImageView.clipsToBounds = true
        cellImageView.backgroundColor = UIColor.ypWhiteAlpha50
        
        cellImageView.kf.setImage(with: URL(string: photo.thumbImageURL), placeholder: placeholder) { [weak self] result in
            if case .success(_) = result {
                self?.cellImageView.contentMode = .scaleAspectFill
            }
            self?.onImageLoad?()
        }
    }
    
    func setIsLiked(_ isLiked: Bool) {
        let likeImage = isLiked ? UIImage(named: "Active") : UIImage(named: "noActive")
        cellLikeButton.setImage(likeImage, for: .normal)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellImageView.kf.cancelDownloadTask()
        cellImageView.image = nil
        cellDateLabel.text = nil
        cellLikeButton.setImage(nil, for: .normal)
        onImageLoad = nil
    }
    
    @IBAction private func likeButtonClicked() {
        delegate?.imageListCellDidTapLike(self)
    }
}

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}
