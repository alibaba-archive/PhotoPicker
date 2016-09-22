//
//  SlomoIconView.swift
//  PhotoPicker
//
//  Created by DangGu on 16/6/21.
//  Copyright © 2016年 StormXX. All rights reserved.
//

import UIKit

class SlomoIconView: UIView {

    var iconColor: UIColor = UIColor.white
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func draw(_ rect: CGRect) {
        iconColor.setStroke()
        let width: CGFloat = 2.2
        let insetRect = rect.insetBy(dx: width / 2, dy: width / 2)

        let circlePath = UIBezierPath(ovalIn: insetRect)
        circlePath.lineWidth = width
        let pattern: [CGFloat] = [0.75, 0.75]
        circlePath.setLineDash(pattern, count: 2, phase: 0)
        circlePath.stroke()
    }
}
