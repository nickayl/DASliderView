//
//  LayoutManagers.swift
//  Bookka
//
//  Created by Domenico Aiello on 05/04/21.
//

import Foundation
import UIKit

public /*abstract*/ class LayoutManager {

    fileprivate var position: Int {
        set { sliderView.position = newValue }
        get { sliderView.position }
    }
    
    fileprivate var items: [DAItemView] { sliderView.items }
    fileprivate var delegate: DASliderViewDelegate? { sliderView.delegate }

    public internal(set) var sliderView: DASliderView!
    public private(set) var type: DASliderViewLayoutManager!
    
    fileprivate var sliderViewWidth: CGFloat {
        sliderView.frame.size.width
    }
    
    // Lack of abstract classes support leads to this ugly hacks
    fileprivate init() {} // No instance? No party.
    
    fileprivate func direction(of translation: CGPoint) -> DASliderViewDirection {
        translation.x > 0 ? .left : .right
    }
    
    func scrollBegan() { }
    
    func scrollChanged(_ translation: CGPoint) {
        dragItemView(translation)
    }
    
    func scrollEnded(_ translation: CGPoint, canScroll: Bool) {
        if canScroll {
            performScroll(to: direction(of: translation), ofQuantity: 1)
        } else { cancelScroll(translation) }
    }
    
    fileprivate func cancelScroll(_ translation: CGPoint) {
        UIView.animate(withDuration: 0.2) {
            self.items.forEach { $0.restorePreviousLocation() }
        }
    }
    
    fileprivate func dragItemView(_ translation: CGPoint) {
        if abs(translation.x) > abs(translation.y) {
            items.forEach { $0.move(xQuantity: translation.x) }
        }
    }
    
    func applyLayout() { fatalError("applyLayout not implemented") }
    func performScroll(to direction: DASliderViewDirection, ofQuantity quantity: Int = 1, animated: Bool = true) { fatalError("performScroll not implemented") }
    func insertItem(at index: Int, animated: Bool = true) { }
    func changeItem(at index: Int, newItem: DAItemView, oldItem: DAItemView, animated: Bool = true) { }
    func removeItem(at index: Int, animated: Bool = true) { }
//
    func scrollTo(_ position: Int, animated: Bool = true) {
        performScroll(to: (position < self.position) ? .left : .right,
                      ofQuantity: abs(self.position - position), animated: animated)
    }
    
    func scrollLeft(of quantity: Int = 1, animated: Bool = true) {
        performScroll(to: .left, ofQuantity: quantity, animated: animated)
    }
    
    func scrollRight(of quantity: Int = 1, animated: Bool = true) {
        performScroll(to: .right, ofQuantity: quantity, animated: animated)
    }
}

public class LeftBoundItemLayoutManager : LayoutManager {

    public static let defaultLeftMargin = CGFloat(25)
    public static let defaultInitialMargin = CGFloat(0)
    
    public var initialMargin: CGFloat = defaultInitialMargin
    public var leftMargin: CGFloat = defaultLeftMargin
    
    override public var type: DASliderViewLayoutManager! { .leftBound }
    
    private func movingFactor(for item: DAItemView) -> CGFloat {
        item.width + leftMargin
    }
    
    public init(withInitialMargin: CGFloat = defaultInitialMargin,
                       leftMargin: CGFloat = defaultLeftMargin) {
        super.init()
        self.initialMargin = withInitialMargin
        self.leftMargin = leftMargin
    }
    
    public override init() { super.init() }
    
    override func applyLayout() {
        
        items.forEach { item in
            
            let size = item.size
            let x: CGFloat
            
            if item.position == 0 {
                x = initialMargin
            } else {
               // let precX = item.previous!.view.frame.origin.x
                let previous = items[item.position - 1]
                let precX = previous.view.frame.origin.x
                x = precX + movingFactor(for: previous)
            }
            
            item.view.frame = CGRect(x: x, y: 0, width: size.width, height: size.height)
            item.saveCurrentLocation()
        }
        
    }
    
    override func performScroll(to direction: DASliderViewDirection,
                               ofQuantity quantity: Int,
                               animated: Bool = true) {
        
        items.forEach { item in
            
            let startingPoint = item.location
            
            let x: CGFloat
            switch direction {
                case .left:
                    let w = items[position-1].width
                    x = startingPoint.x + (w + leftMargin) * CGFloat(quantity)

                case .right:
                    let w = items[position].width
                    x = startingPoint.x - (w + leftMargin) * CGFloat(quantity)
            }
            
            if animated {
                UIView.animate(withDuration: 0.2) { item.translate(x: x) }
            } else { item.translate(x: x) }
            
        }
        
        position += direction.rawValue * quantity
        delegate?.sliderViewDidSelect(item: items[position].wrappedDAView, at: position, sliderView: sliderView)
    }
    
    override func insertItem(at index: Int, animated: Bool = true) {
        print("Inserting item at position \(index)...")

        let item = items[index]

        let itemsStartingAtIndex = items.filter {
            $0.position > index
        }

        func moveViews() {
            itemsStartingAtIndex.forEach {
                $0.view.center.x += movingFactor(for: $0)
                $0.saveCurrentLocation()
            }
        }

        let prevX = items[item.position - 1].view.frame.origin.x
        item.view.layer.opacity = 0.0
        item.view.frame = CGRect(x: prevX + movingFactor(for: items[item.position - 1]), y: 0, width: item.width, height: item.height)

        if animated {
            UIView.animate(withDuration: 0.2) { moveViews() }
            UIView.animate(withDuration: 0.5, delay: 0.2, options: .beginFromCurrentState) {
                item.view.layer.opacity = 1.0
            }
        } else {
            moveViews()
            item.view.layer.opacity = 1.0
        }

        item.saveCurrentLocation()
    }
    
    override func removeItem(at index: Int, animated: Bool = true) {
        print("Inserting item at position \(index)...")

        let item = items[index]

        let itemsStartingAtIndex = items.filter {
            $0.position > index
        }

        func moveViews() {
            itemsStartingAtIndex.forEach {
                $0.view.center.x -= movingFactor(for: item)
                $0.saveCurrentLocation()
            }
        }

        if animated {
            UIView.animate(withDuration: 0.2, animations: {
                item.view.layer.opacity = 0
            }, completion: { _ in
                item.view.removeFromSuperview()
            })
            UIView.animate(withDuration: 0.2, delay: 0.5) { moveViews() }
        } else {
            moveViews()
            item.view.layer.opacity = 0
            item.view.removeFromSuperview()
        }
    }
    
    override func changeItem(at index: Int, newItem: DAItemView, oldItem: DAItemView, animated: Bool = true) {

        let oldFrame = oldItem.view.frame
        newItem.view.frame = oldFrame
        newItem.view.layer.opacity = 0

        if animated {
            UIView.animate(withDuration: 0.2) {
                oldItem.view.layer.opacity = 0
            } completion: { result in
                oldItem.view.removeFromSuperview()
            }

            UIView.animate(withDuration: 0.2, delay: 0.2) {
                newItem.view.layer.opacity = 1
            }

        } else {
            newItem.view.layer.opacity = 1
            oldItem.view.removeFromSuperview()
        }

        newItem.saveCurrentLocation()

    }
}

public class CenteredItemLayoutManager : LayoutManager {
    
    public static let defaultPreview = CGFloat(25)
    public var preview = CenteredItemLayoutManager.defaultPreview
    
    override public var type: DASliderViewLayoutManager! { .centered }
    
    private func movingFactor(for item: DAItemView) -> CGFloat {
        return (sliderViewWidth / 2)
            + (item.width/2)
            - preview
    }
    
    public init(withPreview preview: CGFloat) {
        super.init()
        self.preview = preview
    }
    
    override public init() { super.init() }
    
    override func applyLayout() {
        
        var precedingItem: DAItemView!
        
       // print("superview width: \(rootView.frame.width) sliderView width: \(sliderView.frame.width) bounds=\(sliderView.bounds)")
        
        for i in 0 ..< items.count {
            
            let item = items[i]
            let size = item.size
            
            let x: CGFloat
            if i == 0 {
                x = (sliderView.frame.size.width/2) - (size.width/2)
            }
            else {
                let precX = precedingItem.view.frame.origin.x
                x = precX + movingFactor(for: precedingItem)
            }
            
            item.view.frame = CGRect(x: x, y: 0, width: size.width, height: size.height)
            precedingItem = item
            item.saveCurrentLocation()
        }
    }
    
    override func performScroll(to direction: DASliderViewDirection,
                               ofQuantity quantity: Int,
                               animated: Bool = true) {
        
        items.forEach { item in
            
            let point: CGPoint
            //let item = items[i]
            let startingPoint = item.location
            
            switch direction {
                case .left:
                    point = CGPoint(x:startingPoint.x + self.movingFactor(for: item) * CGFloat(quantity), y: startingPoint.y)
                case .right:
                    point = CGPoint(x:startingPoint.x - self.movingFactor(for: item) * CGFloat(quantity), y: startingPoint.y)
            }
            
            if animated {
                UIView.animate(withDuration: 0.2) { item.translate(toPoint: point) }
            } else {
                item.translate(toPoint: point)
            }
            
        }
        
        position += direction.rawValue * quantity
        delegate?.sliderViewDidSelect(item: items[position].wrappedDAView, at: position, sliderView: sliderView)
        //print("Scrolled to position: \(currentPosition)")
    }
    
}

//    override func insertItem(at index: Int, animated: Bool = true) {
//        print("Inserting item at position \(index)...")
//
//        let item = items[index]
//
//        let itemsStartingAtIndex = items.filter {
//            $0.position > index
//        }
//
//        func moveViews() {
//            itemsStartingAtIndex.forEach {
//                $0.view.center.x += movingFactor(for: $0)
//                $0.saveCurrentLocation()
//            }
//        }
//
//        let prevX = item.previous!.view.frame.origin.x
//        item.view.layer.opacity = 0.0
//        item.view.frame = CGRect(x: prevX + movingFactor(for: item.previous!), y: 0, width: item.width, height: item.height)
//
//        if animated {
//            UIView.animate(withDuration: 0.2) { moveViews() }
//            UIView.animate(withDuration: 0.5, delay: 0.2, options: .beginFromCurrentState) {
//                item.view.layer.opacity = 1.0
//            }
//        } else {
//            moveViews()
//            item.view.layer.opacity = 1.0
//        }
//
//        item.saveCurrentLocation()
//    }
//
//    override func removeItem(at index: Int, animated: Bool = true) {
//        print("Inserting item at position \(index)...")
//
//        let item = items[index]
//
//        let itemsStartingAtIndex = items.filter {
//            $0.position > index
//        }
//
//        func moveViews() {
//            itemsStartingAtIndex.forEach {
//                $0.view.center.x -= movingFactor(for: item)
//                $0.saveCurrentLocation()
//            }
//        }
//
//        if animated {
//            UIView.animate(withDuration: 0.2, animations: {
//                item.view.layer.opacity = 0
//            }, completion: { (res) in
//                item.view.removeFromSuperview()
//            })
//            UIView.animate(withDuration: 0.2, delay: 0.5) { moveViews() }
//        } else {
//            moveViews()
//            item.view.layer.opacity = 0
//            item.view.removeFromSuperview()
//        }
//    }
//
//    override func changeItem(at index: Int, newItem: DAItemView, oldItem: DAItemView, animated: Bool = true) {
//
//        let oldFrame = oldItem.view.frame
//        newItem.view.frame = oldFrame
//        newItem.view.layer.opacity = 0
//
//        if animated {
//            UIView.animate(withDuration: 0.2) {
//                oldItem.view.layer.opacity = 0
//            } completion: { result in
//                oldItem.view.removeFromSuperview()
//            }
//
//            UIView.animate(withDuration: 0.2, delay: 0.2) {
//                newItem.view.layer.opacity = 1
//            }
//
//        } else {
//            newItem.view.layer.opacity = 1
//            oldItem.view.removeFromSuperview()
//        }
//
//        newItem.saveCurrentLocation()
//
//    }


// dead in tombstone

//    fileprivate var rootView: UIView {
//        var view: UIView? = sliderView
//
//        while true {
//            if view?.superview != nil {
//                view = view?.superview
//            } else { return view! }
//        }
//    }

// position += (direction == .left ? -1 : 1) * quantity
//let max = CGFloat( allSizes.map { Float($0.width) }.max()! )
//point = CGPoint(x: startingPoint.x + (w + leftMargin) * CGFloat(quantity) , y: startingPoint.y)
//                    point = CGPoint(x:startingPoint.x + self.movingFactor * CGFloat(quantity),
//                                    y: startingPoint.y)
//point = CGPoint(x: startingPoint.x - (w + leftMargin) * CGFloat(quantity) , y: startingPoint.y)
//point = CGPoint(x:startingPoint.x - self.movingFactor * CGFloat(quantity), y: startingPoint.y)

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
