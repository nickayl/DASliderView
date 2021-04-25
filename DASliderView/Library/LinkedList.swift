//
//  LinkedList.swift
//  DASliderView
//
//  Created by Domenico Aiello on 22/04/21.
//

import Foundation

/**
 Specify an object that can be linked  in a unidirectional way.
 */
//protocol Linkable {
//    associatedtype Element : Linkable
//
//    var next: Element? { get set }
//}

/**
 Extend the `Linkable` protocol to allow objects to be linked in a bidirectional way.
 */
//protocol DoublyLinkable : Linkable {
//    var previous: Element? { get set }
//}

/**
 Specify an object that can be linked in a bidirectional way.
 Designed to be used in conjunction with a LinkedList data structure.
 */
class LinkedElement<T>  {
    
    fileprivate(set) var index: Int = -1
    fileprivate(set) var element: T?
    fileprivate(set) var previous: LinkedElement<T>?
    fileprivate(set) var next: LinkedElement<T>?
    
    fileprivate init(element: T? = nil) {
        self.element = element
    }
    
    fileprivate func destroy() {
        previous = nil
        next = nil
        element = nil
    }
}

/**
 An unordered list of linked objects that can be traversed in linear time.
 
 The implementation roughly follows the one provided on the well known book "Introduction to Algorithms" of Thomas H. Cormen et al.
 */

class LinkedList<T : Equatable> : Sequence {
    
    typealias Element = LinkedElement<T>
    typealias Iterator = LinkedListIterator<T>
    
    var head: LinkedElement<T>?
    var tail: LinkedElement<T>?
    
    let sentinel = LinkedElement<T>()
    
    private(set) var count: Int = 0
    public var isEmpty: Bool { count == 0 }
    
    init() {  }
    
    init(withElement headElement: T) {
        addFirst(element: headElement)
    }
    
    func makeIterator() -> LinkedListIterator<T>  {
        return LinkedListIterator<T>(linkedList: self)
    }

    func addLast(element: T) {
        let newEntry = LinkedElement(element: element)
        
        tail?.next = newEntry
        newEntry.index = count
        newEntry.previous = tail
        tail = newEntry
        count += 1
    }
    
    func addFirst(element: T) {
        let newEntry = LinkedElement(element: element)
        
        head?.previous = newEntry
        newEntry.next = head
        head = newEntry
        
        sentinel.next = head
        if tail == nil { tail = head }
        //count += 1
        notifyIndexUpdate(of: 1)
    }
    
    func insert(element newElement: T, atIndex index: Int) {
        
        if index == 0 {
            addFirst(element: newElement)
        } else if index == count - 1 {
            addLast(element: newElement)
        } else {
            var elementAtIndex = sentinel.next
            
            for _ in 0 ..< index { elementAtIndex = elementAtIndex?.next }
            
            let newLinkedElement = LinkedElement(element: newElement)
            
            newLinkedElement.previous = elementAtIndex
            newLinkedElement.next = elementAtIndex?.next
            
            elementAtIndex?.next = newLinkedElement
            newLinkedElement.next?.previous = newLinkedElement
            notifyIndexUpdate(of: 1)
        }
        
    }
    
    func removeFirst() {
        head?.next?.previous = nil
        head?.destroy()
        head = head?.next
        //count -= 1
        notifyIndexUpdate(of: -1)
    }
    
    func removeLast() {
        tail?.previous?.next = nil
        tail?.destroy()
        tail = tail?.previous
        count -= 1
        //notifyIndexUpdate(of: -1)
    }
    
    func remove(elementAtIndex index: Int) {
        //remove(element: linkedElementOf(elementatIndex(index)))
    }
    
    func remove(element: T) {
        
        let linkedElement = linkedElementOf(element)
        
        if linkedElement === head {
            removeFirst()
        } else if linkedElement === tail {
            removeLast()
        } else {
            linkedElement?.previous?.next = linkedElement?.next
            linkedElement?.next?.previous = linkedElement?.previous
            
            linkedElement?.destroy()
            notifyIndexUpdate(of: -1)
        }
        
    }

    func elementAtIndex(_ index: Int) -> Element? {
        var pointer: LinkedElement<T>? = sentinel
        
        for _ in 0 ... index { pointer = pointer?.next }
        
        return pointer
    }
    
//    func replace(element: T, with: T) {
//
//    }
//
    
    public func index(of element: T) -> Int? {
        var currentElement = sentinel.next
        
        while currentElement != nil {
            if currentElement?.element == element {
                return currentElement?.index
            }
            currentElement = currentElement?.next
        }
        
        return nil
    }
    
    // Private functions ===
    
    private func linkedElementOf(_ element: T) -> LinkedElement<T>? {
        var currentElement = sentinel.next
        
        while currentElement?.element != element {
            currentElement = currentElement?.next
        }
        
        return currentElement
    }
    
    private func notifyIndexUpdate(of quantity: Int) {
        let iterator = makeIterator()
        
        while let element = iterator.next() {
            element.index += quantity
        }
        
        count += quantity
    }
    
//    private func internalIterator() -> InternalListIterator<T> {
//        return InternalListIterator<T>(linkedList: self)
//    }
    
//    public func find(elementAtIndex index: Int) {
//        let iterator = makeIterator()
//
//    }
    
//    public func find(element: T) -> {
//        let iterator = makeIterator()
//
//        while let e = iterator.next() {
//
//        }
//    }
    
    class LinkedListIterator<T : Equatable> : IteratorProtocol {
        
        typealias Element = LinkedElement<T>
        
        let linkedList: LinkedList<T>
        var currentElement: LinkedElement<T>?
        
        init(linkedList: LinkedList<T>) {
            self.linkedList = linkedList
            currentElement = linkedList.sentinel
        }
        
        func next() -> LinkedElement<T>? {
            currentElement = currentElement?.next
            if currentElement == nil {
                currentElement = linkedList.sentinel
                return nil
            }
            return currentElement
        }
    }
    
//    internal final class LinkedListIterator<T : Equatable> : IteratorProtocol {
//
//        typealias Element = T
//
//        let linkedList: LinkedList<T>
//        var currentElement: LinkedElement<T>? = nil
//
//        init(linkedList: LinkedList<T>) {
//            self.linkedList = linkedList
//            currentElement = linkedList.sentinel
//        }
//
//        func next() -> T? {
//            currentElement = currentElement?.next
//            if currentElement == nil {
//                currentElement = linkedList.sentinel
//                return nil
//            }
//            return currentElement?.element
//        }
//    }
    
}
