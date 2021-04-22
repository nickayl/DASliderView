//
//  TestScrollViewViewController.swift
//  Bookka
//
//  Created by Domenico Aiello on 03/04/21.
//

import UIKit

class ImageItem : DAView {
    
    var name: String = "no name"

    init(name: String = "", view: UIView, size: CGSize? = nil) {
        super.init(view: view, size: size)
        self.name = name
    }

}

class ViewController: UIViewController, DASliderViewDataSouce, DASliderViewDelegate {
    
    var sliderView: DASliderView!
    var sliderView2: DASliderView!
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet weak var positionTextField: UITextField!
    @IBOutlet weak var goToPosition: UIButton!
    @IBOutlet weak var animatedSwitch: UISwitch!
    
    @IBOutlet var leftButton: UIButton!
    @IBOutlet var rightButton: UIButton!
    
    @IBAction func goToPositionAction(_ sender: Any) {
        try? sliderView.setPosition(newPosition: Int(positionTextField.text ?? "0") ?? 0,
                                    animated: animatedSwitch.isOn)
    }
    
    @IBAction func goLeft(_ sender: Any) {
        try? sliderView.setPosition(newPosition: sliderView.currentPosition-1, animated: animatedSwitch.isOn)
    }
    
    @IBAction func goRight(_ sender: Any) {
        try? sliderView.setPosition(newPosition: sliderView.currentPosition+1, animated: animatedSwitch.isOn)
    }
    
    var images = [ UIImage(named: "b2"), UIImage(named: "b3"), UIImage(named: "b1"), UIImage(named: "b4"), UIImage(named: "b5") ]
    let cards = [ UIImage(named: "series1"), UIImage(named: "series2"), UIImage(named: "series3"), UIImage(named: "series4"), UIImage(named: "series5") ]
    
    let cardsSize = CGSize(width: 280, height: 210)
    let imagesSize = CGSize(width: 150, height: 200)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sliderView = DASliderView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 220))
        sliderView2 = DASliderView(frame: CGRect(x: 0, y: sliderView.frame.origin.y + 220, width: view.frame.width, height: 220))
        
        scrollView.contentSize = CGSize(width: view.frame.width, height: 1200)
        scrollView.isExclusiveTouch = false
        scrollView.canCancelContentTouches = false
        
        sliderView.frame.size = CGSize(width: view.frame.width, height: view.frame.height)
        //try? sliderView.setPosition(newPosition: 1)
        
        sliderView.dataSource = self
        sliderView.delegate = self
        sliderView.layoutManager = CenteredItemLayoutManager(withPreview: 30)
        sliderView.parentViewInterceptingTouchEvents = scrollView
        sliderView.initialize(withPosition: 0)
        
        sliderView2.layoutManager = LeftBoundItemLayoutManager(withInitialMargin: 25.0)
        sliderView2.dataSource = self
        sliderView2.delegate = self
        sliderView2.parentViewInterceptingTouchEvents = scrollView
        sliderView2.minimumDragToScroll = sliderView2.frame.size.width / 8
        sliderView2.initialize()
        
        scrollView.addSubview(sliderView)
        scrollView.addSubview(sliderView2)
        
        print("SliderView started at position: \(sliderView.currentPosition)")
        
        print("Waiting 3 seconds...")
        
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 2) {
            DispatchQueue.main.async {
                self.images.insert(UIImage(named: "b3_ds.jpg"), at: 1)
                print("Adding item at position 1")
                //self.sliderView2.reloadData()
                self.sliderView2.notifyItemInserted(atIndex: 1)
            }
        }
        
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 3) {
            DispatchQueue.main.async {
                self.images.insert(UIImage(named: "b4_ds.jpg"), at: 1)
                print("Adding item at position 1")
                //self.sliderView2.reloadData()
                self.sliderView2.notifyItemInserted(atIndex: 1)
            }
        }
//        DispatchQueue.init(label: "myBlock").asyncAfter(deadline: .now() + 3) {
//            DispatchQueue.main.async {
//
//            }
//        }
        
    }
    
    func sliderViewDidSelect(item: DAView, at position: Int, sliderView: DASliderView) {
        //let itm = item as! ImageItem
        print("Selected item with position \(position) - \(item.position) and name \((item as! ImageItem).name)")
    }
    
    func sliderViewDidReceiveTapOn(item: DAView, at position: Int, sliderView: DASliderView) {
        print("Tapped item with position \(item.position)")
    }
    
    func sliderViewDidReceiveLongTouchOn(item: DAView, at position: Int, sliderView: DASliderView) {
        print("Received Long touch on item \(item)")
    }
    
    func sliderViewDidScroll(sliderView: DASliderView) {
        print("Scroll...")
    }
    
    func viewForItem(at position: Int, recycling convertView: DAView?, sliderView: DASliderView) -> DAView {
        
//        if let itemView = convertView {
//
//            let imageView = itemView.view as! UIImageView
//            imageView.image = images[position]
//
//            return ImageItem(view: imageView, size: imagesSize)
//
//        } else {
            let imageView = UIImageView()
            
            imageView.contentMode = .scaleAspectFit
            imageView.backgroundColor = UIColor.black
            imageView.image = images[position]
            //imageView.image = cards[position]
            imageView.backgroundColor = .black
            imageView.isUserInteractionEnabled = true
            
            let size: CGSize
            
            if position == 0 {
                size = CGSize(width: 200, height: 200)
            } else {
                size = imagesSize
            }
            imageView.frame.size = size
            //let item = ImageItem(name: "Image\(position)", view: imageView, size: size)
            let item = ImageItem(name: "Image\(position)", view: imageView)
            //item.size = imagesSize
            return item
            //return imageView
        //}
    }
      
    func numberOfItems(of sliderView: DASliderView) -> Int {
        return images.count
        //return cards.count
    }
    
    
//    func sizeForItem(at position: Int, sliderView: DASliderView) -> CGSize {
//        if position == 0 {
//            return CGSize(width: 200, height: 200)
//        } else {
//            return imagesSize
//        }
//        //return cardsSize
//    }
//
    
//    func paddingForItem(at position: Int, of sliderView: DASliderView) -> CGFloat {
//        if position == 3 {
//            return 35.0
//        }
//        
//        return 12.5
//    }
    
    //    func gestureRecognizerDelegate() -> UIGestureRecognizerDelegate {
    //        return self
    //    }
    //
    //    func allowInterceptTouchEventsForView() -> UIView {
    //        return scrollView
    //    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
