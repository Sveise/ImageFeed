//
//  Array +Extension.swift
//  ImageFeed
//
//  Created by Svetlana Varenova on 14.07.2025.
//

import Foundation

extension Array {
    func withReplaced(itemAt index: Int, newValue: Element) -> [Element] {
        var newArray = self
        newArray[index] = newValue
        return newArray
    }
}
