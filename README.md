# PhotoPicker
A image picker for iOS , written by Swift.


## How To Get Started
### Carthage
Specify "PhotoPicker" in your Cartfile:
```
github "teambition/PhotoPicker"
```

### Usage
##### configuration  properties
```
// use this to fetch what type album you want
public var assetCollectionSubtypes: [PHAssetCollectionSubtype]?
// if you want to select more than 1 photo, set it to true
public var allowMultipleSelection: Bool

```

#####  Implement delegate
```
func photoPickerController(controller: PhotoPickerController, didFinishPickingAssets assets: [PHAsset], needHighQualityImage: Bool)
func photoPickerControllerDidCancel(controller: PhotoPickerController)
func photoPickerController(controller: PhotoPickerController, shouldSelectAsset asset: PHAsset) -> Bool
func photoPickerController(controller: PhotoPickerController, didSelectAsset asset: PHAsset)
func photoPickerController(controller: PhotoPickerController, didDeselectAsset asset: PHAsset)
```

##### Present PhotoPicker
```
let photoPickerController = PhotoPickerController()
photoPickerController.delegate = self
presentViewController(photoPickerController, animated: true, completion: nil)
```

## Similar
- [QBImagePicker](https://github.com/questbeat/QBImagePicker)(This framework is written by Objective-C)
- [Example app using Photos Framework](https://developer.apple.com/library/ios/samplecode/UsingPhotosFramework/Introduction/Intro.html)(Apple PhotoKit Sample Code)

## Minimum Requirement
- iOS 8.0

## Release Notes
- [Release Notes](https://github.com/teambition/PhotoPicker/releases)

## License
- GrowingTextView is released under the MIT license. See [LICENSE](https://github.com/teambition/PhotoPicker/blob/master/LICENSE) for details.

## More Info
- Have a question? Please [open an issue](https://github.com/teambition/PhotoPicker/issues/new)!
