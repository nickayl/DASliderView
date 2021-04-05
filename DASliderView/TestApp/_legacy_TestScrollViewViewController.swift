//
//  TestScrollViewViewController.swift
//  Bookka
//
//  Created by Domenico Aiello on 03/04/21.
//

import UIKit

class TestScrollViewViewController1111: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet var sliderView: UIView!
    @IBOutlet var scrollView: UIScrollView!
    
    let images = [ UIImage(named: "b2"), UIImage(named: "b3"), UIImage(named: "b1") ]
    var imageViews = [UIImageView]()
    
    let sliderBookSize = CGSize(width: 150, height: 200)
    
    let padding = CGFloat(25)
    
    var movingFactor: CGFloat {
        return CGFloat(view.frame.width/2) - padding + CGFloat(sliderBookSize.width/2)
    }
    
    var currentPosition = 0
    var centers: [CGPoint]!
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc private func panGestureHandler(gestureRecognizer: UIPanGestureRecognizer) {
        
        let touchedView = gestureRecognizer.view!
        
        // Get the changes in the X and Y directions relative to
        // the superview's coordinate space.
        let translation = gestureRecognizer.translation(in: touchedView.superview)
        gestureRecognizer.delegate = nil
        //let velocity = gestureRecognizer.velocity(in: piece.superview)
        
       // print("fromScrollView=\(piece is UIScrollView), translation=\(translation), velocity=\(velocity)")
        
        func cancelScroll() {
            UIView.animate(withDuration: 0.2) {
                for i in 0 ..< self.imageViews.count {
                    self.imageViews[i].center = CGPoint(x: self.centers[i].x, y: self.centers[i].y)
                }
            }
        }
        
        func performScroll() {
            print("Scrolling to position: \(currentPosition+1)")
            
            UIView.animate(withDuration: 0.2) {
                for i in 0 ..< self.imageViews.count {
                    self.imageViews[i].center = getMove(self.centers[i], translation.x)
                }
            }
            
            currentPosition += translation.x > 0 ? -1 : 1
        }
        
        func getMove(_ startingPoint: CGPoint, _ delta: CGFloat) -> CGPoint {
            if delta > 0 {
                return CGPoint(x:startingPoint.x + movingFactor, y: startingPoint.y)
            } else {
                return CGPoint(x:startingPoint.x - movingFactor, y: startingPoint.y)
            }
        }
        
        func dragItemView() {
            
            for i in 0 ..< imageViews.count { // When the user moves the finger, we are in the changed state
                let point = centers[i]
                
                if abs(translation.x) > abs(translation.y) {
                    let newCenter = CGPoint(x: point.x + translation.x, y: point.y)
                    imageViews[i].center = newCenter
                }
            }
            
        }
        
        switch gestureRecognizer.state {
        
            case .began:  // Here is where the touch movement starts
                centers = imageViews.map { $0.center }
                
            case .changed:
                dragItemView()
                
            case .ended, .cancelled:
                print("ENDED")
                
                if abs(translation.x) >= (view.frame.width/4) {
                    
                    if( (currentPosition == imageViews.count-1 && translation.x < 0) ||
                        (currentPosition == 0 && translation.x > 0) ) {
                        cancelScroll()
                    }
                    else { performScroll() }
                } else { cancelScroll() }
                
                gestureRecognizer.delegate = self
                
            default:
                print("Invalid gesture state")
            
        }
        
            
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var precedingImageView: UIImageView?
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandler(gestureRecognizer:)))
        panGesture.delegate = self
       // scrollView.addGestureRecognizer(panGesture)
        sliderView.addGestureRecognizer(panGesture)
        
        
        for i in 0 ..< images.count {
            var imageView: UIImageView!
            
            if i == 0 {
                imageView = UIImageView(frame: CGRect(x: (view.frame.width/2) - (sliderBookSize.width/2),
                                                      y: 0,
                                                      width: sliderBookSize.width,
                                                      height: sliderBookSize.height))
            } else {
                let precX = precedingImageView!.frame.origin.x
                let rect = CGRect(x: precX + (view.frame.width/2) + (sliderBookSize.width/2) - padding,
                                  y: 0,
                                  width: sliderBookSize.width,
                                  height: sliderBookSize.height)
                imageView = UIImageView(frame: rect)
                
            }
            
            imageViews.append(imageView)
            precedingImageView = imageView
            imageView.contentMode = .scaleAspectFit
            imageView.image = images[i]
            imageView.backgroundColor = .black
            imageView.isUserInteractionEnabled = true
            sliderView.addSubview(imageView)
            //imageView.addGestureRecognizer(panGesture)
        }
        
        if currentPosition > 0 {
            for img in imageViews {
                img.center = CGPoint(x: img.center.x - (movingFactor * CGFloat(currentPosition)), y: img.center.y)
            }
        }
        
        print("STARTING position: \(currentPosition)")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
