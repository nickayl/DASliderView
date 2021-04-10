//
//  LayoutManagers.swift
//  Bookka
//
//  Created by Domenico Aiello on 05/04/21.
//

import Foundation
import UIKit

public class LayoutManager {

    fileprivate var position: Int {
        set { sliderView.position = newValue }
        get { sliderView.position }
    }
    
    fileprivate var items: [DAItemView] { sliderView.items }
    fileprivate var delegate: DASliderViewDelegate? { sliderView.delegate }
    fileprivate var minimumDragToScroll:CGFloat { sliderView.minimumDragToScroll }

    
    public internal(set) var sliderView: DASliderView!
    public var type: DASliderViewLayoutManager {
        return .centered
    }
    
    fileprivate var lastItemPosition: [CGPoint]!
    
    fileprivate lazy var allSizes: [CGSize] = {
        var sizes = [CGSize]()
        
        for i in 0 ..< sliderView.dataSource!.numberOfItems(of: sliderView) {
            sizes.append(sliderView.dataSource!.sizeForItem(at: i, sliderView: sliderView))
        }
        return sizes
    }()
    
    fileprivate var rootView: UIView {
        var view: UIView? = sliderView
        
        while true {
            if view?.superview != nil {
                view = view?.superview
            } else { return view! }
        }
    }
    
    fileprivate var sliderViewWidth: CGFloat {
        sliderView.frame.size.width
    }
    
    fileprivate init() {}
    
    fileprivate func direction(of translation: CGPoint) -> DASliderViewDirection {
        translation.x > 0 ? .left : .right
    }

    fileprivate func itemSize(at position: Int) -> CGSize {
        sliderView.dataSource!.sizeForItem(at: position, sliderView: sliderView)
    }
    
    fileprivate func itemWidth(at position: Int) -> CGFloat {
        itemSize(at: position).width
    }
    
    internal func applyLayout(position: Int) { }
    internal func performScroll(to direction: DASliderViewDirection,
                               ofQuantity quantity: Int,
                               animated: Bool = true) { }
    
    func scrollBegan() {
        lastItemPosition = items.map { $0.view.center }
    }
    
    func scrollChanged(_ translation: CGPoint) {
        dragItemView(translation)
    }
    
    func scrollEnded(_ translation: CGPoint) {
        if( (abs(translation.x) < (minimumDragToScroll)) ||
            (position == items.count-1 && translation.x < 0) ||
            (position == 0 && translation.x > 0) ) {
            cancelScroll()
        }
        else {
            performScroll(to: direction(of: translation), ofQuantity: 1)
        }
    }
    
     func scrollTo(_ position: Int, animated: Bool = true) {
        lastItemPosition = items.map { $0.view.center }
        performScroll(to: (position < self.position) ? .left : .right,
                      ofQuantity: abs(self.position - position), animated: animated)
    }
    
    func cancelScroll() {
        UIView.animate(withDuration: 0.2) {
            for i in 0 ..< self.items.count {
                self.items[i].view.center = CGPoint(x: self.lastItemPosition[i].x, y: self.lastItemPosition[i].y)
            }
        }
    }
    
    func dragItemView(_ translation: CGPoint) {
        for i in 0 ..< items.count { // When the user moves the finger, we are in the changed state.
            let point = lastItemPosition[i]
            
            if abs(translation.x) > abs(translation.y) {
                let newCenter = CGPoint(x: point.x + translation.x, y: point.y)
                items[i].view.center = newCenter
            }
        }
    }
}

public class LeftBoundItemLayoutManager : LayoutManager {

    public static let defaultLeftMargin = CGFloat(25)
    public static let defaultInitialMargin = CGFloat(0)
    
    public var initialMargin: CGFloat = defaultInitialMargin
    public var leftMargin: CGFloat = defaultLeftMargin
    
    override public var type: DASliderViewLayoutManager {
        return .centered
    }
    
    private func movingFactor(at position: Int) -> CGFloat {
        return itemWidth(at: position) + leftMargin
    }
    
    public init(withInitialMargin: CGFloat = defaultInitialMargin,
                       leftMargin: CGFloat = defaultLeftMargin) {
        super.init()
        self.initialMargin = withInitialMargin
        self.leftMargin = leftMargin
    }
    
    public override init() {
        super.init()
    }
    
    override func applyLayout(position: Int) {
        
        var precedingItem: DAItemView!
        
        for i in 0 ..< items.count {
            
            let item = items[i]
            let size = itemSize(at: i)
            //items.append(item)
            
            let x: CGFloat
            if i == 0 {
                x = initialMargin
            }
            else {
                let precX = precedingItem.view.frame.origin.x
                x = precX + movingFactor(at: i-1)
            }
            
            item.view.frame = CGRect(x: x, y: 0, width: size.width, height: size.height)
            item.view.tag = i
            precedingItem = item
            
        }
        
        lastItemPosition = items.map { $0.view.center }
        //self.position = position
        scrollTo(position, animated: sliderView.animationEnabled)
    }
    
    override func performScroll(to direction: DASliderViewDirection,
                               ofQuantity quantity: Int,
                               animated: Bool = true) {
        
        for i in 0 ..< self.items.count {
            
            let point: CGPoint
            let startingPoint = self.lastItemPosition[i]
            
            //let max = CGFloat( allSizes.map { Float($0.width) }.max()! )
            
            switch direction {
                case .left:
                    let w = itemSize(at: position-1).width
                    point = CGPoint(x: startingPoint.x + (w + leftMargin) * CGFloat(quantity) , y: startingPoint.y)
//                    point = CGPoint(x:startingPoint.x + self.movingFactor * CGFloat(quantity),
//                                    y: startingPoint.y)
                case .right:
                    let w = itemSize(at: position).width
                    point = CGPoint(x: startingPoint.x - (w + leftMargin) * CGFloat(quantity) , y: startingPoint.y)
                    //point = CGPoint(x:startingPoint.x - self.movingFactor * CGFloat(quantity), y: startingPoint.y)
            }
            
            if animated {
                UIView.animate(withDuration: 0.2) { self.items[i].view.center = point }
            } else {
                self.items[i].view.center = point
            }
        }
        
        // position += (direction == .left ? -1 : 1) * quantity
        position += direction.rawValue * quantity
        delegate?.sliderViewDidSelect?(item: items[position], at: position, sliderView: sliderView)
        //print("Scrolled to position: \(currentPosition)")
    }
    
}

public class CenteredItemLayoutManager : LayoutManager {
    
    public static let defaultPreview = CGFloat(25)
    public var preview = CenteredItemLayoutManager.defaultPreview
    
    private func movingFactor(at position: Int) -> CGFloat {
        return (sliderViewWidth / 2)
            + (itemWidth(at: position)/2)
            - preview
    }
    
    public init(withPreview preview: CGFloat) {
        super.init()
        self.preview = preview
    }
    
    override public init() { super.init() }
    
    override func applyLayout(position: Int) {
        
        var precedingItem: DAItemView!
        
        print("superview width: \(rootView.frame.width) sliderView width: \(sliderView.frame.width) bounds=\(sliderView.bounds)")
        
        for i in 0 ..< items.count {
            
            let item = items[i]
            let size = itemSize(at: i)
            //items.append(item)
            
            let x: CGFloat
            if i == 0 {
                x = (sliderView.frame.size.width/2) - (size.width/2)
            }
            else {
                let precX = precedingItem.view.frame.origin.x
                x = precX + movingFactor(at: i-1)
            }
            
            item.view.frame = CGRect(x: x, y: 0, width: size.width, height: size.height)
            item.view.tag = i
            precedingItem = item
        }
        
        lastItemPosition = items.map { $0.view.center }
        //self.position = position
        scrollTo(position, animated: sliderView.animationEnabled)
    }
    
    
    
    override func performScroll(to direction: DASliderViewDirection,
                               ofQuantity quantity: Int,
                               animated: Bool = true) {
        
        for i in 0 ..< self.items.count {
            
            let point: CGPoint
            let startingPoint = self.lastItemPosition[i]
            
            switch direction {
                case .left:
                    point = CGPoint(x:startingPoint.x + self.movingFactor(at: i) * CGFloat(quantity), y: startingPoint.y)
                case .right:
                    point = CGPoint(x:startingPoint.x - self.movingFactor(at: i) * CGFloat(quantity), y: startingPoint.y)
            }
            
            if animated {
                UIView.animate(withDuration: 0.2) { self.items[i].view.center = point }
            } else {
                self.items[i].view.center = point
            }
        }
        
        position += direction.rawValue * quantity
        delegate?.sliderViewDidSelect?(item: items[position], at: position, sliderView: sliderView)
        //print("Scrolled to position: \(currentPosition)")
    }
    
}

//internal protocol LayoutManagerInternal {
//
//    func scrollBegan()
//    func scrollChanged(_ translation: CGPoint)
//    func scrollEnded(_ translation: CGPoint)
//    func applyLayout(position: Int)
//    func scrollTo(_ position: Int, animated: Bool)
//    func dragItemView(_ translation: CGPoint)
//    func cancelScroll()
//    func performScroll(to direction: DASliderViewDirection,
//                               ofQuantity quantity: Int,
//                               animated: Bool)
//
//    var movingFactor: CGFloat { get }
//    var position: Int { get set }
//    var items: [DAItemView] { get }
//    var properties: [String:CGFloat] { get }
//    var type: DASliderViewLayoutManager { get }
//}

//    enum LayoutManagerError : Error {
//        case NotImplementedError
//        case AbstractClassCannotBeInstantiated
//    }
