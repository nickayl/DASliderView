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
        let list = LinkedList<String>(withElement: elements.first!)
        
        list.addFirst(element: elements[1])
        
        XCTAssertFalse(list.isEmpty)
        XCTAssertEqual(2, list.count)
        
        XCTAssertNil(list.head?.previous)
        XCTAssertNotNil(list.head?.next)
        
        XCTAssertEqual(list.head?.element, elements[1])
        XCTAssertEqual(list.head?.next?.element, elements[0])
        
        XCTAssertEqual(list.head?.index, 0)
        XCTAssertEqual(list.head?.next?.index, 1)
        
    }
    
    func test_D_AddLast() throws {
        let list = LinkedList<String>()
        
        list.addFirst(element: elements.first!)
        list.addLast(element: elements.last!)
        
        XCTAssertFalse(list.isEmpty)
        XCTAssertEqual(2, list.count)
        
        XCTAssertNil(list.head?.previous)
        XCTAssertNotNil(list.head?.next)
        
        XCTAssertEqual(list.head?.element, elements.first!)
        XCTAssertEqual(list.head?.next?.element, elements.last!)
        
        XCTAssertEqual(list.head?.index, 0)
        XCTAssertEqual(list.head?.next?.index, 1)
    }

}
