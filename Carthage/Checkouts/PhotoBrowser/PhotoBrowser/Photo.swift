//
//  Photo.swift
//  PhotoBrowser
//
//  Created by WangWei on 16/2/16.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import Foundation
import UIKit
import Photos
import Kingfisher

public struct Photo {
    public var image: UIImage?
    public var thumbnailImage: UIImage?
    public var photoUrl: NSURL?
    public var thumbnailUrl: NSURL?
    public var title: String?
    public var object: AnyObject?
    
    public init(image: UIImage?, title: String? = nil, thumbnailImage: UIImage? = nil, photoUrl: NSURL? = nil, thumbnailUrl: NSURL? = nil, object: AnyObject? = nil) {
        self.image = image
        self.title = title
        self.thumbnailImage = thumbnailImage
        self.photoUrl = photoUrl
        self.thumbnailUrl = thumbnailUrl
        self.object = object
    }
    
    public func localOriginalPhoto() -> UIImage? {
        if image != nil {
            return image
        } else if let photoUrl = photoUrl {
            let image = KingfisherManager.sharedManager.cache.retrieveImageInMemoryCacheForKey(photoUrl.absoluteString)
            return image ?? KingfisherManager.sharedManager.cache.retrieveImageInDiskCacheForKey(photoUrl.absoluteString)
        }
        return nil
    }
    
    public func localThumbnailPhoto() -> UIImage? {
        if thumbnailImage != nil {
            return thumbnailImage
        } else if let thumbnailUrl = thumbnailUrl {
            let image = KingfisherManager.sharedManager.cache.retrieveImageInMemoryCacheForKey(thumbnailUrl.absoluteString)
            return image ?? KingfisherManager.sharedManager.cache.retrieveImageInDiskCacheForKey(thumbnailUrl.absoluteString)
        }
        return nil
    }
    
    public func imageToSave() -> UIImage? {
        
        if let imageToSave = localOriginalPhoto() {
            return imageToSave
        }
        if let imageToSave = localThumbnailPhoto() {
            return imageToSave
        }
        return nil
        
    }
}
