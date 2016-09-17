## Features
A simple photo browser to display remote photos. [Kingfisher] (https://github.com/onevcat/Kingfisher) is used to download and cache images.
Support:

* Double-tap to zoom out & zoom in
* Device rotation
* Full screen mode
* Long press action
* Custom toolbar

## Installation

### Carthage
To integrate PhotoBrowser into your Xcode project using Carthage, specify it in your `Cartfile`:

``` bash
$ github "teambition/PhotoBrowser"
```

Then, run the following command to build the PhotoBrowser framework:

``` bash
$ carthage update
```

If Kingfisher is not used in your project, you have to **drag it your self into your project** from the [Carthage/Build] folder.

## Run Demo

``` bash
$ git clone git@github.com:teambition/PhotoBrowser.git
```
And then

``` bash
$ carthage update
```

## Usage

``` swift
import PhotoBrowser

let photoBrowser = PhotoBrowser

let photo = Photo.init(image: nil, thumbnailImage: thumbnail1, photoUrl: photoUrl1)
let photo2 = Photo.init(image: nil, thumbnailImage: thumbnail2, photoUrl: photoUrl2)
let photo3 = Photo.init(image: nil, thumbnailImage: thumbnail3, photoUrl: photoUrl3)

photoBrowser.photos = [photo, photo2, photo3]

```

Set **toolbarItems** property of UIViewController to custom toolbar:

``` swift
let item1 = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.Bookmarks, target: self, action: nil)
item1.tintColor = UIColor.blackColor()
photoBrowser.toolbarItem = [item1]
```

When no item specified, toolbar will hide itself.

Implement PhotoBrowserDelegate to receive images long press gesture:

``` swift
photoBrowser.photoBrowserDelegate = self

func longPressOn(photo: Photo, gesture: UILongPressGestureRecognizer) {
        guard let imageView = gesture.view as? UIImageView else {
            return
        }
        let alertController = UIAlertController.init(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let cancelAction = UIAlertAction.init(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        let saveAction = UIAlertAction.init(title: "Save", style: UIAlertActionStyle.Default) {[unowned self] (action) -> Void in
            if let image = imageView.image {
                self.saveToAlbum(image)
            }
        }
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        self.photoBrowser?.presentViewController(alertController, animated: true, completion: nil)
    }

```

## To-Do

* Support datasource to provide data
* Support Block-syntax for long press gesture

## License
PhotoBrowser is released under the MIT license. See LICENSE for details.

