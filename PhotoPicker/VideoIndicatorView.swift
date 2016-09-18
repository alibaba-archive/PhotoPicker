//
//  VideoIndicatorView.swift
//  PhotoPicker
//
//  Created by DangGu on 16/6/21.
//  Copyright © 2016年 StormXX. All rights reserved.
//

import UIKit

class VideoIndicatorView: UIView {

    @IBOutlet weak var videoIcon: VideoIconView!
    @IBOutlet weak var slomoIcon: SlomoIconView!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        layer.insertSublayer(gradientLayer, at: 0)
    }

}
