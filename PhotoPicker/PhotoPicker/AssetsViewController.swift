//
//  AssetsViewController.swift
//  PhotoPicker
//
//  Created by DangGu on 16/2/26.
//  Copyright © 2016年 StormXX. All rights reserved.
//

import UIKit
import Photos

class AssetsViewController: UICollectionViewController {
    
    //MARK: - public property
    var photoPickerController: PhotoPickerController!
    var selectedAssets: [PHAsset] = [] {
        didSet {
            updateHighQualityImageSize()
        }
    }
    
    var assetCollection: PHAssetCollection! {
        didSet {
            self.updateFetchRequest()
        }
    }
    
    //MARK: - private property
    private let imageManager: PHCachingImageManager = PHCachingImageManager()
    private var previousPreheatRect: CGRect = CGRectZero
    private var assetsFetchResults: PHFetchResult!
    private var lastSelectItemIndexPath: NSIndexPath?
    private var toolbarNumberView: ToolBarNumberView!
    private var toolbarHighQualityButton: ToolBarHighQualityButton!
    private var sendBarItem: UIBarButtonItem!
    private var needHighQuality: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCancelButton()
        setupToolBar()
        resetCachedAssets()
        PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
    }
    
    deinit {
        PHPhotoLibrary.sharedPhotoLibrary().unregisterChangeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = assetCollection.localizedTitle
        navigationItem.prompt = photoPickerController.prompt
        
        collectionView?.allowsMultipleSelection = photoPickerController.allowMultipleSelection
        
        collectionView?.reloadData()
        
        if assetsFetchResults.count > 0 && isMovingToParentViewController() {
            let indexPath = NSIndexPath(forItem: assetsFetchResults.count - 1, inSection: 0)
            collectionView?.scrollToItemAtIndexPath(indexPath, atScrollPosition: .Top, animated: false)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        updateCachedAssets()
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        guard let collectionView = collectionView else { return }
        collectionViewLayout.invalidateLayout()
        if let indexPath = collectionView.indexPathsForVisibleItems().last {
            coordinator.animateAlongsideTransition(nil, completion: { (context) -> Void in
               collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: false)
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetsFetchResults.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: AssetCell = collectionView.dequeueReusableCellWithReuseIdentifier(assetCellIdentifier, forIndexPath: indexPath) as! AssetCell
        fillCell(cell, forIndexPath: indexPath)
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionFooter {
            let footerView: UICollectionReusableView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: assetFooterViewIdentifier, forIndexPath: indexPath)
            let numberOfPhotos = assetsFetchResults.countOfAssetsWithMediaType(.Image)
            let numberOfVideos = assetsFetchResults.countOfAssetsWithMediaType(.Video)
            
            if let label = footerView.viewWithTag(100) as? UILabel {
                label.text = "\(numberOfPhotos) \(localizedString["PhotoPicker.Photos"]!) , \(numberOfVideos) \(localizedString["PhotoPicker.Videos"]!)"
            }
            return footerView
        }
        return UICollectionReusableView()
    }

    // MARK: UICollectionViewDelegate
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        func clearSelectedCell() {
            selectedAssets.removeAll()
            if let selectedIndexPathes = collectionView.indexPathsForSelectedItems() {
                selectedIndexPathes.forEach({ (selectIndexPath) in
                    if selectIndexPath != indexPath {
                        collectionView.deselectItemAtIndexPath(selectIndexPath, animated: false)
                    }
                })
            }
        }

        guard let asset = assetsFetchResults[indexPath.item] as? PHAsset else { return }
        
        if photoPickerController.allowMultipleSelection {
            if isAutoDeselectEnable() && selectedAssets.count > 0 {
                selectedAssets.removeAtIndex(0)
                if let lastSelectItemIndexPath = lastSelectItemIndexPath {
                    collectionView.deselectItemAtIndexPath(lastSelectItemIndexPath, animated: false)
                }
            }
            
            if asset.mediaType == .Video {
                clearSelectedCell()
                toggleHighQualityButtonHidden(true)
                showVideoSelectAlert()
            } else if isVideoAsset(lastSelectItemIndexPath) {
                clearSelectedCell()
                toggleHighQualityButtonHidden(false)
            } else {
                toggleHighQualityButtonHidden(false)
            }

            selectedAssets.append(asset)
            lastSelectItemIndexPath = indexPath
            updateToolBar()
        } else {
            photoPickerController.delegate?.photoPickerController(photoPickerController, didFinishPickingAssets: [asset], needHighQualityImage: true)
        }
        
        photoPickerController.delegate?.photoPickerController(photoPickerController, didSelectAsset: asset)
    }
    
    override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        guard photoPickerController.allowMultipleSelection, let asset = assetsFetchResults[indexPath.item] as? PHAsset else { return }
        
        if let index = selectedAssets.indexOf(asset) {
            selectedAssets.removeAtIndex(index)
            lastSelectItemIndexPath = nil
            
            updateToolBar()
            photoPickerController.delegate?.photoPickerController(photoPickerController, didDeselectAsset: asset)
        }
    }

    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        if let asset = assetsFetchResults[indexPath.item] as? PHAsset, let shouldSelectAsset = photoPickerController.delegate?.photoPickerController(photoPickerController, shouldSelectAsset: asset) {
            guard shouldSelectAsset else { return false }
            if isAutoDeselectEnable() {
                return true
            }
            
            if isMaximumSelectionReached() {
                showMaximumSelectionReachedAlert()
                return false
            }
            return true
        } else {
            return false
        }
    }
}

//MARK: - response method
extension AssetsViewController {
    func sendButtonTapped() {
        guard selectedAssets.count > 0 else { return }
        photoPickerController.delegate?.photoPickerController(photoPickerController, didFinishPickingAssets: selectedAssets, needHighQualityImage: toolbarHighQualityButton.checked)
    }
    
    func cancelButtonTapped(sender: UIBarButtonItem) {
        photoPickerController.delegate?.photoPickerControllerDidCancel(photoPickerController)
    }
}

//MARK: - UI help method
extension AssetsViewController {
    func setupCancelButton() {
        let cancel = UIBarButtonItem(title: localizedString["PhotoPicker.Cancel"], style: .Plain, target: self, action: #selector(cancelButtonTapped))
        navigationItem.rightBarButtonItem = cancel
    }

    func setupToolBar() {
        guard photoPickerController.allowMultipleSelection else { return }
        toolbarNumberView = ToolBarNumberView(frame: CGRect(origin: CGPointZero, size: CGSize(width: 21.0, height: 21.0)))
        toolbarHighQualityButton = ToolBarHighQualityButton(frame: CGRect(origin: CGPointZero, size: CGSize(width: 150, height: 21.0)))
        toolbarHighQualityButton.assetsViewController = self
        
        sendBarItem = UIBarButtonItem(title: localizedString["PhotoPicker.Send"], style: .Plain, target: self, action: #selector(AssetsViewController.sendButtonTapped))
        sendBarItem.enabled = false
        let highqualityBarItem = UIBarButtonItem(customView: toolbarHighQualityButton)
        let numberBarItem = UIBarButtonItem(customView: toolbarNumberView)
        let leftSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        toolbarItems = [highqualityBarItem, leftSpace, numberBarItem, sendBarItem]
        
        navigationController?.toolbar.tintColor = toolBarTintColor
        navigationController?.setToolbarHidden(false, animated: true)
    }

    func toggleHighQualityButtonHidden(hidden: Bool) {
        toolbarHighQualityButton.hidden = hidden
    }
    
    func updateToolBar() {
        guard photoPickerController.allowMultipleSelection else { return }
        sendBarItem.enabled = (selectedAssets.count != 0)
        toolbarNumberView.number = selectedAssets.count
    }
    
    func updateHighQualityImageSize() {
        guard toolbarHighQualityButton.checked else { return }
        var size: Int = 0
        selectedAssets.forEach { (asset) -> () in
            let options = PHImageRequestOptions()
            options.synchronous = true
            PHImageManager.defaultManager().requestImageDataForAsset(asset, options: options, resultHandler: { (imageData, dataUTI, orientation, info) -> Void in
                if let data = imageData {
                    size += data.length
                }
            })
        }
        self.toolbarHighQualityButton.highqualityImageSize = size
    }

    func isVideoAsset(indexPath: NSIndexPath?) -> Bool {
        guard let _ = indexPath, asset = assetsFetchResults[indexPath!.item] as? PHAsset else { return false }
        return asset.mediaType == .Video
    }

    func showVideoSelectAlert() {
        guard !photoPickerController.hasShowVideoAlert else { return }
        let alertController = UIAlertController(title: nil, message: localizedString["PhotoPicker.VideoSelect.Alert"] ?? "", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: localizedString["PhotoPicker.OK"], style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)
        photoPickerController.hasShowVideoAlert = true
    }
}

//MARK: - collection view help method
extension AssetsViewController {
    func fillCell(cell: AssetCell, forIndexPath indexPath: NSIndexPath) {
        cell.tag = indexPath.item
        
        let asset = assetsFetchResults[indexPath.item] as! PHAsset
        let itemSize = (collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        let targetSize = itemSize.scale(traitCollection.displayScale)
        cell.overlayView.hidden = !photoPickerController.allowMultipleSelection
        
        imageManager.requestImageForAsset(asset,
            targetSize: targetSize,
            contentMode: .AspectFill,
            options: nil) { (image, info) -> Void in
                guard let image = image where cell.tag == indexPath.item else { return }
                cell.imageView.image = image
        }
        
        if asset.mediaType == .Video {
            cell.videoIndicatorView.hidden = false
            
            let minutes = Int(asset.duration / 60.0)
            let seconds = Int(ceil(asset.duration - 60.0 * Double(minutes)))
            cell.videoIndicatorView.timeLabel.text = String(format: "%02ld:%02ld", minutes, seconds)
            
            if asset.mediaSubtypes == .VideoHighFrameRate {
                cell.showSlomoIcon()
            } else {
                cell.showVideoIcon()
            }
        } else {
            cell.videoIndicatorView.hidden = true
        }
    }
    
    func isMaximumSelectionReached() -> Bool {
        let minimumNumberOfSelection = max(1, photoPickerController.minimumNumberOfSelection)
        
        if minimumNumberOfSelection <= photoPickerController.maximumNumberOfSelection {
            return photoPickerController.maximumNumberOfSelection <= selectedAssets.count
        } else {
            return false
        }
    }
    
    func isMinimumSelectionFullfilled() -> Bool {
        return photoPickerController.minimumNumberOfSelection <= selectedAssets.count
    }
    
    func isAutoDeselectEnable() -> Bool {
        return photoPickerController.maximumNumberOfSelection == 1 && photoPickerController.maximumNumberOfSelection >= photoPickerController.minimumNumberOfSelection
    }
    
    func showMaximumSelectionReachedAlert() {
        let maximumNumberOfSelection = photoPickerController.maximumNumberOfSelection
        let alertController = UIAlertController(title: nil, message: String(format: localizedString["PhotoPicker.MaximumNumberOfSelection.Alert"]!, maximumNumberOfSelection), preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: localizedString["PhotoPicker.Cancel"], style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        navigationController?.presentViewController(alertController, animated: true, completion: nil)
    }
}

//MARK: - asset help method
extension AssetsViewController {
    
    func updateFetchRequest() {
        guard let assetCollection = assetCollection else {
            assetsFetchResults = nil
            return
        }
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        switch photoPickerController.mediaType {
        case .Image:
            fetchOptions.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.Image.rawValue)
        case .Video:
            fetchOptions.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.Video.rawValue)
        default:
            break
        }
        
        assetsFetchResults = PHAsset.fetchAssetsInAssetCollection(assetCollection, options: fetchOptions)
    }
    
    func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
        previousPreheatRect = CGRectZero
    }
    
    func updateCachedAssets() {
        guard isViewLoaded(), let _ = view.window, let collectionView = self.collectionView else { return }
        
        // The preheat window is twice the height of the visible rect.
        var preheatRect = collectionView.bounds
        preheatRect = CGRectInset(preheatRect, 0.0, -0.5 * CGRectGetHeight(preheatRect))
        
        /*
        Check if the collection view is showing an area that is significantly
        different to the last preheated area.
        */
        let delta = abs(CGRectGetMidY(preheatRect) - CGRectGetMidY(previousPreheatRect))
        
        if delta > (CGRectGetHeight(collectionView.bounds) / 3.0) {
            var addedIndexPaths: [NSIndexPath] = []
            var removedIndexPaths: [NSIndexPath] = []
            
            computeDifferenceBetweenRect(previousPreheatRect, andRect: preheatRect,
                removedHandler: { (removedRect) -> Void in
                    guard let indexPaths = collectionView.pp_indexPathsForElementsInRect(removedRect) else { return }
                    removedIndexPaths.appendContentsOf(indexPaths)
                }, addedHandler: { (addedRect) -> Void in
                    guard let indexPaths = collectionView.pp_indexPathsForElementsInRect(addedRect) else { return }
                    addedIndexPaths.appendContentsOf(indexPaths)
            })
            
            let itemSize = (collectionViewLayout as! UICollectionViewFlowLayout).itemSize
            let targetSize = itemSize.scale(traitCollection.displayScale)
            
            if let assetsToStartCaching = assetsAtIndexPaths(addedIndexPaths) {
                imageManager.startCachingImagesForAssets(assetsToStartCaching,
                    targetSize: targetSize,
                    contentMode: .AspectFill,
                    options: nil)
            }
            
            if let assetsToStopCaching = assetsAtIndexPaths(removedIndexPaths) {
                imageManager.stopCachingImagesForAssets(assetsToStopCaching,
                    targetSize: targetSize,
                    contentMode: .AspectFill,
                    options: nil)
            }
            
            previousPreheatRect = preheatRect
        }
        
    }
    
    func computeDifferenceBetweenRect(oldRect: CGRect, andRect newRect: CGRect, removedHandler: (removedRect: CGRect) -> Void, addedHandler: (addedRect: CGRect) -> Void) {
        if CGRectIntersectsRect(oldRect, newRect) {
            let oldMaxY = CGRectGetMaxY(oldRect)
            let oldMinY = CGRectGetMinY(oldRect)
            let newMaxY = CGRectGetMaxY(newRect)
            let newMinY = CGRectGetMinY(newRect)
            
            if newMaxY > oldMaxY {
                let rectToAdd = CGRect(x: newRect.origin.x, y: oldMaxY, width: newRect.size.width, height: (newMaxY - oldMaxY))
                addedHandler(addedRect: rectToAdd)
            }
            
            if oldMinY > newMinY {
                let rectToAdd = CGRect(x: newRect.origin.x, y: newMinY, width: newRect.size.width, height: (oldMinY - newMinY))
                addedHandler(addedRect: rectToAdd)
            }
            
            if newMaxY < oldMaxY {
                let rectToRemove = CGRect(x: newRect.origin.x, y: newMaxY, width: newRect.size.width, height: (oldMaxY - newMaxY))
                removedHandler(removedRect: rectToRemove)
            }
            
            if oldMinY < newMinY {
                let rectToRemove = CGRect(x: newRect.origin.x, y: oldMinY, width: newRect.size.width, height: (newMinY - oldMinY))
                removedHandler(removedRect: rectToRemove)
            }
        } else {
            addedHandler(addedRect: newRect)
            removedHandler(removedRect: oldRect)
        }
    }
    
    func assetsAtIndexPaths(indexPaths: [NSIndexPath]) -> [PHAsset]? {
        guard indexPaths.count > 0 else { return nil }
        
        var assets: [PHAsset] = []
        for indexPath in indexPaths {
            guard indexPath.item < assetsFetchResults.count else { break }
            let asset: PHAsset = assetsFetchResults[indexPath.item] as! PHAsset
            assets.append(asset)
        }
        
        return assets
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension AssetsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var numberOfColumns: Int = 0
        switch (currentDevice, currentOrientation) {
        case (.Phone, .Landscape):
            numberOfColumns = AssetsNumberOfColumns.LandscapePhone
        case (.Phone, .Portrait):
            numberOfColumns = AssetsNumberOfColumns.PortraitPhone
        case (.Pad, .Landscape):
            numberOfColumns = AssetsNumberOfColumns.LandscapePad
        case (.Pad, .Portrait):
            numberOfColumns = AssetsNumberOfColumns.PortraitPad
        default:
            numberOfColumns = AssetsNumberOfColumns.LandscapePhone
        }
        
        let width: CGFloat = (CGRectGetWidth(view.frame) - 2.0 * CGFloat(numberOfColumns - 1)) / CGFloat(numberOfColumns)
        
        return CGSize(width: width, height: width)
    }
}

extension AssetsViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(changeInstance: PHChange) {
        guard let collectionChanges = changeInstance.changeDetailsForFetchResult(self.assetsFetchResults) else { return }
        
        dispatch_async(dispatch_get_main_queue()) { [unowned self]() -> Void in
            self.assetsFetchResults = collectionChanges.fetchResultAfterChanges
            
            if collectionChanges.hasIncrementalChanges || collectionChanges.hasMoves {
                self.collectionView?.reloadData()
            } else {
                self.collectionView?.performBatchUpdates({ () -> Void in
                    if let removedIndexes = collectionChanges.removedIndexes where removedIndexes.count > 0 {
                        self.collectionView?.deleteItemsAtIndexPaths(removedIndexes.pp_indexPathsFromIndexesInSection(0))
                    }
                    
                    if let insertedIndexes = collectionChanges.insertedIndexes where insertedIndexes.count > 0 {
                        self.collectionView?.insertItemsAtIndexPaths(insertedIndexes.pp_indexPathsFromIndexesInSection(0))
                    }
                    
                    if let changedIndexes = collectionChanges.changedIndexes where changedIndexes.count > 0 {
                        self.collectionView?.reloadItemsAtIndexPaths(changedIndexes.pp_indexPathsFromIndexesInSection(0))
                    }
                    }, completion: nil)
            }
            
            self.resetCachedAssets()
        }
    }
}
