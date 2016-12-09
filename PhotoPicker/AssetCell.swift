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
    @IBOutlet weak var tapGestureView: UIView!
    @IBOutlet weak var videoIndicatorView: VideoIndicatorView!
    fileprivate var checkHandler: ((_ checked: Bool) -> Bool)?

    fileprivate var checked: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler(_:)))
        tapGestureView.isUserInteractionEnabled = true
        tapGestureView.addGestureRecognizer(tapGesture)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        checkHandler = nil
    }

    func tapGestureHandler(_ recognizer: UIGestureRecognizer) {
        guard let handler = checkHandler else { return }
        if handler(checked) {
            setChecked(!checked, animation: true)
        }
    }

    func addCheckHandler(_ handler: @escaping (_ checked: Bool) -> Bool) {
        checkHandler = handler
    }

    func setChecked(_ checked: Bool, animation: Bool) {
        checkMarkImageView.image = checked ? UIImage(named: selectedCheckMarkImageName, in: currentBundle, compatibleWith: nil) : UIImage(named: unselectedCheckMarkImageName, in: currentBundle, compatibleWith: nil)
        if !self.checked && checked && animation {
            UIView.animateKeyframes(withDuration: 0.33, delay: 0.0, options: [], animations: { () -> Void in
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5, animations: { [unowned self]() -> Void in
                    let transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                    self.checkMarkImageView.transform = transform
                    })
                
                UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5, animations: { [unowned self]() -> Void in
                    self.checkMarkImageView.transform = CGAffineTransform.identity
                    })
                }, completion: nil)
        }
        self.checked = checked
    }

    func showVideoIcon() {
        videoIndicatorView.videoIcon.isHidden = false
        videoIndicatorView.slomoIcon.isHidden = true
    }
    
    func showSlomoIcon() {
        videoIndicatorView.videoIcon.isHidden = true
        videoIndicatorView.slomoIcon.isHidden = false
    }
}
