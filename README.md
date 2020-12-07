# AdmiroSDK

## Requirements: 
===========

* XCode 11.0+ ([latest](https://developer.apple.com/xcode/))


## Quickstart:
The `Demo` project can be found at root folder and `Admiro.xxframework` can be found in the `Release` directory.  `Demo` project is the Swift example.

Open the Example in Xcode, and be sure to allow the permissions to access the camera. The example produce output of the selfie image and bounding box related to face coordinates. 

Don't forget to add permissions to your application.

* Privacy - Camera Usage Description (For using camera)
* Privacy - Photo Library Additions Usage Description (To save captured selfies)
* Privacy - Photo Library Usage Description - Optional (To display saved selfies from photo album)

## Integrating the SDK into your own application


To integrate `Admiro` into your Xcode project using CocoaPods, specify it in your Podfile:

```
source '../AdmiroSDK'
platform :ios, '11.0'
use_frameworks!

target '<Your Target Name>' do
	pod 'Admiro'
end
```

## XCFramework
Please use script build.sh to generate binary `Admiro.xcframework` archive that you can use as a dependency in Xcode.

`Admiro.xcframework` is a Release (Optimized) binary that offer best available Swift code performance.


## Usage

First import library by

`import Admiro`


### Option 1
Extend your viewcontroller from `ADCameraViewController` than you can get the event that ADCameraViewControllerDelegate. This gives you the opportunity to get the selfie image to present in to a screen. 

```
extension CameraController: ADCameraViewControllerDelegate {

    func cameraViewController(didFocus point: CGPoint) {

    }
    
	...    
    func cameraViewController(captured image: UIImage) {
        self.showFilterController(image: image)
    }
  	...
}
```

### Options 2: 

```
let ViewController = ADCameraViewController()
present(ViewController, animated: true, completion: nil)
```

