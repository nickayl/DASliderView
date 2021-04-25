//
//  LinkedListTests.swift
//  DASliderViewTests
//
//  Created by Domenico Aiello on 24/04/21.
//

import XCTest
@testable import DASliderView

class LinkedListTests: XCTestCase {

    private let elements = [ "ciao", "pollo", "SO' LILLO", "pintus", "eoeo" ]
    private var list: LinkedList<String>!
    
    override func setUpWithError() throws {
        list = LinkedList()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_A_EmptyInit() throws {
        
        let list = LinkedList<String>()
        
        XCTAssertTrue(list.isEmpty)
        XCTAssertEqual(0, list.count)
        
        XCTAssertNil(list.head)
        XCTAssertNil(list.tail)
        
        XCTAssertNotNil(list.sentinel)
        XCTAssertNil(list.sentinel.next)
        XCTAssertNil(list.sentinel.previous)
        XCTAssertEqual(list.sentinel.index, -1)
    }
    
    func test_B_InitWithHead() throws {
        
        let list = LinkedList<String>(withElement: elements.first!)
        
        XCTAssertFalse(list.isEmpty)
        XCTAssertEqual(1, list.count)
        
        XCTAssertNotNil(list.head)
        XCTAssertNil(list.head?.previous)
        XCTAssertNil(list.head?.next)
        XCTAssertNotNil(list.sentinel.next)
        
        XCTAssertEqual(list.head?.element, elements.first!)
        XCTAssertEqual(list.head?.index, 0)
    }
    
    func test_C_AddFirst() throws {
        let (firstElement, secondElement) = ("Ciao", "Pollo")
        
        let list = LinkedList<String>(withElement: secondElement)
        
        list.addFirst(element: firstElement)
        
        XCTAssertFalse(list.isEmpty)
        XCTAssertEqual(2, list.count)
        
        XCTAssertNil(list.head?.previous)
        XCTAssertNotNil(list.head?.next)
        
        XCTAssertEqual(list.head?.element, firstElement)
        XCTAssertEqual(list.head?.next?.element, secondElement)
        
        XCTAssertEqual(list.head?.index, 0)
        XCTAssertEqual(list.head?.next?.index, 1)
        
    }
    
    func test_D_AddLast() throws {
        let (firstElement, secondElement) = ("Ciao", "Pollo")
        
        let list = LinkedList<String>()
        
        list.addFirst(element: firstElement)
        list.addLast(element: secondElement)
        
        XCTAssertFalse(list.isEmpty)
        XCTAssertEqual(2, list.count)
        
        XCTAssertNil(list.head?.previous)
        XCTAssertNil(list.tail?.next)
        XCTAssertNotNil(list.head?.next)
        
        XCTAssertTrue(list.head?.next === list.tail)
        
        XCTAssertEqual(list.head?.element, firstElement)
        XCTAssertEqual(list.tail?.element, secondElement)
        
        XCTAssertEqual(list.head?.index, 0)
        XCTAssertEqual(list.tail?.index, 1)
    }
    
    func test_E_RemoveFirst() throws {
        
        let (firstElement, secondElement) = ("Ciao", "Pollo")
        
        let list = LinkedList<String>()
        
        list.addFirst(element: firstElement)
        list.addLast(element: secondElement)
        
        XCTAssertFalse(list.isEmpty)
        XCTAssertEqual(2, list.count)
        
        XCTAssertEqual(list.head?.element, firstElement)
        XCTAssertEqual(list.tail?.element, secondElement)
        
        list.removeFirst()
        
        XCTAssertFalse(list.isEmpty)
        XCTAssertEqual(1, list.count)
        XCTAssertEqual(list.head?.element, secondElement)
        XCTAssertTrue(list.head === list.tail)
        XCTAssertNil(list.head?.previous)
        XCTAssertNil(list.head?.next)
        XCTAssertEqual(0, list.head?.index)
        
        XCTAssertNoThrow(try testConsistency(on: list))
        
    }
    
    func test_E_RemoveLast() throws {
        
        let (firstElement, secondElement) = ("Ciao", "Pollo")
        
        let list = LinkedList<String>()
        
        list.addFirst(element: firstElement)
        list.addLast(element: secondElement)
        
        XCTAssertFalse(list.isEmpty)
        XCTAssertEqual(2, list.count)
        
        XCTAssertEqual(list.head?.element, firstElement)
        XCTAssertEqual(list.tail?.element, secondElement)
        
        list.removeLast()
        
        XCTAssertFalse(list.isEmpty)
        XCTAssertEqual(1, list.count)
        XCTAssertEqual(list.head?.element, firstElement)
        XCTAssertTrue(list.head === list.tail)
        XCTAssertNil(list.head?.previous)
        XCTAssertNil(list.head?.next)
        XCTAssertEqual(0, list.head?.index)
        
        XCTAssertNoThrow(try testConsistency(on: list))
        
    }
    
    
    func test_F_InsertAtIndex() throws {
        
        let (firstElement, secondElement, thirdElement, fourthElement) = ("Ciao", "Pollo", "Weee", "eoeoe")
        
        let list = LinkedList<String>()
        
        list.insert(element: firstElement, atIndex: 0)
        
        XCTAssertNoThrow(try test_C_AddFirst())
        
        list.insert(element: secondElement, atIndex: 1)
        
        XCTAssertNoThrow(try test_D_AddLast())
        
        list.insert(element: thirdElement, atIndex: 2)
        
        XCTAssertEqual(3, list.count)
        
        let thirdLE = list.elementAtIndex(2)
        
        XCTAssertNotNil(thirdLE)
        XCTAssertEqual(thirdLE?.element, thirdElement)
        XCTAssertEqual(2, thirdLE?.index)
        
        XCTAssertFalse(list.head === list.tail)
        XCTAssertFalse(list.head === thirdLE)
        XCTAssertFalse(list.head?.next === thirdLE)
        XCTAssertTrue(list.tail === thirdLE)
        
        list.addLast(element: fourthElement)
        
        XCTAssertEqual(4, list.count)
        
        let lastLE = list.elementAtIndex(3)
        
        XCTAssertNotNil(lastLE)
        XCTAssertEqual(lastLE?.element, fourthElement)
        XCTAssertEqual(3, lastLE?.index)
        
        XCTAssertFalse(list.head === list.tail)
        XCTAssertFalse(list.head === lastLE)
        XCTAssertTrue(thirdLE === list.tail?.previous)
        XCTAssertTrue(list.tail === lastLE)
        
        
        XCTAssertEqual(0, list.head?.index)
        XCTAssertEqual(1, list.head?.next?.index)
        XCTAssertEqual(2, list.tail?.previous?.index)
        XCTAssertEqual(3, list.tail?.index)
        XCTAssertEqual(list.count - 1, list.tail?.index)
        
        XCTAssertNil(list.tail?.next)
        XCTAssertNil(list.head?.previous)
        
        XCTAssertNoThrow(try testConsistency(on: list))
    }
    
    func test_G_RemoveElement() throws {
        
        let (firstElement, secondElement, thirdElement, fourthElement) = ("Ciao", "Pollo", "Weee", "eoeoe")
        
        let list = LinkedList<String>()
        
        list.insert(element: firstElement, atIndex: 0)
        list.insert(element: secondElement, atIndex: 1)
        list.insert(element: thirdElement, atIndex: 2)
        list.insert(element: fourthElement, atIndex: 3)
        
        XCTAssertEqual(list.count, 4)
        
        let oldHead = list.elementAtIndex(0)
        let oldSecond = list.elementAtIndex(1)
        
        list.remove(element: firstElement)
        
        XCTAssertEqual(list.count, 3)
        XCTAssertEqual(list.head?.element, secondElement)
        XCTAssertEqual(list.head?.index, 0)
        
        XCTAssertFalse(list.head === oldHead)
        XCTAssertTrue(oldSecond === list.head)
        XCTAssertTrue(oldSecond?.index == 0)
        
        XCTAssertNoThrow(try testConsistency(on: list))
        
        let third = list.elementAtIndex(1)
        
        list.remove(linkedElement: oldSecond!)
        XCTAssertEqual(2, list.count)
        XCTAssertTrue(list.head === third)
        XCTAssertTrue(third?.index == 0)
        
        XCTAssertNoThrow(try testConsistency(on: list))
    }
    
    func test_H_ElementAtIndex() throws {
        
        let (firstElement, secondElement, thirdElement, fourthElement) = ("Ciao", "Pollo", "Weee", "eoeoe")
        
        let list = LinkedList<String>()
        
        list.insert(element: firstElement, atIndex: 0)
        list.insert(element: secondElement, atIndex: 1)
        list.insert(element: thirdElement, atIndex: 2)
        list.insert(element: fourthElement, atIndex: 3)
        
        let f = list.elementAtIndex(0)
        let s = list.elementAtIndex(1)
        
        XCTAssertEqual(f?.element, firstElement)
        XCTAssertEqual(s?.element, secondElement)
        
        XCTAssertEqual(f?.index, 0)
        XCTAssertEqual(s?.index, 1)
    }
    
    func test_I_AddAll() throws {
        
        let elements = ["Ciao", "Pollo", "Weee", "eoeoe"]
        
        let list = LinkedList<String>()
        
        XCTAssertEqual(0, list.count)
        
        list.addAll(elements)
        
        XCTAssertEqual(4, list.count)
        
        XCTAssertNoThrow(try testConsistency(on: list))
    }
    
    func test_L_RemoveAll() throws {
        
        let list = getFullList()
        
        XCTAssertGreaterThan(list.count, 0)
        
        list.removeAll()
        
        XCTAssertEqual(0, list.count)
        XCTAssertNil(list.head)
        XCTAssertNil(list.tail)
        
        XCTAssertNoThrow(try testConsistency(on: list))
    }
    
    func test_L_RemoveAllManually() throws {
        
        print("===== test_L_RemoveAllManually START =======")
        let list = getFullList()
        
        XCTAssertGreaterThan(list.count, 0)
        
        list.printAll()
        
        list.remove(element: "Ciao")
        list.remove(element: "eoeoe")
        
        let tail = list.tail
        
        
        list.remove(linkedElement: tail!)
        list.remove([list.head!])
        
        XCTAssertEqual(0, list.count)
        XCTAssertNil(list.head)
        XCTAssertNil(list.tail)
        
        XCTAssertNoThrow(try testConsistency(on: list))
        list.printAll()
        print("===== test_L_RemoveAllManually END =======")
    }
    
    func getFullList() -> LinkedList<String> {
        let elements = ["Ciao", "Pollo", "Weee", "eoeoe"]
        let list = LinkedList<String>()
        list.addAll(elements)
        
        return list
    }
    
    func testConsistency<T>(on list: LinkedList<T>) throws {
        
        for i in 0 ..< list.count {
            let elementAtIndex = list.elementAtIndex(i)
            
            XCTAssertEqual(i, elementAtIndex?.index)
            
            if i == 0 { XCTAssertNil(elementAtIndex?.previous) }
            else if i == list.count - 1 { XCTAssertNil(elementAtIndex?.next) }
            else {
                XCTAssertNotNil(elementAtIndex?.previous)
                XCTAssertNotNil(elementAtIndex?.next)
            }
        }
    }

}
