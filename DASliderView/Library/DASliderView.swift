//
//  DASliderView.swift
//  Bookka
//
//  Created by Domenico Aiello on 04/04/21.
//

import Foundation
import UIKit

//public protocol DAItemView : AnyObject {
//    var view: UIView { get }
//    var position: Int { get }
//
//    init(view: UIView, position: Int)
//}

public class DAItemView : NSObject {
    
    // Public getters properties
    public let view: UIView
    public private(set) var position: Int
    
    public override var description: String {
        return "\(String(describing: type(of: self)))(view: \(view), \n position: \(position)"
    }
    
    public var size: CGSize = .zero
    public var width: CGFloat { size.width }
    public var height: CGFloat { size.height }
    
    // private properties
    internal private(set) var coordinates: CGPoint = CGPoint.zero
    
    internal init(view: UIView, position: Int) {
        self.view = view
        self.position = position
    }
    
    internal func translate(toPoint: CGPoint) {
        view.center = toPoint
        saveCurrentLocation()
    }
    
    internal func translate(x: CGFloat, y: CGFloat? = nil) {
        translate(toPoint: CGPoint(x: x, y: y ?? view.center.y))
    }
    
    internal func saveCurrentLocation() {
        coordinates = view.center
    }
    
    internal func restorePreviousLocation() {
        view.center = coordinates
    }
    
    internal func move(xQuantity: CGFloat = 0, yQuantity: CGFloat = 0) {
        //(coordinates.x, coordinates.y) = (xQuantity, yQuantity)
        view.center.x = coordinates.x + xQuantity
        view.center.y = coordinates.y + yQuantity
    }
    
}

public enum DASliderViewProperty : String {
    case padding, margin, initialMargin, minDragToScroll
}

public enum DASliderViewError : Error {
    case positionOutOfBoundsError
    case dataSourceNotSetError
}

public enum DASliderViewDirection: Int {
    case left = -1, right = 1
}

public enum DASliderViewLayoutManager: Int {
    case centered, leftBound
}

public protocol DASliderViewDataSouce {
    
    // Required function implementations
    func viewForItem(at position: Int, recycling convertView: DAItemView?, sliderView: DASliderView) -> UIView
    func sizeForItem(at position: Int, sliderView: DASliderView) -> CGSize
    func numberOfItems(of sliderView: DASliderView) -> Int
    
}

public protocol DASliderViewDelegate {
    func sliderViewDidScroll(sliderView: DASliderView)
    func sliderViewDidSelect(item: DAItemView, at position: Int, sliderView: DASliderView)
    func sliderViewDidReceiveTapOn(item: DAItemView, at position: Int, sliderView: DASliderView)
    func sliderViewDidReceiveLongTouchOn(item: DAItemView, at position: Int, sliderView: DASliderView)
}

extension DASliderViewDelegate { // Default empty implementation: so they are optional without the ugly
    func sliderViewDidScroll(sliderView: DASliderView) { }
    func sliderViewDidSelect(item: DAItemView, at position: Int, sliderView: DASliderView) { }
    func sliderViewDidReceiveTapOn(item: DAItemView, at position: Int, sliderView: DASliderView) { }
    func sliderViewDidReceiveLongTouchOn(item: DAItemView, at position: Int, sliderView: DASliderView) { }
}


// old stuff

//    internal func get(for sliderView: DASliderView) -> LayoutManager {
//        switch self {
//        case .centered:
//            return CenteredItemLayoutManager(with: sliderView)
//        case .leftBound:
//            return LeftBoundItemLayoutManager(with: sliderView)
//        }
//    }

// Optional function implementations
// @objc optional func paddingForItem(at position: Int, of sliderView: DASliderView) -> CGFloat
//@objc optional func scrollingAnimation(of sliderView: DASliderView) -> UIView.AnimationOptions
//@objc optional func amountOfPointsToPerformScroll(of sliderView: DASliderView) -> CGFloat

//@objc public protocol DASliderView {
//
//    var delegate: DASliderViewDelegate? { get set }
//    var dataSource: DASliderViewDataSouce? { get set }
//
//    var properties: [String : CGFloat] { get }
//    var currentPosition: Int { get }
//    var selectedItem: DAItemView { get }
//    var animationEnabled: Bool { get set }
//    // var parentView: UIView { get }
//    var layoutManager: DASliderViewLayoutManager { get set }
//    var superviewCanInterceptTouchEvents: Bool { get set }
//    var gestureRecognizerDelegate: UIGestureRecognizerDelegate? { get set }
//
//    func setPosition(newPosition: Int, animated: Bool) throws
//    func setItemsPadding(_ padding: CGFloat)
//    func setMinimumDragToScroll(_ amount: CGFloat)
//
//    func initialize()
//    func initialize(withPosition position: Int, properties: [String : CGFloat])
//}

