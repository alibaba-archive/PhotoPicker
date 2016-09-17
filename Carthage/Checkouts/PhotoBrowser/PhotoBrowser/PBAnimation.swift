//
//  PresentAnimation.swift
//  PhotoBrowser
//
//  Created by WangWei on 16/3/14.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import UIKit

let PresentDuration = 0.3
let DismissDuration = 0.35
var AssociatedObjectHandle: UInt8 = 0

extension UIViewController {

    public func presentPhotoBrowser(viewControllerToPresent: UIViewController, fromView: UIView) {
        let transitionDelegate = TransitionDelegate(fromView: fromView)
        let navigationController = UINavigationController(rootViewController: viewControllerToPresent)
        navigationController.modalPresentationStyle = .FullScreen
        navigationController.pb_transitionDelegate = transitionDelegate
        navigationController.transitioningDelegate = transitionDelegate
        presentViewController(navigationController, animated: true, completion: nil)
    }
    
    public func dismissPhotoBrowser(toView toView: UIView? = nil) {
        if let viewController = presentedViewController {
            viewController.pb_transitionDelegate.toView = toView
        }
        dismissViewControllerAnimated(true, completion: nil)
    }

    internal var pb_transitionDelegate: TransitionDelegate {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectHandle) as! TransitionDelegate
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectHandle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

public class TransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    public var fromView: UIView!
    public var toView: UIView?
    
    init(fromView: UIView) {
        super.init()
        self.fromView = fromView
        self.toView = fromView
    }
    
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentAnimation(fromView: fromView)
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let destView = toView {
            return DismissAnimation(toView: destView)
        } else {
            return DismissImmediatelyAnimation()
        }
    }
}

public class PresentAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    public var fromView: UIView!
    
    public init(fromView: UIView) {
        super.init()
        self.fromView = fromView
    }

    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return PresentDuration
    }
 
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let container = transitionContext.containerView()!
 
        container.addSubview(toVC.view)
        let fromFrame = container.convertRect(fromView.frame, fromView: fromView.superview)
        let toFrame = transitionContext.finalFrameForViewController(toVC)
        
        let scale = CGAffineTransformMakeScale(fromFrame.width/toFrame.width, fromFrame.height/toFrame.height)
        let translate = CGAffineTransformMakeTranslation(-(toVC.view.center.x - fromFrame.midX), -(toVC.view.center.y - fromFrame.midY))
        toVC.view.transform = CGAffineTransformConcat(scale, translate)
        toVC.view.alpha = 0
        
        UIView.animateWithDuration(PresentDuration, delay: 0, options: .CurveEaseInOut, animations: {
            toVC.view.transform = CGAffineTransformMakeScale(1, 1)
            toVC.view.alpha = 1
            self.fromView.alpha = 0
            }) { (_) in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
                self.fromView.alpha = 1
        }
    }
}

public class DismissAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    public var toView: UIView!
    
    init(toView: UIView) {
        super.init()
        self.toView = toView
    }
    
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return DismissDuration
    }
    
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView()!
        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!

        toVC.view.frame = transitionContext.finalFrameForViewController(toVC)
        container.addSubview(toVC.view)
        container.addSubview(fromVC.view)
        let toFrame = container.convertRect(toView.frame, fromView: toView.superview)
        let scale = CGAffineTransformMakeScale(toFrame.width/fromVC.view.frame.width, toFrame.height/fromVC.view.frame.height)
        let translate = CGAffineTransformMakeTranslation(-(fromVC.view.center.x - toFrame.midX), -(fromVC.view.center.y - toFrame.midY))
        toView.alpha = 0
        
        UIView.animateWithDuration(DismissDuration, delay: 0, options: .CurveEaseOut, animations: {
            fromVC.view.transform = CGAffineTransformConcat(scale, translate)
            fromVC.view.alpha = 0
            self.toView.alpha = 1
            }) { (_) in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
}

public class DismissImmediatelyAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return DismissDuration/2
    }
    
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        
        transitionContext.containerView()?.addSubview(toVC.view)
        transitionContext.containerView()?.addSubview(fromVC.view)
        
        UIView.animateWithDuration(DismissDuration/2, animations: { () -> Void in
            fromVC.view.alpha = 0
            }) { (_) -> Void in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
}
