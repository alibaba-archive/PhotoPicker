//
//  SlomoIconView.swift
//  PhotoPicker
//
//  Created by DangGu on 16/6/21.
//  Copyright © 2016年 StormXX. All rights reserved.
//

import UIKit

class SlomoIconView: UIView {

    var iconColor: UIColor = UIColor.whiteColor()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func drawRect(rect: CGRect) {
        iconColor.setStroke()
        let width: CGFloat = 2.2
        let insetRect = CGRectInset(rect, width / 2, width / 2)

        let circlePath = UIBezierPath(ovalInRect: insetRect)
        circlePath.lineWidth = width
        let pattern: [CGFloat] = [0.75, 0.75]
        circlePath.setLineDash(pattern, count: 2, phase: 0)
        circlePath.stroke()
    }
}
