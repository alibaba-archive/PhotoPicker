//
//  CircleProgressView.swift
//  PhotoPicker
//
//  Created by Suric on 2018/11/25.
//  Copyright © 2018 StormXX. All rights reserved.
//

import UIKit

class CircularProgressView: UIView {
    
    // progress: Should be between 0 to 1
    var progress: CGFloat = 0 {
        didSet {
            self.isHidden = self.progress == 1
            self.setNeedsDisplay()
        }
    }
    
    private var circleStrokeWidth: CGFloat = 5
    
    // MARK: Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.isHidden = true
    }
    
    // MARK: Public Methods
    
    func setCircleStrokeWidth(_ circleStrokeWidth: CGFloat) {
        self.circleStrokeWidth = circleStrokeWidth
        self.setNeedsDisplay()
    }
    
    // MARK: Core Graphics Drawing
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawOutCircle(rect)
        drawOutLine(rect)
        drawInnerLine(rect)
        drawRect(rect, margin: circleStrokeWidth, color: UIColor.white, percentage: progress)
        drawProgressCircle(rect)
    }
    
    func drawCircle(with rect: CGRect, lineWidth: CGFloat, strokeColor: UIColor, margin: CGFloat = 0) {
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.setLineWidth(lineWidth)
        context.setStrokeColor(strokeColor.cgColor)
        
        let centerX: CGFloat = rect.width * 0.5
        let centerY: CGFloat = rect.height * 0.5
        let radius: CGFloat = min(rect.height, rect.width) * 0.5 - margin - lineWidth
        let startAngle: CGFloat = -.pi/2
        let endAngle: CGFloat = -.pi/2 + .pi * 2
        let center: CGPoint = CGPoint(x: centerX, y: centerY)
        
        context.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        context.strokePath()
    }
    
    func drawOutCircle(_ rect: CGRect) {
        drawCircle(with: rect, lineWidth: circleStrokeWidth / 2, strokeColor: UIColor.white)
    }
    
    func drawOutLine(_ rect: CGRect) {
        drawCircle(with: rect, lineWidth: 0.5, strokeColor: UIColor.gray)
    }
    
    
    func drawInnerLine(_ rect: CGRect) {
        drawCircle(with: rect, lineWidth: 0.5, strokeColor: UIColor.gray, margin: circleStrokeWidth / 2)
    }
    
    private func drawRect(_ rect: CGRect, margin: CGFloat, color: UIColor, percentage: CGFloat) {
        
        let radius: CGFloat = min(rect.height, rect.width) * 0.5 - margin
        let centerX: CGFloat = rect.width * 0.5
        let centerY: CGFloat = rect.height * 0.5
        
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.setStrokeColor(UIColor.white.cgColor)
        context.setFillColor(UIColor.white.cgColor)
        let center: CGPoint = CGPoint(x: centerX, y: centerY)
        context.move(to: center)
        let startAngle: CGFloat = -.pi/2
        let endAngle: CGFloat = -.pi/2 + .pi * 2 * percentage
        context.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        context.closePath()
        context.fillPath()
    }
    
    private func drawProgressCircle(_ rect: CGRect) {
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.setStrokeColor(UIColor.gray.cgColor)
        context.setFillColor(UIColor.white.cgColor)
        context.setLineWidth(0.5)
        
        let centerX: CGFloat = rect.width * 0.5
        let centerY: CGFloat = rect.height * 0.5
        let radius: CGFloat = min(rect.height, rect.width) * 0.5 - (circleStrokeWidth / 2) - 0.5
        let startAngle: CGFloat = -.pi/2
        let endAngle: CGFloat = -.pi/2 + .pi * 2 * progress
        let center: CGPoint = CGPoint(x: centerX, y: centerY)
        
        context.move(to: center)
        context.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        context.closePath()
        context.drawPath(using: .fillStroke)
        
        drawProgressLine(rect)
    }
    
    func drawProgressLine(_ rect: CGRect) {
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.setLineWidth(0.5)
        context.setStrokeColor(UIColor.white.cgColor)
        
        let centerX: CGFloat = rect.width * 0.5
        let centerY: CGFloat = rect.height * 0.5
        let radius: CGFloat = min(rect.height, rect.width) * 0.5 - (circleStrokeWidth / 2) - 0.5
        let startAngle: CGFloat = -.pi/2
        let endAngle: CGFloat = -.pi/2 + .pi * 2 * progress
        let center: CGPoint = CGPoint(x: centerX, y: centerY)
        
        context.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        context.strokePath()
    }
}
