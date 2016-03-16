//
//  CommonExtension.swift
//  PhotoPicker
//
//  Created by DangGu on 16/2/25.
//  Copyright © 2016年 StormXX. All rights reserved.
//

import UIKit

extension CGSize {
    func scale(scale: CGFloat) -> CGSize {
        return CGSize(width: self.width * scale, height: self.height * scale)
    }
}

extension UICollectionView {
    func pp_indexPathsForElementsInRect(rect: CGRect) -> [NSIndexPath]? {
        let allLayoutAttributes = self.collectionViewLayout.layoutAttributesForElementsInRect(rect)
        guard let attributes = allLayoutAttributes where attributes.count > 0 else { return nil }
        var indexPaths: [NSIndexPath] = []
        for layoutAttributes in attributes {
            let indexPath = layoutAttributes.indexPath
            indexPaths.append(indexPath)
        }
        return indexPaths
    }
}

extension NSIndexSet {
    func pp_indexPathsFromIndexesInSection(section: Int) -> [NSIndexPath] {
        var indexPaths: [NSIndexPath] = []
        for (index, _) in self.enumerate() {
            indexPaths.append(NSIndexPath(forItem: index, inSection: section))
        }
        return indexPaths
    }
}