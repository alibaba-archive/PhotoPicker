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
                imageView.isHidden = true
                numberLabel.isHidden = true
            } else {
                imageView.isHidden = false
                numberLabel.isHidden = false
                numberLabel.text = "\(number)"
                changeNumberAnimation()
            }
        }
    }
    
    fileprivate var imageView: UIImageView!
    fileprivate var numberLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupProperty()
        addSubview(imageView)
        addSubview(numberLabel)
    }
    
    func setupProperty() {
        imageView = UIImageView(frame: bounds)
        imageView.image = UIImage(named: toolbarNumberViewBackgroundImageName, in: currentBundle, compatibleWith: nil)
        imageView.isHidden = true
        
        numberLabel = UILabel(frame: bounds)
        numberLabel.font = UIFont.boldSystemFont(ofSize: 15.0)
        numberLabel.textAlignment = .center
        numberLabel.textColor = UIColor.white
        numberLabel.isHidden = true
    }
    
    func changeNumberAnimation() {
        UIView.animate(withDuration: 0.1, animations: { [unowned self]() -> Void in
            self.imageView.transform = CGAffineTransform(scaleX: 0, y: 0)
        }, completion: { (finished) -> Void in
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 10.0, options: [], animations: { () -> Void in
                self.imageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: nil)
        })
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
