//
//  ImagesListCellDelegate.swift
//  ImageFeed
//
//  Created by Svetlana Varenova on 14.07.2025.
//

import Foundation

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
    func imageListCellDidTapImage(_ cell: ImagesListCell)
}
