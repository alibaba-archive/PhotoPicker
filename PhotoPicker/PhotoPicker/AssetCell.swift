//
//  AssetCell.swift
//  PhotoPicker
//
//  Created by DangGu on 16/2/26.
//  Copyright © 2016年 StormXX. All rights reserved.
//

import UIKit

class AssetCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var checkMarkImageView: UIImageView!
    
    override var selected: Bool {
        willSet {
            if !selected && newValue {
                checkMarkImageView.image = newValue ? UIImage(named: selectedCheckMarkImageName, inBundle: currentBundle, compatibleWithTraitCollection: nil) : UIImage(named: unselectedCheckMarkImageName, inBundle: currentBundle, compatibleWithTraitCollection: nil)
                if newValue {
                    UIView.animateKeyframesWithDuration(0.33, delay: 0.0, options: [], animations: { () -> Void in
                        UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.5, animations: { [unowned self]() -> Void in
                            let transform = CGAffineTransformMakeScale(1.3, 1.3)
                            self.checkMarkImageView.transform = transform
                            })
                        
                        UIView.addKeyframeWithRelativeStartTime(0.5, relativeDuration: 0.5, animations: { [unowned self]() -> Void in
                            self.checkMarkImageView.transform = CGAffineTransformIdentity
                            })
                        }, completion: nil)
                }
            }
        }
    }
}
