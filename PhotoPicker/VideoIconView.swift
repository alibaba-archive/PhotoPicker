//
//  VideoIconView.swift
//  PhotoPicker
//
//  Created by DangGu on 16/6/21.
//  Copyright © 2016年 StormXX. All rights reserved.
//

import UIKit

class VideoIconView: UIView {

    var iconColor: UIColor = UIColor.whiteColor()

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func drawRect(rect: CGRect) {
        iconColor.setFill()
        
        let trianglePath = UIBezierPath()
        trianglePath.moveToPoint(CGPoint(x: maxX, y: minY))
        trianglePath.addLineToPoint(CGPoint(x: maxX, y: maxY))
        trianglePath.addLineToPoint(CGPoint(x: maxX - midY, y: midY))
        trianglePath.closePath()
        trianglePath.fill()
    
        
        let squarePath = UIBezierPath(roundedRect: CGRect(x: minX, y: minY, width: width - midY - 1.0, height: height), cornerRadius: 2.0)
        squarePath.fill()
    }
}
