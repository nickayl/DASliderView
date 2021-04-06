//
//  DASliderViewImpl.swift
//  Bookka
//
//  Created by Domenico Aiello on 04/04/21.
//

import Foundation
import UIKit

public class DASliderView : UIView {

    public var delegate: DASliderViewDelegate?
    public var dataSource: DASliderViewDataSouce?
    
    public var currentPosition: Int { return position }
    public var selectedItem: DAItemView { return items[position] }
    public var layoutManager: DASliderViewLayoutManager {
        set {
            if newValue == .centered { __layoutManager = CenteredItemLayoutManager(with: self) }
            else { __layoutManager = LeftBoundItemLayoutManager(with: self) }
        }
        get {
            __layoutManager.type
        }
    }
    public var animationEnabled: Bool = true
   
    public var superviewCanInterceptTouchEvents: Bool = true
    public var gestureRecognizerDelegate: UIGestureRecognizerDelegate?
    public var properties: [String : CGFloat]!
    
    // ==== kProperties and private fields
    public let kPadding = DASliderViewProperty.padding.rawValue
    public let kMargin = DASliderViewProperty.margin.rawValue
    public let kInitialMargin = DASliderViewProperty.initialMargin.rawValue
    public let kMinDragToScroll = DASliderViewProperty.minDragToScroll.rawValue
    
    private var __layoutManager: LayoutManager!
    private var defaultProperties: [String : CGFloat]!
    
    internal var padding: CGFloat { properties[kPadding]! }
    internal var minimumDragToScroll: CGFloat { properties[kMinDragToScroll]! }
    internal var margin: CGFloat { properties[kMargin]! }
    internal var initialMargin: CGFloat { properties[kInitialMargin]! }
    
    internal var position: Int = 0
    internal var items: [DAItemView] = []
    internal var parentView: UIView { return superview ?? self }
    // ==

    public func initialize() { initialize(withPosition: 0, properties: defaultProperties) }
    
    public func initialize(withPosition position: Int, properties: [String : CGFloat] = [:]) {
        if dataSource == nil {
            print("Sliderview initialized with nil dataSource! You will see nothing until you set the delegate to the sliderView. "); return
        }
        
        defaultProperties = [ kPadding : CGFloat(25), kMinDragToScroll : frame.width/4, kMargin: CGFloat(25), kInitialMargin: CGFloat(0) ]
        
        if properties.isEmpty {
            self.properties = defaultProperties
        } else if layoutManager == .centered {
            self.properties = [ kPadding         : properties[kPadding] ?? defaultProperties[kPadding]!,
                                kMinDragToScroll : properties[kMinDragToScroll] ?? defaultProperties [kMinDragToScroll]!]
        } else if layoutManager == .leftBound {
            self.properties = [ kMargin         : properties[kMargin] ?? defaultProperties[kMargin]!,
                                kInitialMargin         : properties[kInitialMargin] ?? defaultProperties[kInitialMargin]!,
                                kMinDragToScroll : properties[kMinDragToScroll] ?? defaultProperties [kMinDragToScroll]!]
        }
        
        if __layoutManager == nil {
            layoutManager = .centered
        }
        
        for i in 0 ..< dataSource!.numberOfItems(of: self) {
            let item = dataSource!.viewForItem(at: i, recycling: nil, sliderView: self)
            items.append(item)
        }
        
        __layoutManager.applyLayout(position: position)
        
        for item in items {
            // Item view gesture detection ========
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognizer(gestureRecognizer:)))
            let longTouchGesture = UILongPressGestureRecognizer(target: self, action:#selector(longTouchGestureRecognizer(gestureRecognizer:)))
            item.view.addGestureRecognizer(tapGesture)
            item.view.addGestureRecognizer(longTouchGesture)
            // =====
            
            self.addSubview(item.view) // Finally add the view to the sliderview
        }
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandler(gestureRecognizer:)))
        self.addGestureRecognizer(panGesture)
        panGesture.delegate = gestureRecognizerDelegate

        if superviewCanInterceptTouchEvents {
            superview?.addGestureRecognizer(panGesture)
        }
        
    }
    
    public func setPosition(newPosition: Int, animated: Bool = true) throws {
        
        if newPosition < 0 || newPosition >= items.count {
            throw DASliderViewError.positionOutOfBoundsError
        } else if dataSource == nil {
            throw DASliderViewError.dataSourceNotSetError
        }
        
        //self.position = newPosition
        __layoutManager.scrollTo(newPosition, animated: animated)
    }
    
    public func setItemsPadding(_ padding: CGFloat) {
        self.properties[kPadding] = padding < 0 ? defaultProperties[kPadding]! : padding
    }
    
    public func setMinimumDragToScroll(_ amount: CGFloat) {
        if amount > defaultProperties[ kMinDragToScroll ]! {
            self.properties[ kMinDragToScroll ] = amount
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
                __layoutManager.scrollBegan()
                
            case .changed:
                __layoutManager.scrollChanged(translation)
                delegate?.sliderViewDidScroll?(sliderView: self)
                
            case .ended, .cancelled, .failed: 
                gestureRecognizer.delegate = gestureRecognizerDelegate
                __layoutManager.scrollEnded(translation)
                
                //gestureRecognizer.delegate = self
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
}
