//
//  VideoIconView.swift
//  PhotoPicker
//
//  Created by DangGu on 16/6/21.
//  Copyright © 2016年 StormXX. All rights reserved.
//

import UIKit

class VideoIconView: UIView {

    var iconColor: UIColor = UIColor.white

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func draw(_ rect: CGRect) {
        iconColor.setFill()
        
        let trianglePath = UIBezierPath()
        trianglePath.move(to: CGPoint(x: maxX, y: minY))
        trianglePath.addLine(to: CGPoint(x: maxX, y: maxY))
        trianglePath.addLine(to: CGPoint(x: maxX - midY, y: midY))
        trianglePath.close()
        trianglePath.fill()
    
        
        let squarePath = UIBezierPath(roundedRect: CGRect(x: minX, y: minY, width: width - midY - 1.0, height: height), cornerRadius: 2.0)
        squarePath.fill()
    }
}
