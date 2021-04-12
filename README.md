# DASliderView

![Cocoapods platforms](https://img.shields.io/cocoapods/p/DASliderView.svg?color=%23fb0006)
![Cocoapods](https://img.shields.io/badge/language-swift%205.0-red.svg)
![Cocoapods](https://img.shields.io/cocoapods/v/DASliderView.svg?color=green)
![Maintenance](https://img.shields.io/maintenance/yes/2021.svg)
![Cocoapods](https://img.shields.io/cocoapods/l/DASliderView.svg)

An nice and clean way to display your views as a set of sliding views. 
Easy to use: requires only little configuration and you are ready to start!

<!-- <img src="https://github.com/cyclonesword/DASliderView/blob/master/screen1.png?raw=true" width="276" height="598"> -->
<img src="https://github.com/cyclonesword/DASliderView/blob/master/appVideo.gif?raw=true" width="276" height="598">    <img src="https://github.com/cyclonesword/DASliderView/blob/master/appVideo2.gif?raw=true" width="276">

## Requirements

* iOS 9.0+
* Swift 5.0
* ARC

## Installation
### CocoaPods

Just add the DASliderView dependency to your Podfile:
```cocoapods
  pod 'DASliderView'
  use_frameworks!
```
And then in your terminal (positioned in the same directory of your project's Podfile) run ```pod install``` 

### Carthage
Carthage support will be soon available

## Usage
### Quick Start Guide

In the view you want to display the SliderView, set the custom class as  **```DASliderView```** :
<center><img src="https://github.com/cyclonesword/DASliderView/blob/master/Screenshot%202021-04-06%20at%2016.33.53.png?raw=true"></center>

Don't forget to bind the DASliderView view with an outlet inside your custom ViewController class.

Then in your ViewController, you need to implement at least the ```DASliderViewDataSource``` class, but i highly recommend to bind also the ```DASliderViewDelegate``` to receive notification when the user perform various operations (such us when the user scrolls to the previous or next view , when the user taps on the view etc)
```swift
class MyViewController : UIViewController, DASliderViewDelegate, DASliderViewDataSouce { 
    
    // The core of the library: The DASliderView class
    @IBOutlet var sliderView: DASliderView!
    // In this example i use the sliderView inside a UIScrollView
    @IBOutlet var scrollView: UIScrollView!
	...
}
```

In your **viewDidLoad** set the **dataSource** and(optionally) the delegate, and finally call the **initialize** method
as shown in this example:
```swift
...
var data: [DAItemView] // The data array for the sliderview.
let size = CGSize(width: 150, height: 200) // The size of the views. Can be different for every view.
...
override func viewDidLoad() {
	
	// Assign the dataSource and the delegate. 
	// The delegate is optional but the datSource must be provided, 
	// otherwise the sliderView will show nothing.
	sliderView.dataSource = self
	sliderView.delegate = self
	
	// Enable the  parent scrollView to intercept touch events (see below for more info on this)
	sliderView.parentViewInterceptingTouchEvents = scrollView
	
	// If you want to customize the layout manager and its properties:
	sliderView.layoutManager = LeftBoundItemLayoutManager(withInitialMargin: 25.0)
	// Or...
	sliderView.layoutManager = CenteredItemLayoutManager(withPreview: 30)
	
	// Initialize the sliderView at position 0 (default) 
	// with the provided layout manager. If you do not set a layout manager, 
	// the default CenteredItemLayoutManager will be used, with its default values.
	// See below for more info on the layout managers
	sliderView.initialize()
	...
}
```

### Layout Manager
The SliderView has 2 built-in layout manager that handles how the views must be initially positioned and how they should scroll in response to the user touch events.

 -  **`CenteredItemLayoutManager`** (default) :  Displays the items starting from the sliderView's center.  The other views are previewed at the left and right bounds of the sliderView. At position 0, there's no left item. 
 You can adjust the items position using the **`preview`** property.  With this property you can specify the amount of pixels(in points) a view should be visible starting from the left or right bounds.
 
 - **`LeftBoundItemLayoutManager`**:  Displays the items starting from left. You can adjust the items position using the **`initialMargin`** and **`leftMargin`** properties.

For all layout manager the property **`minDragToScroll`** specify how much pixels(in points) the user must drag to trigger a left or right scrolling event.

### DataSource and Delegate
You must implement the DASliderViewDataSource to make the SliderView work properly:

```swift
func viewForItem(at position: Int, recycling convertView: DAItemView?, sliderView: DASliderView) -> DAItemView {

	if let itemView = convertView {
		let imageView = itemView.view as! UIImageView
		imageView.image = images[position]

		return itemView
	} else {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFit
		imageView.image = data[position]
		imageView.isUserInteractionEnabled = true

		// Here 'ImageItem' is simply a subclass of DAItemViewImpl. It is a
		// convenient class meant for subclassing, but you can directly implement
		// the protocol DAItemView if you prefer.
		let item = ImageItem(name: "Image\(position)", view: imageView, position: position)
		return item
	}
}

func numberOfItems(of sliderView: DASliderView) -> Int {
	return data.count
}

func sizeForItem(at position: Int, sliderView: DASliderView) -> CGSize {
	return size
}
```

If you want to implement also the DASliderViewDelegate :
```swift
func sliderViewDidSelect(item: DAItemView, at position: Int, sliderView: DASliderView) {
	let itm = item as! ImageItem
	print("Selected item with position \(position) - \(itm.position) and name \(itm.name)")
}

func sliderViewDidReceiveTapOn(item: DAItemView, at position: Int, sliderView: DASliderView) {
	print("Tapped item with position \(item.position)")
}

func sliderViewDidReceiveLongTouchOn(item: DAItemView, at position: Int, sliderView: DASliderView) {
	print("Received Long touch on item \(item)")
}

func sliderViewDidScroll(sliderView: DASliderView) {
	print("User is scrolling the sliderView...")
}

```
 
 ### Forward touch events to the parent UIScrollView
 If the `DASliderView`  is inside an other view that needs to intercept the touch events handled by the sliderView, such as the `UIScrollView`, you need to set the **`parentViewInterceptingTouchEvents`** property of `DASliderView`, as shown in this example:
 
```swift
class ViewController: UIViewController, DASliderViewDataSouce, DASliderViewDelegate {
	
	@IBOutlet var sliderView: DASliderView!
	@IBOutlet var scrollView: UIScrollView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		...
		sliderView.parentViewInterceptingTouchEvents = scrollView
	}
	...
}
 ```
 
 ## Contribution
 
Contributors are welcome! 
Since this is a brand new library, i hope someone will help me with the maintainance of the project and for the future feature releases.
