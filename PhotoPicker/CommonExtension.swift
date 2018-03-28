//
//  CommonExtension.swift
//  PhotoPicker
//
//  Created by DangGu on 16/2/25.
//  Copyright © 2016年 StormXX. All rights reserved.
//

import UIKit

extension CGSize {
    func scale(_ scale: CGFloat) -> CGSize {
        return CGSize(width: self.width * scale, height: self.height * scale)
    }
}

extension UICollectionView {
    func pp_indexPathsForElementsInRect(_ rect: CGRect) -> [IndexPath]? {
        let allLayoutAttributes = self.collectionViewLayout.layoutAttributesForElements(in: rect)
        
        guard let attributes = allLayoutAttributes , attributes.count > 0 else {
            return nil
        }
        
        return attributes.flatMap { $0.indexPath }
    }
}

extension IndexSet {
    func pp_indexPathsFromIndexesInSection(_ section: Int) -> [IndexPath] {
        var indexPaths: [IndexPath] = []
        for (index, _) in self.enumerated() {
            indexPaths.append(IndexPath(item: index, section: section))
        }
        return indexPaths
    }
}
