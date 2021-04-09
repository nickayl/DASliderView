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
    public var selectedItem: DAItemView { return items[position] }
    public var addGestureRecognizerToArrayOfViews: [UIView]?
    public var animationEnabled: Bool = true
    public var layoutManager: LayoutManager!
    
    public internal(set) var position: Int = 0
    public internal(set) var items: [DAItemView] = []
    public lazy var minimumDragToScroll: CGFloat = self.frame.size.width/4
    
    public func initialize(withPosition position: Int = 0) {
        
        if dataSource == nil {
            print("Sliderview initialized with nil dataSource! You will see nothing until you set the delegate to the sliderView. "); return
        }
        
        if layoutManager == nil {
            layoutManager = CenteredItemLayoutManager()
        }
        
        layoutManager.sliderView = self
        //gestureRecognizerDelegate = gestureRecognizerDelegate ?? self
        
//        if properties.isEmpty {
//            self.properties = DASliderView.defaultProperties
//        }
        
        for i in 0 ..< dataSource!.numberOfItems(of: self) {
            let item = dataSource!.viewForItem(at: i, recycling: nil, sliderView: self)
            items.append(item)
        }
        
        layoutManager.applyLayout(position: position)
        
        for item in items {
            // Item view gesture detection ========
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognizer(gestureRecognizer:)))
            let longTouchGesture = UILongPressGestureRecognizer(target: self, action:#selector(longTouchGestureRecognizer(gestureRecognizer:)))
            longTouchGesture.minimumPressDuration = 0.7
            longTouchGesture.allowableMovement = 3.0
            
            item.view.addGestureRecognizer(tapGesture)
            item.view.addGestureRecognizer(longTouchGesture)
            // =====
            
            self.addSubview(item.view) // Finally add the view to the sliderview
        }
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandler(gestureRecognizer:)))
        //panGesture.delegate = self
        panGesture.delegate = self
        addGestureRecognizerToArrayOfViews?.forEach { $0.addGestureRecognizer(panGesture) }
        self.addGestureRecognizer(panGesture)

//        if superviewCanInterceptTouchEvents {
//            superview?.addGestureRecognizer(panGesture)
//        }
        
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
    
//    public func setItemsPadding(_ padding: CGFloat) {
//        //self.properties[kPadding] = padding < 0 ? defaultProperties[kPadding]! : padding
//    }
    
    public func setMinimumDragToScroll(_ amount: CGFloat) {
        
        if amount > minimumDragToScroll {
            minimumDragToScroll = amount
        }
    }
    
    @objc private func longTouchGestureRecognizer(gestureRecognizer: UILongPressGestureRecognizer) {
        
        switch gestureRecognizer.state {
            case .ended, .cancelled, .failed:
                let item = items.first { $0.view.tag == gestureRecognizer.view!.tag }!
                
                delegate?.sliderViewDidReceiveLongTouchOn?(item: item,
                                                     at: item.view.tag,
                                                     sliderView: self)
               // print("long toch(\(gestureRecognizer.state.rawValue)) on view: tag=\(item.view.tag), position=\(item.position)")
            default:
                return ;
        }
        
    }
    
    @objc private func tapGestureRecognizer(gestureRecognizer: UITapGestureRecognizer) {
        let item = items.first { $0.view.tag == gestureRecognizer.view!.tag }!
        
        delegate?.sliderViewDidReceiveTapOn?(item: item,
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
                delegate?.sliderViewDidScroll?(sliderView: self)
                
            case .ended, .cancelled, .failed: 
                //gestureRecognizer.delegate = gestureRecognizerDelegate
                layoutManager.scrollEnded(translation)
                
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
