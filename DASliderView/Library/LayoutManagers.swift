//
//  LayoutManagers.swift
//  Bookka
//
//  Created by Domenico Aiello on 05/04/21.
//

import Foundation
import UIKit

internal protocol LayoutManager {
    
    func scrollBegan()
    func scrollChanged(_ translation: CGPoint)
    func scrollEnded(_ translation: CGPoint)
    func applyLayout(position: Int)
    func scrollTo(_ position: Int, animated: Bool)
    func dragItemView(_ translation: CGPoint)
    func cancelScroll()
    func performScroll(to direction: DASliderViewDirection,
                               ofQuantity quantity: Int,
                               animated: Bool)
    
    var movingFactor: CGFloat { get }
    var position: Int { get set }
    var items: [DAItemView] { get }
    var properties: [String:CGFloat] { get }
    var type: DASliderViewLayoutManager { get }
}

internal class AbstractLayoutManager {
    
    enum LayoutManagerError : Error {
        case NotImplementedError
        case AbstractClassCannotBeInstantiated
    }

    var position: Int {
        set { sliderView.position = newValue }
        get { sliderView.position }
    }
    
    var properties: [String : CGFloat] = [:]
    var items: [DAItemView] { sliderView.items }
    var delegate: DASliderViewDelegate? { sliderView.delegate }
    var padding: CGFloat { sliderView.padding }
    var minimumDragToScroll:CGFloat { sliderView.minimumDragToScroll }
    var itemSize: CGSize { sliderView.dataSource!.sizeForItem(at: position, sliderView: sliderView) }
    
    let sliderView: DASliderView
    var lastItemPosition: [CGPoint]!
    
    var rootView: UIView {
        var view: UIView? = sliderView
        
        while true {
            if view?.superview != nil {
                view = view?.superview
            } else { return view! }
        }
    }
    
    func direction(of translation: CGPoint) -> DASliderViewDirection {
        return translation.x > 0 ? .left : .right
    }
    
    init(with sliderView: DASliderView) {
        self.sliderView = sliderView
    }
    
}

internal class LeftBoundItemLayoutManager : AbstractLayoutManager, LayoutManager {

    internal var initialMargin: CGFloat { sliderView.initialMargin }
    internal var leftMargin: CGFloat { sliderView.margin }
    
    var type: DASliderViewLayoutManager = .leftBound
    
    var movingFactor: CGFloat {
        return itemSize.width + (leftMargin * 1)
    }
    
    func applyLayout(position: Int) {
        
        var precedingItem: DAItemView!
        
        for i in 0 ..< items.count {
            
            let item = items[i]
            //items.append(item)
            
            let x: CGFloat
            if i == 0 {
                x = initialMargin
            }
            else {
                let precX = precedingItem.view.frame.origin.x
                x = precX + movingFactor
            }
            
            item.view.frame = CGRect(x: x, y: 0, width: itemSize.width, height: itemSize.height)
            item.view.tag = i
            precedingItem = item
            
        }
        
        lastItemPosition = items.map { $0.view.center }
        //self.position = position
        scrollTo(position, animated: sliderView.animationEnabled)
    }
    
    func scrollBegan() {
        lastItemPosition = items.map { $0.view.center }
    }
    
    func scrollChanged(_ translation: CGPoint) {
        dragItemView(translation)
    }
    
    func scrollEnded(_ translation: CGPoint) {
        let direction = self.direction(of: translation)
        
        if( (abs(translation.x) < (minimumDragToScroll)) ||
            (position == items.count-1 && direction == .right) ||
            (position == 0 && direction == .left) ) {
            cancelScroll()
        }
        else {
            performScroll(to: direction, ofQuantity: 1)
        }
    }
    
    public  func scrollTo(_ position: Int, animated: Bool = true) {
        lastItemPosition = items.map { $0.view.center }
        performScroll(to: (position < self.position) ? .left : .right,
                      ofQuantity: abs(self.position - position), animated: animated)
    }
    
    func performScroll(to direction: DASliderViewDirection,
                               ofQuantity quantity: Int,
                               animated: Bool = true) {
        
        for i in 0 ..< self.items.count {
            
            let point: CGPoint
            let startingPoint = self.lastItemPosition[i]
            
            switch direction {
                case .left:
                    point = CGPoint(x: startingPoint.x + (items[i].view.frame.width + leftMargin) * CGFloat(quantity) , y: startingPoint.y)
//                    point = CGPoint(x:startingPoint.x + self.movingFactor * CGFloat(quantity),
//                                    y: startingPoint.y)
                case .right:
                    point = CGPoint(x: startingPoint.x - (items[i].view.frame.width + leftMargin) * CGFloat(quantity) , y: startingPoint.y)
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
    
    func cancelScroll() {
        UIView.animate(withDuration: 0.2) {
            for i in 0 ..< self.items.count {
                self.items[i].view.center = CGPoint(x: self.lastItemPosition[i].x, y: self.lastItemPosition[i].y)
            }
        }
    }
    
    func dragItemView(_ translation: CGPoint) {
        
        for i in 0 ..< items.count { // When the user moves the finger, we are in the changed state
            let point = lastItemPosition[i]
            
            if abs(translation.x) > abs(translation.y) {
                let newCenter = CGPoint(x: point.x + translation.x, y: point.y)
                items[i].view.center = newCenter
            }
        }
        
    }
    
}

internal class CenteredItemLayoutManager : AbstractLayoutManager, LayoutManager {
    
    var type: DASliderViewLayoutManager = .centered
    
    var movingFactor: CGFloat {
        return CGFloat(sliderView.frame.size.width/2)
            - padding
            + CGFloat(itemSize.width/2)
    }
    
    func applyLayout(position: Int) {
        
        var precedingItem: DAItemView!
        
        print("superview width: \(rootView.frame.width) sliderView width: \(sliderView.frame.width) bounds=\(sliderView.bounds)")
        
        for i in 0 ..< items.count {
            
            let item = items[i]
            //items.append(item)
            
            let x: CGFloat
            if i == 0 {
                x = (sliderView.frame.size.width/2) - (itemSize.width/2)
            }
            else {
                let precX = precedingItem.view.frame.origin.x
                x = precX + movingFactor
            }
            
            item.view.frame = CGRect(x: x, y: 0, width: itemSize.width, height: itemSize.height)
            item.view.tag = i
            precedingItem = item
        }
        
        lastItemPosition = items.map { $0.view.center }
        //self.position = position
        scrollTo(position, animated: sliderView.animationEnabled)
    }
    
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
    
    public  func scrollTo(_ position: Int, animated: Bool = true) {
        lastItemPosition = items.map { $0.view.center }
        performScroll(to: (position < self.position) ? .left : .right,
                      ofQuantity: abs(self.position - position), animated: animated)
    }
    
    func performScroll(to direction: DASliderViewDirection,
                               ofQuantity quantity: Int,
                               animated: Bool = true) {
        
        for i in 0 ..< self.items.count {
            
            let point: CGPoint
            let startingPoint = self.lastItemPosition[i]
            
            switch direction {
                case .left:
                    point = CGPoint(x:startingPoint.x + self.movingFactor * CGFloat(quantity), y: startingPoint.y)
                case .right:
                    point = CGPoint(x:startingPoint.x - self.movingFactor * CGFloat(quantity), y: startingPoint.y)
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
    
    func cancelScroll() {
        UIView.animate(withDuration: 0.2) {
            for i in 0 ..< self.items.count {
                self.items[i].view.center = CGPoint(x: self.lastItemPosition[i].x, y: self.lastItemPosition[i].y)
            }
        }
    }
    
    func dragItemView(_ translation: CGPoint) {
        
        for i in 0 ..< items.count { // When the user moves the finger, we are in the changed state
            let point = lastItemPosition[i]
            
            if abs(translation.x) > abs(translation.y) {
                let newCenter = CGPoint(x: point.x + translation.x, y: point.y)
                items[i].view.center = newCenter
            }
        }
        
    }
    
}
