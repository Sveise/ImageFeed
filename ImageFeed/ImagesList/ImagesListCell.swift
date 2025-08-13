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
    
    private enum Constants {
        static let likedImageName = "Active"
        static let unlikedImageName = "noActive"
    }
    
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var cellDateLabel: UILabel!
    @IBOutlet weak var cellLikeButton: UIButton!
    
    var onImageLoad: (() -> Void)?
    weak var delegate: ImagesListCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cellLikeButton.accessibilityIdentifier = "likeButton" 
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        cellImageView.isUserInteractionEnabled = true
        cellImageView.addGestureRecognizer(tapRecognizer)
    }
    
    @objc private func imageTapped() {
        delegate?.imageListCellDidTapImage(self)
    }
    
    func configure(with photo: Photo, dateFormatter: DateFormatter) {
        if let date = photo.createdAt {
            cellDateLabel.text = dateFormatter.string(from: date)
        } else {
            cellDateLabel.text = ""
        }
        
        setIsLiked(photo.isLiked)
        let likeImage = UIImage(named: photo.isLiked ? Constants.likedImageName : Constants.unlikedImageName)
        cellLikeButton.setImage(likeImage, for: .normal)
        cellImageView.kf.indicatorType = .activity
        let placeholder = UIImage(named: "stub")
        
        cellImageView.contentMode = .center
        cellImageView.clipsToBounds = true
        cellImageView.backgroundColor = UIColor.ypWhiteAlpha50
        
        cellImageView.kf.setImage(with: URL(string: photo.thumbImageURL), placeholder: placeholder) { [weak self] result in
            guard let self = self else { return }
            
            if case .success = result {
                cellImageView.contentMode = .scaleAspectFill
            }
            
            onImageLoad?()
        }
    }
    
    func setIsLiked(_ isLiked: Bool) {
        let likeImage = UIImage(named: isLiked ? Constants.likedImageName : Constants.unlikedImageName)
        cellLikeButton.setImage(likeImage, for: .normal)
        cellLikeButton.accessibilityIdentifier = "likeButton"
        cellLikeButton.accessibilityValue = isLiked ? "Active" : "noActive"
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
