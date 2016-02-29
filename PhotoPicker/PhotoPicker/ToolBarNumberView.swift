//
//  ToolBarNumberView.swift
//  PhotoPicker
//
//  Created by DangGu on 16/2/29.
//  Copyright © 2016年 StormXX. All rights reserved.
//

import UIKit

class ToolBarNumberView: UIView {
    var number: Int = 0 {
        didSet {
            if number == 0 {
                imageView.hidden = true
                numberLabel.hidden = true
            } else {
                imageView.hidden = false
                numberLabel.hidden = false
                numberLabel.text = "\(number)"
                changeNumberAnimation()
            }
        }
    }
    
    private var imageView: UIImageView!
    private var numberLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupProperty()
        addSubview(imageView)
        addSubview(numberLabel)
    }
    
    func setupProperty() {
        imageView = UIImageView(frame: bounds)
        imageView.image = UIImage(named: toolbarNumberViewBackgroundImageName, inBundle: currentBundle, compatibleWithTraitCollection: nil)
        imageView.hidden = true
        
        numberLabel = UILabel(frame: bounds)
        numberLabel.font = UIFont.boldSystemFontOfSize(15.0)
        numberLabel.textAlignment = .Center
        numberLabel.textColor = UIColor.whiteColor()
        numberLabel.hidden = true
    }
    
    func changeNumberAnimation() {
        UIView.animateWithDuration(0.1, animations: { [unowned self]() -> Void in
            self.imageView.transform = CGAffineTransformMakeScale(0, 0)
        }) { (finished) -> Void in
            if finished {
                UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 10.0, options: [], animations: { () -> Void in
                    self.imageView.transform = CGAffineTransformMakeScale(1.0, 1.0)
                    }, completion: nil)
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
