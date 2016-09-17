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
    @IBOutlet weak var videoIndicatorView: VideoIndicatorView!
    private var checkHandler: ((checked: Bool) -> Bool)?

    private var checked: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler(_:)))
        checkMarkImageView.userInteractionEnabled = true
        checkMarkImageView.addGestureRecognizer(tapGesture)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        checkHandler = nil
    }

    func tapGestureHandler(recognizer: UIGestureRecognizer) {
        guard let handler = checkHandler else { return }
        if handler(checked: checked) {
            setChecked(!checked, animation: true)
        }
    }

    func addCheckHandler(handler: (checked: Bool) -> Bool) {
        checkHandler = handler
    }

    func setChecked(checked: Bool, animation: Bool) {
        checkMarkImageView.image = checked ? UIImage(named: selectedCheckMarkImageName, inBundle: currentBundle, compatibleWithTraitCollection: nil) : UIImage(named: unselectedCheckMarkImageName, inBundle: currentBundle, compatibleWithTraitCollection: nil)
        if !self.checked && checked && animation {
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
        self.checked = checked
    }

    func showVideoIcon() {
        videoIndicatorView.videoIcon.hidden = false
        videoIndicatorView.slomoIcon.hidden = true
    }
    
    func showSlomoIcon() {
        videoIndicatorView.videoIcon.hidden = true
        videoIndicatorView.slomoIcon.hidden = false
    }
}
