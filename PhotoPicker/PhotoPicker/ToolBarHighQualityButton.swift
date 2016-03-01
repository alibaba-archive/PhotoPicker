//
//  ToolBarHighQualityButton.swift
//  PhotoPicker
//
//  Created by DangGu on 16/3/1.
//  Copyright © 2016年 StormXX. All rights reserved.
//

import UIKit

let imageViewWidth: CGFloat = 18
class ToolBarHighQualityButton: UIView {
    
    //MARK: - public property
    var checked: Bool = false {
        didSet {
            if checked {
                imageView.image = UIImage(named: toolbarHighQualityImageCheckedImageName, inBundle: currentBundle, compatibleWithTraitCollection: nil)
                titleLabel.textColor = blueTextColor
            } else {
                imageView.image = UIImage(named: toolbarHighQualityImageUnCheckedImageName, inBundle: currentBundle, compatibleWithTraitCollection: nil)
                titleLabel.textColor = greyTextColor
            }
        }
    }
    
    //MARK: - private property
    private var imageView: UIImageView!
    private var titleLabel: UILabel!
    private var tap: UITapGestureRecognizer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupProperty()
        addSubview(imageView)
        addSubview(titleLabel)
        setupConstraints()
    }
    
    func setupProperty() {
        imageView = UIImageView(frame: CGRectZero)
        imageView.image = UIImage(named: toolbarHighQualityImageUnCheckedImageName, inBundle: currentBundle, compatibleWithTraitCollection: nil)
        
        titleLabel = UILabel(frame: CGRectZero)
        titleLabel.textColor = greyTextColor
        titleLabel.font = UIFont.systemFontOfSize(15.0)
        titleLabel.text = "Origin"
        
        tap = UITapGestureRecognizer(target: self, action: "tapped:")
        addGestureRecognizer(tap)
    }
    
    func setupConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["imageView":imageView, "titleLabel":titleLabel]
        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[imageView(==imageViewWidth)]-5-[titleLabel]|", options: [], metrics: ["imageViewWidth": imageViewWidth], views: views)
        let imageViewHeight = NSLayoutConstraint(item: imageView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: imageViewWidth)
        let imageViewCenterY = NSLayoutConstraint(item: imageView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0.0)
        let titleLabelCenterY = NSLayoutConstraint(item: titleLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0.0)
        let constraints = [imageViewHeight, imageViewCenterY, titleLabelCenterY]
        
        NSLayoutConstraint.activateConstraints(horizontalConstraints + constraints)
    }
    
    func tapped(recognizer: UIGestureRecognizer) {
        checked = !checked
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
