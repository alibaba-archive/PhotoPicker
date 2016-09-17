//
//  PBActionBarItem.swift
//  PhotoBrowser
//
//  Created by WangWei on 16/5/20.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import Foundation

public typealias BarActionClosure = (PhotoBrowser, PBActionBarItem) -> Void

public class PBActionBarItem: NSObject {
    public var barButtonItem: UIBarButtonItem!
    public var action: BarActionClosure?
    public weak var photoBrowser: PhotoBrowser?

    public init(title: String?, style: UIBarButtonItemStyle, action: BarActionClosure? = nil) {
        super.init()
        self.action = action
        barButtonItem = UIBarButtonItem(title: title, style: .Plain, target: self, action: #selector(PBActionBarItem.triggerAction))
    }

    public init(image: UIImage?, style: UIBarButtonItemStyle, action: BarActionClosure? = nil) {
        super.init()
        self.action = action
        barButtonItem = UIBarButtonItem(image: image, style: style, target: self, action: #selector(PBActionBarItem.triggerAction))
    }

    public init(barButtonItem: UIBarButtonItem, action: BarActionClosure? = nil) {
        super.init()
        self.barButtonItem = barButtonItem
        self.action = action
    }

    func triggerAction() {
        guard let photoBrowser = photoBrowser, action = action else {
            return
        }
        action(photoBrowser, self)
    }
}

public extension PhotoBrowser {
    func addActionBarItem(title title: String?, style: UIBarButtonItemStyle, action: BarActionClosure?) {
        let barItem = PBActionBarItem(title: title, style: style, action: action)
        barItem.photoBrowser = self
        actionItems.append(barItem)
    }

    func insert(actionBarItem: PBActionBarItem, at index: Int) {
        let barItem = actionBarItem
        barItem.photoBrowser = self
        actionItems.insert(barItem, atIndex: index)
    }

    func removeAllToolbarItems() {
        actionItems.removeAll()
    }
}
