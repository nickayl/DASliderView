//
//  DASliderViewImpl.swift
//  Bookka
//
//  Created by Domenico Aiello on 04/04/21.
//

import Foundation
import UIKit

public class DASliderView : UIView, UIGestureRecognizerDelegate {

    public var delegate: DASliderViewDelegate?
    public var dataSource: DASliderViewDataSouce?
    
    public var currentPosition: Int { return position }
    public var selectedItem: DAView { return items[position].wrappedDAView }
    public var parentViewInterceptingTouchEvents: UIView?
    public var animationEnabled: Bool = true
    public var layoutManager: LayoutManager = defaultLayoutManager
    
    public internal(set) var position: Int = 0
    internal var items: [DAItemView] = []
    public lazy var minimumDragToScroll: CGFloat = self.frame.size.width/4
    
    private var initialized = false
    
    private static let defaultLayoutManager = CenteredItemLayoutManager()
    
    public func initialize(withPosition position: Int = 0) {
        
        if initialized {
            print("sliderView cannot be initialized more than once.")
            return
        }
        
        if dataSource == nil {
            print("Sliderview initialized with nil dataSource! You will see nothing until you set the dataSource to the sliderView. ")
            return
        }
        
        layoutManager.sliderView = self
        
        self.position = position
        reloadData()
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandler(gestureRecognizer:)))
        panGesture.delegate = self
        parentViewInterceptingTouchEvents?.addGestureRecognizer(panGesture)
        self.addGestureRecognizer(panGesture)
        
        initialized = true
    }
    
    // Causes the sliderView to entirely reload all the views from the dataSource.
    // Consider using notifyItemInserted or notifyItemRemove instead of this method,
    // Should be used only as a last resort.
    public func reloadData(animated: Bool = false) {
        
        items.removeAll()
        self.subviews.forEach { $0.removeFromSuperview() }
        
        let numItems = dataSource!.numberOfItems(of: self)
        
        for i in 0 ..< numItems {
            let daView = dataSource!.viewForItem(at: i, recycling: nil, sliderView: self)
            let itemView = DAItemView(daView: daView, position: i)
            
            insertView(atPosition: i, itemView: itemView)
        }
        
        layoutManager.applyLayout()
        let previousPosition = self.position
        self.position = 0
        layoutManager.scrollTo(previousPosition, animated: animated)
    }
    
    private func insertView(atPosition index: Int, itemView: DAItemView, replaceIfPresent: Bool = true) {
        
        items.insert(itemView, at: index)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognizer(gestureRecognizer:)))
        let longTouchGesture = UILongPressGestureRecognizer(target: self, action:#selector(longTouchGestureRecognizer(gestureRecognizer:)))
        longTouchGesture.minimumPressDuration = 0.7
        longTouchGesture.allowableMovement = 3.0
        
        itemView.view.addGestureRecognizer(tapGesture)
        itemView.view.addGestureRecognizer(longTouchGesture)
        itemView.view.tag = index
        
        self.addSubview(itemView.view)
    }
    
    public func notifyItemInserted(atIndex index: Int, animated: Bool = true) {
        
        if dataSource!.numberOfItems(of: self) != items.count + 1 {
            print("DASliderView WARNING: No new item detected")
            return
        } else if index < 0 || index > items.count {
            print("Cannot insert item at index \(index): It must be in the range 0 ... numberOfItems. If you are adding more than one item, use reloadData()")
        }
        
        let view = dataSource!.viewForItem(at: index, recycling: items[index].wrappedDAView, sliderView: self)
        
        if view != items[index].wrappedDAView {
            let itemView = DAItemView(daView: view, position: index)

            insertView(atPosition: index, itemView: itemView)
            resetItemsIndices()
            layoutManager.insertItem(at: index, animated: animated)
        } else {
            print("Cannot insert identical DAView instance")
        }
        
    }
     
    public func notifyItemRemoved(atIndex index: Int) {
        if dataSource!.numberOfItems(of: self) != items.count - 1 {
            print("DASliderView WARNING: No removed item detected. Please use reloadData() for radical changes to the dataset.")
            // reloadData()
            return
        } else if isOutOfBounds(index) {
            print("Index oout of ranges!")
            return
        }
        
        //let view = dataSource!.viewForItem(at: index, recycling: nil, sliderView: self)
        //let itemAtIndex = items[index]
        
        //if itemAtIndex.wrappedDAView != view {
            print("Removed item at index \(index)")
            
            layoutManager.removeItem(at: index)
            items.remove(at: index)
            resetItemsIndices()
            //layoutManager.removeItem(at: index, animated: animated)
//        } else {
//            print("The element at index \(index) has not been deleted because it is present in the datasource.")
//        }
    }
//    
    public func notifyItemChanged(atIndex index: Int) {
        if isOutOfBounds(index) {
            print("Index oout of ranges!")
            return
        }
        let updatedView = dataSource!.viewForItem(at: index, recycling: items[index].wrappedDAView, sliderView: self)
        
        if updatedView !== items[index].wrappedDAView {
            let oldItem = items[index]
            let newItem = DAItemView(daView: updatedView, position: index)
            
            items[index] = newItem
            
            addSubview(newItem.view)
            layoutManager.changeItem(at: index, newItem: newItem, oldItem: oldItem)
        }
    }
    
    public func setPosition(newPosition: Int, animated: Bool = true) throws {
        
        if newPosition < 0 || newPosition >= items.count {
            throw DASliderViewError.positionOutOfBoundsError
        } else if dataSource == nil {
            throw DASliderViewError.dataSourceNotSetError
        }
        
        //self.position = newPosition
        layoutManager.scrollTo(newPosition, animated: animated)
    }
    
    
    public func setMinimumDragToScroll(_ amount: CGFloat) {
        
        if amount > minimumDragToScroll {
            minimumDragToScroll = amount
        }
    }
    
    private func resetItemsIndices() {
        for i in 0 ..< dataSource!.numberOfItems(of: self) {
            items[i].position = i
            items[i].view.tag = i
        }
    }
    
    private func isOutOfBounds(_ index: Int) -> Bool {
        index < 0 || index >= items.count
    }
    
    @objc private func longTouchGestureRecognizer(gestureRecognizer: UILongPressGestureRecognizer) {
        
        switch gestureRecognizer.state {
            case .ended, .cancelled, .failed:
                let item = items.first { $0.view.tag == gestureRecognizer.view!.tag }!
                
                delegate?.sliderViewDidReceiveLongTouchOn(item: item.wrappedDAView,
                                                     at: item.view.tag,
                                                     sliderView: self)
               // print("long toch(\(gestureRecognizer.state.rawValue)) on view: tag=\(item.view.tag), position=\(item.position)")
            default:
                return ;
        }
        
    }
    
    @objc private func tapGestureRecognizer(gestureRecognizer: UITapGestureRecognizer) {
        let item = items.first { $0.view.tag == gestureRecognizer.view!.tag }!
        
        delegate?.sliderViewDidReceiveTapOn(item: item.wrappedDAView,
                                             at: item.view.tag,
                                             sliderView: self)
        //print("Tap on view: tag=\(item.view.tag), position=\(item.position)")
    }
    
    @objc private func panGestureHandler(gestureRecognizer: UIPanGestureRecognizer) {
        if dataSource == nil { return }
        
        let touchedView = gestureRecognizer.view!
        let translation = gestureRecognizer.translation(in: touchedView.superview)
        //let velocity = gestureRecognizer.velocity(in: piece.superview)
        
        switch gestureRecognizer.state {
        
            case .began:  // Here is where the touch movement starts
                gestureRecognizer.delegate = nil
                layoutManager.scrollBegan()
                
            case .changed:
                layoutManager.scrollChanged(translation)
                print("translation x: \(translation.x)")
                delegate?.sliderViewDidScroll(sliderView: self)
                
            case .ended, .cancelled, .failed:
                let result = (abs(translation.x) < (minimumDragToScroll)) ||
                    (position == items.count-1 && translation.x < 0) ||
                    (position == 0 && translation.x > 0)
                
                layoutManager.scrollEnded(translation, canScroll: !result)
                gestureRecognizer.delegate = self //gestureRecognizerDelegate
            default:
                print("Invalid gesture state")
        }
            
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}



//    public var layoutManager: DASliderViewLayoutManager {
//        set {
//            if newValue == .centered { __layoutManager = CenteredItemLayoutManager(with: self) }
//            else { __layoutManager = LeftBoundItemLayoutManager(with: self) }
//        }
//        get {
//            __layoutManager.type
//        }
//    }
    
   
    //public var superviewCanInterceptTouchEvents: Bool = true
    //public var gestureRecognizerDelegate: UIGestureRecognizerDelegate?
    
    
    // ==== kProperties and private fields
//    public static let kPadding = DASliderViewProperty.padding.rawValue
//    public static let kMargin = DASliderViewProperty.margin.rawValue
//    public static let kInitialMargin = DASliderViewProperty.initialMargin.rawValue
    //public static let kMinDragToScroll = DASliderViewProperty.minDragToScroll.rawValue
   
    
//    public var layoutManager: DASliderViewLayoutManager = .centered
//    private var __layoutManager: LayoutManager
    
//    public static let defaultProperties: [DASliderViewProperty : CGFloat] = [ .padding : CGFloat(25),
//                                                                              .minDragToScroll : 100,
//                                                                              .margin: CGFloat(25),
//                                                                              .initialMargin: CGFloat(0) ]
    //public private(set) var properties = defaultProperties
    
    //internal var padding: CGFloat { properties[.padding] ?? DASliderView.defaultProperties[.padding]! }
    
//    internal var margin: CGFloat { properties[.margin] ?? DASliderView.defaultProperties[.margin]! }
//    internal var initialMargin: CGFloat { properties[.initialMargin] ?? DASliderView.defaultProperties[.initialMargin]! }
    
   
    //internal var parentView: UIView { return superview ?? self }
    // ==
    

//private var startX: CGFloat = 0
//private var endX: CGFloat = 0
//private var translation: CGPoint!

//    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        startX = touches.first!.location(in: self).x
//        print("startX=\(startX)")
//        __layoutManager.scrollBegan()
//    }
//
//    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        let curX = touches.first!.location(in: self).x
//        //let translation = CGPoint(x: -(startX - curX), y: 0)
//        print("curX = \(curX),translationX=\(translation.x)")
//        translation.x = -(startX - curX)
//        __layoutManager.scrollChanged(translation)
//    }
//
//    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        endX = touches.first!.location(in: self).x
//        //let translation = CGPoint(x: -(startX - endX), y: 0)
//        __layoutManager.scrollEnded(translation)
//        print("endX=\(endX)")
//    }
//
//    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print("Touch canceled")
//        endX = touches.first!.location(in: self).x
//        //let translation = CGPoint(x: -(startX - endX), y: 0)
//        __layoutManager.scrollEnded(translation)
//    }
