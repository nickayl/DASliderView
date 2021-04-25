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
class LinkedElement<T> : CustomStringConvertible {
    
    fileprivate(set) var index: Int = -1
    fileprivate(set) var element: T?
    fileprivate(set) var previous: LinkedElement<T>?
    fileprivate(set) var next: LinkedElement<T>?
    
    public var description: String {
        "LinkedElement(index: \(index), element: \(element.debugDescription),  previous: \(previous?.element.debugDescription ?? "---"), next: \(next?.element.debugDescription ?? "---")".replacingOccurrences(of: "Optional(", with: "").replacingOccurrences(of: "\")", with: "\"")
    }
    
    fileprivate init(element: T? = nil) {
        self.element = element
    }
    
    fileprivate func destroy() {
        previous = nil
        next = nil
        element = nil
        index = -1
    }
    
    
}

/**
 An unordered list of linked objects that can be traversed in linear time.
 
 The implementation roughly follows the one provided on the well known book "Introduction to Algorithms" of Thomas H. Cormen et al.
 */

class LinkedList<T : Equatable> : Sequence, CustomStringConvertible {
    
    typealias Element = LinkedElement<T>
    typealias Iterator = LinkedListIterator<T>
    
    var head: LinkedElement<T>?
    var tail: LinkedElement<T>?
    
    let sentinel = LinkedElement<T>()
    
    public var description: String {
        var s = "\(type(of: self))(head: \(head), \n position: \(tail))\n"
        return s
    }
    
    public func printAll() {
        print("[", terminator: "")
        self.forEach {
            print($0.description + ",") 
        }
        print("]")
    }
    
    private(set) var count: Int = 0
    public var isEmpty: Bool { count == 0 }
    
    init() {  }
    
    init(withElement headElement: T) {
        addFirst(element: headElement)
    }
    
    func makeIterator() -> LinkedListIterator<T>  {
        return LinkedListIterator<T>(linkedList: self)
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
    
    func addLast(element: T) {
        let newEntry = LinkedElement(element: element)
        
        tail?.next = newEntry
        newEntry.index = count
        newEntry.previous = tail
        tail = newEntry
        if head == nil {
            head = tail
            sentinel.next = head
        }
        count += 1
    }
    
    func addAll(_ elements: [T]) {
        elements.forEach { addLast(element: $0) }
    }
    
    func insert(element newElement: T, atIndex index: Int) {
        
        if index == 0 {
            addFirst(element: newElement)
        } else if index == count {
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
        let currentHead = head
        
        head = head?.next
        head?.previous = nil
        
        sentinel.next = head
        
        currentHead?.destroy()
        //count -= 1
        notifyIndexUpdate(of: -1)
    }
    
    func removeLast() {
        let currentTail = tail
        tail = tail?.previous
        tail?.next = nil
        count -= 1
        
        currentTail?.destroy()
        
        if count == 0 {
            head = nil
        }
        //if head == nil { head = tail }
        //notifyIndexUpdate(of: -1)
    }
    
    func removeAll() {
        for _ in 0 ..< count { removeLast() }
    }
    
    func remove(linkedElement: LinkedElement<T>) {
        
        if linkedElement === head {
            removeFirst()
        } else if linkedElement === tail {
            removeLast()
        } else {
            linkedElement.previous?.next = linkedElement.next
            linkedElement.next?.previous = linkedElement.previous
            
            linkedElement.destroy()
            notifyIndexUpdate(of: -1)
        }
    }
    
    func remove(_ elements: [LinkedElement<T>]) {
        elements.forEach {
            remove(linkedElement: $0)
        }
    }
    
    func remove(element: T) {
        if let linkedElement = linkedElementOf(element) {
            remove(linkedElement: linkedElement)
        }
    }
    
    func remove(_ elements: [T]) {
        elements.forEach {
            remove(element: $0)
        }
    }
    
    

    func elementAtIndex(_ index: Int) -> Element? {
        
        if index < 0 || index >= count {
            return nil
        }
        
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
        
        if count == 0 {
            head = nil
            tail = nil
        }
    }
    
    subscript(row: Int) -> T {
        get {
            assert(row >= 0 || row < count, "IndexOutOfBoundsException")
            return elementAtIndex(row)!.element!
        }
//        set {
//            assert(row >= 0 || row <= count, "IndexOutOfBoundsException")
//            insert(element: newValue.element!, atIndex: row)
//        }
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
