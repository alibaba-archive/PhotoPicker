//
//  PBCustomView.swift
//  PhotoBrowser
//
//  Created by WangWei on 16/3/16.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import UIKit

private let statusBarHeight = 20
private let waitingViewMargin: CGFloat = 10.0

class WaitingView: UIView {
    
    var logoView: UIImageView!
    var progress: CGFloat = 0 {
        
        willSet {
            if newValue > 1 {
                removeFromSuperview()
            }
        }
        
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 5.0
        layer.masksToBounds = true
        backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        clipsToBounds = true
        
        let image = UIImage.init(named: "icon-logo-white", inBundle: NSBundle.init(forClass: classForCoder), compatibleWithTraitCollection: nil)
        
        logoView = UIImageView.init(image: image)
        logoView.center = center
        addSubview(logoView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func drawRect(rect: CGRect) {
        let currentContext = UIGraphicsGetCurrentContext()
        let centerX = rect.size.width / 2
        let centerY = rect.size.height / 2
        
        UIColor.whiteColor().set()
        CGContextSetLineWidth(currentContext, 2)
        CGContextSetLineCap(currentContext, CGLineCap.Round)
        let end = CGFloat( -M_PI_2 + Double(progress) * M_PI * 2 + 0.05)
        let radius = min(rect.size.width, rect.size.height) / 2 - waitingViewMargin
        CGContextAddArc(currentContext, centerX, centerY, radius, CGFloat(-M_PI_2), end, 0)
        CGContextStrokePath(currentContext)
    }
    
}

class PBNavigationBar: UIView {
    
    lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(self.leftButton)
        view.addSubview(self.rightButton)
        view.addSubview(self.titleLabel)
        view.addSubview(self.indexLabel)
        
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .CenterY, relatedBy: .Equal, toItem: self.rightButton, attribute: .CenterY, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .CenterY, relatedBy: .Equal, toItem: self.leftButton, attribute: .CenterY, multiplier: 1.0, constant: 0))
        
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .Leading, relatedBy: .Equal, toItem: self.leftButton, attribute: .Leading, multiplier: 1.0, constant: -8))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .Trailing, relatedBy: .Equal, toItem: self.rightButton, attribute: .Trailing, multiplier: 1.0, constant: 8))
        
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .Top, relatedBy: .Equal, toItem: self.titleLabel, attribute: .Top, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .CenterX, relatedBy: .Equal, toItem: self.titleLabel, attribute: .CenterX, multiplier: 1.0, constant: 0))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-60-[titleLabel]-60-|", options: [], metrics: nil, views: ["titleLabel": self.titleLabel]))
        
        view.addConstraint(NSLayoutConstraint(item: self.titleLabel, attribute: .Bottom, relatedBy: .Equal, toItem: self.indexLabel, attribute: .Top, multiplier: 1.0, constant: -3))
        view.addConstraint(NSLayoutConstraint(item: self.titleLabel, attribute: .CenterX, relatedBy: .Equal, toItem: self.indexLabel, attribute: .CenterX, multiplier: 1.0, constant: 0))
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Title"
        label.textAlignment = .Center
        label.textColor = UIColor.whiteColor()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var indexLabel: UILabel = {
        let label = UILabel()
        label.text = "Index"
        label.textColor = UIColor.whiteColor()
        label.font = UIFont.systemFontOfSize(14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var leftButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "icon-cross", inBundle: NSBundle(forClass: classForCoder()), compatibleWithTraitCollection: nil)
        button.setImage(image, forState: .Normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addConstraint(NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .GreaterThanOrEqual, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 40))
        button.addConstraint(NSLayoutConstraint(item: button, attribute: .Height, relatedBy: .GreaterThanOrEqual, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 40))
        return button
    }()
    
    var rightButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "icon-share", inBundle: NSBundle(forClass: classForCoder()), compatibleWithTraitCollection: nil)
        button.setImage(image, forState: .Normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addConstraint(NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .GreaterThanOrEqual, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 40))
        button.addConstraint(NSLayoutConstraint(item: button, attribute: .Height, relatedBy: .GreaterThanOrEqual, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 40))
        return button
    }()
    
    var backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup() {
        addSubview(backgroundView)
        backgroundView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        backgroundView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        addSubview(contentView)
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[contentView]-0-|", options: [], metrics: nil, views: ["contentView": contentView]))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-statusBarHeight-[contentView]-0-|", options: [], metrics: ["statusBarHeight":statusBarHeight], views: ["contentView": contentView]))
    }
}

public class PBToolbar: UIToolbar {
    
    var backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setBackgroundImage(UIImage(), forToolbarPosition: .Any, barMetrics: .Default)
        clipsToBounds = true
        addSubview(backgroundView)
        backgroundView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class GradientView: UIView {
    
    var colors: [AnyObject]? {
        get {
            return (layer as! CAGradientLayer).colors
        }
        set {
            (layer as! CAGradientLayer).colors = newValue
        }
    }
    
    var startPoint: CGPoint {
        get {
            return (layer as! CAGradientLayer).startPoint
        }
        set {
            (layer as! CAGradientLayer).startPoint = newValue
        }
    }
    
    var endPoint: CGPoint {
        get {
            return (layer as! CAGradientLayer).endPoint
        }
        set {
            (layer as! CAGradientLayer).endPoint = newValue
        }
    }
    
    override class func layerClass() -> AnyClass {
        return CAGradientLayer.self
    }
}
