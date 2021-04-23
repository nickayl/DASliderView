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
class DoubleLinkedElement<T>  {
    
    var element: T?
    var previous: DoubleLinkedElement<T>?
    var next: DoubleLinkedElement<T>?
    
    init(element: T? = nil) {
        self.element = element
    }
}

/**
 An unordered list of linked objects that can be traversed in linear time.
 
 The implementation roughly follows the one provided on the well known book "Introduction to Algorithms" of Thomas H. Cormen et al.
 */
final class LinkedList<T> : Sequence {
    
    typealias Element = T
    typealias Iterator = LinkedListIterator
    
    var head: DoubleLinkedElement<T>
    var tail: DoubleLinkedElement<T>
    
    private(set) var count: Int = 0
    
    init(withElement headElement: T) {
        self.head = DoubleLinkedElement(element: headElement)
        self.tail = self.head
    }
    
    func makeIterator() -> LinkedListIterator<T>  {
        return LinkedListIterator<T>(linkedList: self)
    }

    func append(element: T) {
        let newEntry = DoubleLinkedElement(element: element)
        
        tail.next = newEntry
        newEntry.previous = tail
        tail = newEntry
        
        count += 1
    }
    
    func prepend(element: T) {
        let newEntry = DoubleLinkedElement(element: element)
        
        head.previous = newEntry
        newEntry.next = head
        head = newEntry
        
        count += 1
    }
    
    func insert(element: T, atIndex: Int) {
        // TODO
    }
    
    func removeHead() {
        if let next = head.next {
            next.previous = nil
            head = next
            count -= 1
        }
    }
    
    func removeTail() {
        if let prev = tail.previous {
            prev.next = nil
            tail = prev
            count -= 1
        }
        
    }
    
    func remove(atIndex index: Int) {
        // TODO
    }
    
    var underestimatedCount: Int { count }

    func withContiguousStorageIfAvailable<R>(_ body: (UnsafeBufferPointer<T>) throws -> R) rethrows -> R? { nil }
    
    
    internal final class LinkedListIterator<T> : IteratorProtocol {
        
        typealias Element = T
        
        let linkedList: LinkedList<T>
        var currentElement: DoubleLinkedElement<T>? = nil
        
        init(linkedList: LinkedList<T>) {
            self.linkedList = linkedList
            currentElement = linkedList.head
        }
        
        func next() -> T? {
            let cur = currentElement?.element
            currentElement = currentElement?.next
            return cur
        }
    }
    
}
