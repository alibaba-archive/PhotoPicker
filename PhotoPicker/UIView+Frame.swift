//
//  UIViewExtension.swift
//  STNumberLabel
//
//  Created by DangGu on 15/11/16.
//  Copyright © 2015年 StormXX. All rights reserved.
//

import UIKit

extension UIView {
    var width: CGFloat {
        get {
            return bounds.width
        }
    }
    
    var height: CGFloat {
        get {
            return bounds.height
        }
    }
    
    var minX: CGFloat {
        get {
            return bounds.minX
        }
    }
    
    var minY: CGFloat {
        get {
            return bounds.minY
        }
    }
    
    var maxX: CGFloat {
        get {
            return bounds.maxX
        }
    }
    
    var maxY: CGFloat {
        get {
            return bounds.maxY
        }
    }

    var midY: CGFloat {
        get {
            return bounds.midY
        }
    }

    var absoluteCenter: CGPoint {
        get {
            return CGPoint(x: width / 2, y: height / 2)
        }
    }
}
