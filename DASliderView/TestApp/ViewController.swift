//
//  TestScrollViewViewController.swift
//  Bookka
//
//  Created by Domenico Aiello on 03/04/21.
//

import UIKit

class ImageItem : DAItemViewImpl {
    
    var name: String
    
    convenience init(name: String, view: UIView, position: Int) {
        self.init(view: view, position: position)
        self.name = name
    }
    
    public required init(view: UIView, position: Int) {
        self.name = "No name  \(position)"
        super.init(view: view, position: position)
    }
}

class ViewController: UIViewController,
                                      UIGestureRecognizerDelegate,
                                      DASliderViewDataSouce,
                                      DASliderViewDelegate {
    
    @IBOutlet var sliderView: DASliderView!
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
    
    let images = [ UIImage(named: "b2"), UIImage(named: "b3"), UIImage(named: "b1"), UIImage(named: "b4"), UIImage(named: "b5") ]
    let cards = [ UIImage(named: "series1"), UIImage(named: "series2"), UIImage(named: "series3"), UIImage(named: "series4"), UIImage(named: "series5") ]
    
    let cardsSize = CGSize(width: 280, height: 210)
    let imagesSize = CGSize(width: 150, height: 200)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sliderView.frame.size = CGSize(width: view.frame.width, height: view.frame.height)
        
        sliderView.dataSource = self
        sliderView.delegate = self
        
        sliderView.gestureRecognizerDelegate = self
        sliderView.superviewCanInterceptTouchEvents = true
        
//        sliderView.setItemsPadding(25)
//        sliderView.setMinimumDragToScroll(sliderView.frame.width/5)
        
        //try? sliderView.setPosition(newPosition: 1)
        
//        let props = [ sliderView.kPadding : CGFloat(20),
//                      sliderView.kMinDragToScroll : view.frame.width/4 ]
//        sliderView.layoutManager = .centered
        
        let props = [ sliderView.kMargin : CGFloat(25),
                      sliderView.kInitialMargin : CGFloat(10),
                      sliderView.kMinDragToScroll : view.frame.width/4 ]
        sliderView.layoutManager = .leftBound
        sliderView.animationEnabled = false
        sliderView.initialize(withPosition: 1, properties: props)
        sliderView.animationEnabled = true
        
        print("SliderView started at position: \(sliderView.currentPosition)")
    }
    
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
        //print("Scollllll")
    }
    
    func viewForItem(at position: Int, recycling convertView: DAItemView?, sliderView: DASliderView) -> DAItemView {
        
        if let itemView = convertView {
            let imageView = itemView.view as! UIImageView
            imageView.image = images[position]
            
            return itemView
            
        } else {
            let imageView = UIImageView()
            
            imageView.contentMode = .scaleAspectFit
            imageView.image = images[position]
            //imageView.image = cards[position]
            imageView.backgroundColor = .black
            imageView.isUserInteractionEnabled = true
            
            let item = ImageItem(name: "Image\(position)", view: imageView, position: position)
            return item
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func numberOfItems(of sliderView: DASliderView) -> Int {
        return images.count
        //return cards.count
    }
    
    
    func sizeForItem(at position: Int, sliderView: DASliderView) -> CGSize {
        return imagesSize
        //return cardsSize
    }
    
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
