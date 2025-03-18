//
//  DataArithmetic.swift
//  TestyTests
//
//  Created by よういち on 2023/01/18.
//  Copyright © 2023 WEB BANANA UNITE Tokyo-Yokohama LPC. All rights reserved.
//

import XCTest
@testable import blocks

final class DataArithmetic: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testHaveBetween() throws {
        Log()
        //        return have(node, between: toAddress, intervalType: .includeExclude)
/*
        17:59:18 Node.swift initFingerTable(i:babysitterNode:token:) l.1395 finger- from: 752125ba784d53149767fcc83d21c543e81937b4744d7ea7e9dd535ea60f341be1ca0a4faeff001ff42e4c497f98cdd1f401cd703898ba37d1ec6ec79e3930de
        17:59:18 Node.swift initFingerTable(i:babysitterNode:token:) l.1396 finger- to: 988637f394e5c291fb7448a9e53bfc5f5fba73feb9ea57703d77b046ed20bab7a0d9f6b41467376ee0dfd25b48cd9a04ed81f0eb197dcfd6ef2532cf84e0f71c
        17:59:18 Node.swift initFingerTable(i:babysitterNode:token:) l.1397 finger- target: 752127ba784d53149767fcc83d21c543e81937b4744d7ea7e9dd535ea60f341be1ca0a4faeff001ff42e4c497f98cdd1f401cd703898ba37d1ec6ec79e3930de
        if self.have(fingers[i].start, between: node)
 */
        if true {
            if let from = "752125ba784d53149767fcc83d21c543e81937b4744d7ea7e9dd535ea60f341be1ca0a4faeff001ff42e4c497f98cdd1f401cd703898ba37d1ec6ec79e3930de".data(using: .hexadecimal),
                let to = "988637f394e5c291fb7448a9e53bfc5f5fba73feb9ea57703d77b046ed20bab7a0d9f6b41467376ee0dfd25b48cd9a04ed81f0eb197dcfd6ef2532cf84e0f71c".data(using: .hexadecimal),
                let target = "752127ba784d53149767fcc83d21c543e81937b4744d7ea7e9dd535ea60f341be1ca0a4faeff001ff42e4c497f98cdd1f401cd703898ba37d1ec6ec79e3930de".data(using: .hexadecimal) {
                Log()
                let lowNode = Node(binaryAddress: from)
                let upNode = Node(binaryAddress: to)
                let targetNode = Node(binaryAddress: target)
                let result = lowNode.have(targetNode, between: upNode, intervalType: .includeExclude)
                XCTAssertEqual(result, true)
            }
        }

        
        if false {
            /*
             Data.Modulo.subtract(exponent: 0)
             public static var Modulo: Data = Data(repeating: 0, count: Int(ModuloAsExponentOf2 / 8)) + Data(repeating: 1, count: 1)
             public static var ModuloAsExponentOf2: UInt = 512

             ・little endien
             {64個＋１}バイト
             000000000000000000000000000000000000000000000000000000000000 0000 1
             {最下位ビット}
                                                                                                                                                    {最上位ビット}
             0x00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 01
             ↓ subtract()
             000001 - 1 = 010000 - 1 = 00ffff = to little endien => ffff00
             
             ↓
             ffffffffffffffffffff ffffffffffffffffffff ffffffffffffffffffff ffffffffffffffffffff ffffffffffffffffffff ffffffffffffffffffff ffffffff 00

             */
            let estimatedResult = "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00".data(using: .hexadecimal)
            Dump(estimatedResult)
            let result = Data.Modulo.subtract(exponent: 0)
            Dump(result)//ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff 00
            XCTAssertEqual(result, estimatedResult)
        }
        if false {
            if let lower = "f87f3ce797b4fcdd28b33987751f821f251b61b7f16b31dbf38888e560a2ec0c1492fc41332ce86b330cc98cb2ac8bdcf482c61703ecfdcd58d7b94f2ae29876".data(using: .hexadecimal),
                let upper = "f87f3ce797b4fcdd28b33987751f821f251b61b7f16b31dbf38888e560a2ec0c1492fc41332ce86b330cc98cb2ac8bdcf482c61703ecfdcd58d7b94f2ae29876".data(using: .hexadecimal),
                let target = "77851f003564c2776b48fa3876a62a0c1f20f22b81e4483c6bed0ff94e5fa02f0410486e2fc70ec7d10a3e4ca7b9ce46bf2e4ff729811b650422a294193a38dc".data(using: .hexadecimal) {
                Log()
                let lowNode = Node(binaryAddress: lower)
                let upNode = Node(binaryAddress: upper)
                let targetNode = Node(binaryAddress: target)
                let result = lowNode.have(targetNode, between: upNode, intervalType: .includeExclude)
                XCTAssertEqual(result, true)
            }
        }

        if false {
            if let lower = "7e20f4e0dbd3050f041d9ebd632eec43f9463a7e07ed340db6bbaec6303860c1ea9fedccccf634498ceca3ce2816cc9296c5c7e5f95d87c496be9feb5a545c99".data(using: .hexadecimal),
                let upper = "7e20f4e0dbd3050f041d9ebd632eec43f9463a7e07ed340db6bbaec6303860c1ea9fedccccf634498ceca3ce2816cc9296c5c7e5f95d87c496be9feb5a545f99".data(using: .hexadecimal),
                let target = "9020f4e0dbd3050f041d9ebd632eec43f9463a7e07ed340db6bbaec6303860c1ea9fedccccf634498ceca3ce2816cc9296c5c7e5f95d87c496be9feb5a545c99".data(using: .hexadecimal) {
                Log()
                let lowNode = Node(binaryAddress: lower)
                let upNode = Node(binaryAddress: upper)
                let targetNode = Node(binaryAddress: target)
                let result = lowNode.have(targetNode, between: upNode)
                XCTAssertEqual(result, true)
            }
        }
        if false {
            if let lower = "10".data(using: .hexadecimal),
                let upper = "1".data(using: .hexadecimal),
                let target = "11".data(using: .hexadecimal) {
                Log()
                let lowNode = Node(binaryAddress: lower)
                let upNode = Node(binaryAddress: upper)
                let targetNode = Node(binaryAddress: target)
                let result = lowNode.have(targetNode, between: upNode)
                XCTAssertEqual(result, true)
            }
        }
        if false {
            if let lower = "7e20f4e0dbd3050f041d9ebd632eec43f9463a7e07ed340db6bbaec6303860c1ea9fedccccf634498ceca3ce2816cc9296c5c7e5f95d87c496be9feb5a545c99".data(using: .hexadecimal),
                let upper = "f87f3ce797b4fcdd28b33987751f821f251b61b7f16b31dbf38888e560a2ec0c1492fc41332ce86b330cc98cb2ac8bdcf482c61703ecfdcd58d7b94f2ae29876".data(using: .hexadecimal),
                let target = "7020f4e0dbd3050f041d9ebd632eec43f9463a7e07ed340db6bbaec6303860c1ea9fedccccf634498ceca3ce2816cc9296c5c7e5f95d87c496be9feb5a545c99".data(using: .hexadecimal) {
                Log()
                let lowNode = Node(binaryAddress: lower)
                let upNode = Node(binaryAddress: upper)
                let targetNode = Node(binaryAddress: target)
                let result = lowNode.have(targetNode, between: upNode)
                XCTAssertEqual(result, false)
            }
        }
        if false {
            if let lower = "7e20f4e0dbd3050f041d9ebd632eec43f9463a7e07ed340db6bbaec6303860c1ea9fedccccf634498ceca3ce2816cc9296c5c7e5f95d87c496be9feb5a545c99".data(using: .hexadecimal),
                let upper = "f87f3ce797b4fcdd28b33987751f821f251b61b7f16b31dbf38888e560a2ec0c1492fc41332ce86b330cc98cb2ac8bdcf482c61703ecfdcd58d7b94f2ae29876".data(using: .hexadecimal),
                let target = "7e20f4e0dbd3050f041d9ebd632eec43f9463a7e07ed340db6bbaec6303860c1ea9fedccccf634498ceca3ce2816cc9296c5c7e5f95d87c496be9feb5a545c99".data(using: .hexadecimal) {
                Log()
                let lowNode = Node(binaryAddress: lower)
                let upNode = Node(binaryAddress: upper)
                let targetNode = Node(binaryAddress: target)
                let result = lowNode.have(targetNode, between: upNode)
                XCTAssertEqual(result, true)
            }
        }
    }
    func testLessThan() throws {
        Log()
        if let lower = "0".data(using: .hexadecimal), let upper = "1".data(using: .hexadecimal), let target = "5".data(using: .hexadecimal) {
            let result = lower.lessThan(upper)
            XCTAssertEqual(result, true)
        }
        
        if let lower = "7e20f4e0dbd3050f041d9ebd632eec43f9463a7e07ed340db6bbaec6303860c1ea9fedccccf634498ceca3ce2816cc9296c5c7e5f95d87c496be9feb5a545c99".data(using: .hexadecimal), let upper = "f87f3ce797b4fcdd28b33987751f821f251b61b7f16b31dbf38888e560a2ec0c1492fc41332ce86b330cc98cb2ac8bdcf482c61703ecfdcd58d7b94f2ae29876".data(using: .hexadecimal), let target = "7f20f4e0dbd3050f041d9ebd632eec43f9463a7e07ed340db6bbaec6303860c1ea9fedccccf634498ceca3ce2816cc9296c5c7e5f95d87c496be9feb5a545c99".data(using: .hexadecimal) {
            Log()
            /*
             target:
             8020f4e0dbd3050f041d9ebd632eec43f9463a7e07ed340db6bbaec6303860c1ea9fedccccf634498ceca3ce2816cc9296c5c7e5f95d87c496be9feb5a545c99
             */
//            let result = target.lessThan(target)
//            XCTAssertEqual(result, false)
            /*
             upper:
             f87f3ce797b4fcdd28b33987751f821f251b61b7f16b31dbf38888e560a2ec0c1492fc41332ce86b330cc98cb2ac8bdcf482c61703ecfdcd58d7b94f2ae29876
             target:
             7f20f4e0dbd3050f041d9ebd632eec43f9463a7e07ed340db6bbaec6303860c1ea9fedccccf634498ceca3ce2816cc9296c5c7e5f95d87c496be9feb5a545c99
             */
//            let result = upper.lessThan(target)
//            XCTAssertEqual(result, true)
//            let result = lower.lessThan(target)
//            XCTAssertEqual(result, true)
        }
    }

    func testGreaterThan() throws {
        Log()
        if let lower = "7e20f4e0dbd3050f041d9ebd632eec43f9463a7e07ed340db6bbaec6303860c1ea9fedccccf634498ceca3ce2816cc9296c5c7e5f95d87c496be9feb5a545c99".data(using: .hexadecimal), let upper = "f87f3ce797b4fcdd28b33987751f821f251b61b7f16b31dbf38888e560a2ec0c1492fc41332ce86b330cc98cb2ac8bdcf482c61703ecfdcd58d7b94f2ae29876".data(using: .hexadecimal), let target = "7f20f4e0dbd3050f041d9ebd632eec43f9463a7e07ed340db6bbaec6303860c1ea9fedccccf634498ceca3ce2816cc9296c5c7e5f95d87c496be9feb5a545c99".data(using: .hexadecimal) {
            Log()
            /*
             target:
             8020f4e0dbd3050f041d9ebd632eec43f9463a7e07ed340db6bbaec6303860c1ea9fedccccf634498ceca3ce2816cc9296c5c7e5f95d87c496be9feb5a545c99
             */
//            let result = target.greaterThan(target)
//            XCTAssertEqual(result, false)
//            let result = lower.greaterThan(target)
//            XCTAssertEqual(result, false)
            let result = target.greaterThan(lower)
            XCTAssertEqual(result, true)
        }
    }

    /*
     Positive Value:
        Make Data BitShiftRight.
     
     Negative Value:
        Subtract Modulo from Data.
     */
    func testModulo() throws {
        Log()
        /*
         Dividened:
         65 byte (520 bit)
         0x010F_FEFEFEFE_FEFEFEFE_..._03
         */
//        let dividend = Data(repeating: 1, count: 1) + Data(repeating: 15, count: 1) + Data(repeating: 254, count: 62) + Data(repeating: 3, count: 1)  //UInt8 * 65
        let dividend = Data(repeating: 1, count: 1) + Data(repeating: 15, count: 1) + Data(repeating: 254, count: 62) + Data(repeating: 3, count: 1) + Data(repeating: 0, count: 1)  //UInt8 * 66
        print("dividend:")
        Dump(dividend)
//        let madeModuloData = dividend.modulo(exponentOf2: 8)    //2^8: 8 bit     x 10進で512
//        let madeModuloData = dividend.modulo(exponentOf2: 16)    //2^16: 16 bit
        let madeModuloData = dividend.modulo(exponentOf2: 512)    //2^512: 512 bit
//        let madeModuloData = dividend.modulo(exponentOf2: 3)    //x８ビット以上のため 2^3: 8 bit
//        let madeModuloData = dividend.modulo(exponentOf2: 4)    //x 2^4: 16 bit
        print("modulo:")
        Dump(madeModuloData)
//        let expectedModulo = Data(repeating: 1, count: 1)
//        let expectedModulo = Data(repeating: 1, count: 1) + Data(repeating: 15, count: 1)
        let expectedModulo = Data(repeating: 1, count: 1) + Data(repeating: 15, count: 1) + Data(repeating: 254, count: 62) + Data(repeating: 0, count: 2)
        print("expected")
        Dump(expectedModulo)
//        let expectedModulo = Data(repeating: 15, count: 1) + Data(repeating: 254, count: 62) + Data(repeating: 3, count: 1)
//        let expectedModulo = Data(repeating: 1, count: 1) + Data(repeating: 15, count: 1)
        XCTAssertEqual(madeModuloData, expectedModulo)
    }
    
    func testAdd() throws {
        Log()
//        let addend = Data(repeating: 254, count: 64)
        let addend = Data(repeating: 1, count: 1) + Data(repeating: 15, count: 1) + Data(repeating: 254, count: 62) + Data(repeating: 0, count: 1) + Data(repeating: 0, count: 1)
        print("addend:")
        Dump(addend)
        /*
         2^1
         = 0b10{1}
         
         2^512
         = 0b10{512}
         */
//        let added = addend.add(exponent: 0)   //2^0
//        let added = addend.add(exponent: 1) //2^1
        let added = addend.add(exponent: 512) //2^512
        
        print("added:")
        Dump(added)
        /*
         Data(repeating: 254, count: 64)
         +
         2^0
         2^1
         2^512
         */
//        let expectedAdd = Data(repeating: 255, count: 1) + Data(repeating: 254, count: 63)
//        let expectedAdd = Data(repeating: 0, count: 1) + Data(repeating: 255, count: 1) + Data(repeating: 254, count: 62)
//        let expectedAdd = Data(repeating: 254, count: 64) + Data(repeating: 1, count: 1)
        /*
         Data(repeating: 1, count: 1) + Data(repeating: 15, count: 1) + Data(repeating: 254, count: 62) + Data(repeating: 0, count: 1) + Data(repeating: 0, count: 1)
         +
         2^0
         2^1
         2^512
         */
//        let expectedAdd = Data(repeating: 2, count: 1) + Data(repeating: 15, count: 1) + Data(repeating: 254, count: 62) + Data(repeating: 0, count: 1) + Data(repeating: 0, count: 1)
//        let expectedAdd = Data(repeating: 3, count: 1) + Data(repeating: 15, count: 1) + Data(repeating: 254, count: 62) + Data(repeating: 0, count: 1) + Data(repeating: 0, count: 1)
        let expectedAdd = Data(repeating: 1, count: 1) + Data(repeating: 15, count: 1) + Data(repeating: 254, count: 62) + Data(repeating: 1, count: 1) + Data(repeating: 0, count: 1)
        print("expected:")
        Dump(expectedAdd)
        XCTAssertEqual(added, expectedAdd)
    }
    
    func testSubtract() throws {
        Log()
        /* Minus Value (Negative value)
         ▿ <010ffefe fefefefe fefefefe fefefefe fefefefe fefefefe fefefefe fefefefe fefefefe fefefefe fefefefe fefefefe fefefefe fefefefe fefefefe fefefefe 0100> #0
         */
        /*
         2^1
         = 0b10{1}
         
         2^512
         = 0b10{512}
         */
        if false {
            let subtractend = Data(repeating: 0, count: 512) + Data(repeating: 1, count: 1)

            print("subtractend:")
            Dump(subtractend)
            let subtracted = subtractend.subtract(exponent: 5) //2^5

            print("subtracted:")
            Dump(subtracted)
            let expectedSubtract = Data(repeating: 224, count: 1) + Data(repeating: 255, count: 511) + Data(repeating: 0, count: 1)

            print("expected:")
            Dump(expectedSubtract)
            XCTAssertEqual(subtracted, expectedSubtract)
        }
        if false {
            let subtractend = Data(repeating: 1, count: 1) + Data(repeating: 2, count: 1) + Data(repeating: 3, count: 1) + Data(repeating: 4, count: 1)
            print("subtractend:")
            Dump(subtractend)   //01020304
            let subtracted = subtractend.subtract(exponent: 512) //subtracter: 2^512    2^512 = 0{0が512個}...1
            print("subtracted:")
            Dump(subtracted)
            //LittleEndian
            //fffdfcfb ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff 00
            var expectedSubtract = Data(repeating: 255, count: 1) + Data(repeating: 253, count: 1) + Data(repeating: 252, count: 1) + Data(repeating: 251, count: 1) + Data(repeating: 255, count: 60)
            expectedSubtract += Data(repeating: 0, count: 1)
            print("expected:")
            //LittleEndian
            //fffdfcfb ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff 00
            Dump(expectedSubtract)
            XCTAssertEqual(subtracted, expectedSubtract)
        }
        if false {
            let subtractend = Data(repeating: 0, count: 64) + Data(repeating: 1, count: 1)
            print("subtractend:")
            Dump(subtractend)
            let subtracted = subtractend.subtract(exponent: 512) //2^512
            print("subtracted:")
            Dump(subtracted)
            let expectedSubtract = Data(repeating: 0, count: 65)
            print("expected:")
            Dump(expectedSubtract)
            XCTAssertEqual(subtracted, expectedSubtract)
        }
        if true {
            let subtractend = Data(repeating: 0, count: 512) + Data(repeating: 1, count: 1)

            print("subtractend:")
            Dump(subtractend)
            let subtracted = subtractend.subtract(exponent: 0) //2^0

            print("subtracted:")
            Dump(subtracted)
            let expectedSubtract = Data(repeating: 255, count: 512) + Data(repeating: 0, count: 1)

            print("expected:")
            Dump(expectedSubtract)
            XCTAssertEqual(subtracted, expectedSubtract)
        }
    }

    //Node#containToAddress
    func testInRange() throws {
        Log()
        /*
         Minus Value (Negative value)
         to
         ▿ <010ffefe fefefefe fefefefe fefefefe fefefefe fefefefe fefefefe fefefefe fefefefe fefefefe fefefefe fefefefe fefefefe fefefefe fefefefe fefefefe 0100> #0

         about
         ▿ <00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 01> #0

         */
        if false {
            let about = Data(repeating: 0, count: 6)
            + Data(repeating: 6, count: 1)
            + Data(repeating: 5, count: 1)
            + Data(repeating: 3, count: 1)
            + Data(repeating: 3, count: 1)  //UInt8
            print("about:")
            Dump(about)
            
            let own = Data(repeating: 0, count: 6)
            + Data(repeating: 5, count: 1)
            + Data(repeating: 3, count: 1)
            + Data(repeating: 1, count: 1)
            + Data(repeating: 0, count: 1)  //UInt8
            print("own:")
            Dump(own)
            
            let to = Data(repeating: 0, count: 6)
            + Data(repeating: 6, count: 1)
            + Data(repeating: 5, count: 1)
            + Data(repeating: 3, count: 1)
            + Data(repeating: 3, count: 1)  //UInt8
            print("to:")
            Dump(to)
            
            let withInRange = own.inRange(intervalType: .exclude, to: to, about: about)
            XCTAssertEqual(withInRange, false)
        }
        
        if false {
            let about = Data(repeating: 0, count: 6)
            + Data(repeating: 5, count: 1)
            + Data(repeating: 2, count: 1)
            + Data(repeating: 3, count: 1)
            + Data(repeating: 0, count: 1)  //UInt8
            print("about:")
            Dump(about)
            
            let own = Data(repeating: 0, count: 6)
            + Data(repeating: 5, count: 1)
            + Data(repeating: 3, count: 1)
            + Data(repeating: 1, count: 1)
            + Data(repeating: 0, count: 1)  //UInt8
            print("own:")
            Dump(own)
            
            let to = Data(repeating: 0, count: 6)
            + Data(repeating: 6, count: 1)
            + Data(repeating: 5, count: 1)
            + Data(repeating: 3, count: 1)
            + Data(repeating: 3, count: 1)  //UInt8
            print("to:")
            Dump(to)
            
            let withInRange = own.inRange(intervalType: .exclude, to: to, about: about)
            XCTAssertEqual(withInRange, true)
        }

        if false {
            let about = Data(repeating: 0, count: 6)
            + Data(repeating: 5, count: 1)
            + Data(repeating: 6, count: 1)
            + Data(repeating: 2, count: 1)
            + Data(repeating: 1, count: 1)  //UInt8
            print("about:")
            Dump(about)
            
            let own = Data(repeating: 0, count: 6)
            + Data(repeating: 5, count: 1)
            + Data(repeating: 3, count: 1)
            + Data(repeating: 4, count: 1)
            + Data(repeating: 0, count: 1)  //UInt8
            print("own:")
            Dump(own)
            
            let to = Data(repeating: 0, count: 6)
            + Data(repeating: 6, count: 1)
            + Data(repeating: 5, count: 1)
            + Data(repeating: 3, count: 1)
            + Data(repeating: 1, count: 1)  //UInt8
            print("to:")
            Dump(to)
            
            let withInRange = own.inRange(intervalType: .include, to: to, about: about)
            XCTAssertEqual(withInRange, true)
        }

        if false {
            if let lower = "7e20f4e0dbd3050f041d9ebd632eec43f9463a7e07ed340db6bbaec6303860c1ea9fedccccf634498ceca3ce2816cc9296c5c7e5f95d87c496be9feb5a545c99".data(using: .hexadecimal), let upper = "f87f3ce797b4fcdd28b33987751f821f251b61b7f16b31dbf38888e560a2ec0c1492fc41332ce86b330cc98cb2ac8bdcf482c61703ecfdcd58d7b94f2ae29876".data(using: .hexadecimal), let target = "7e20f4e0dbd3050f041d9ebd632eec43f9463a7e07ed340db6bbaec6303860c1ea9fedccccf634498ceca3ce2816cc9296c5c7e5f95d87c496be9feb5a545c59".data(using: .hexadecimal) {
                Log()
                let lowNode = Node(binaryAddress: lower)
                let upNode = Node(binaryAddress: upper)   //Have to set Successor
                lowNode.successor = upNode
                let targetNode = Node(binaryAddress: target)
                let result = lowNode.haveBetweenWithSuccessor(about: targetNode)
                XCTAssertEqual(result, true)
            }
        }

        if false {
            if let lower = "7e20f4e0dbd3050f041d9ebd632eec43f9463a7e07ed340db6bbaec6303860c1ea9fedccccf634498ceca3ce2816cc9296c5c7e5f95d87c496be9feb5a545c99".data(using: .hexadecimal), let upper = "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00".data(using: .hexadecimal), let target = "7e20f4e0dbd3050f041d9ebd632eec43f9463a7e07ed340db6bbaec6303860c1ea9fedccccf634498ceca3ce2816cc9296c5c7e5f95d87c496be9feb5a545c59".data(using: .hexadecimal) {
                                
                let withInRange = lower.inRange(intervalType: .includeExclude, to: upper, about: target)
                XCTAssertEqual(withInRange, false)
            }
        }

        if false {
            if let lower = "7e20f4e0dbd3050f041d9ebd632eec43f9463a7e07ed340db6bbaec6303860c1ea9fedccccf634498ceca3ce2816cc9296c5c7e5f95d87c496be9feb5a545c99".data(using: .hexadecimal), let upper = "f87f3ce797b4fcdd28b33987751f821f251b61b7f16b31dbf38888e560a2ec0c1492fc41332ce86b330cc98cb2ac8bdcf482c61703ecfdcd58d7b94f2ae29876".data(using: .hexadecimal), let target = "7e20f4e0dbd3050f041d9ebd632eec43f9463a7e07ed340db6bbaec6303860c1ea9fedccccf634498ceca3ce2816cc9296c5c7e5f95d87c496be9feb5a545c59".data(using: .hexadecimal) {
                                
                let withInRange = lower.inRange(intervalType: .includeExclude, to: upper, about: target)
                XCTAssertEqual(withInRange, false)
            }
        }

        if false {
            let about = Data(repeating: 0, count: 64) + Data(repeating: 1, count: 1)  //UInt8 * 65
            print("about:")
            Dump(about)
            
            let own = Data.DataNull
            print("own:")
            Dump(own)
            
            let to = Data(repeating: 1, count: 1) + Data(repeating: 15, count: 1) + Data(repeating: 254, count: 62) + Data(repeating: 1, count: 1) + Data(repeating: 0, count: 1)  //UInt8 * 66
            print("to:")
            Dump(to)
            
            let withInRange = own.inRange(intervalType: .includeExclude, to: to, about: about)
            XCTAssertEqual(withInRange, true)
        }

        if false {
            let about = Data(repeating: 0, count: 64) + Data(repeating: 1, count: 1)  //UInt8 * 65
            print("about:")
            Dump(about)
            
            let own = Data(repeating: 0, count: 64) + Data(repeating: 1, count: 1) + Data(repeating: 0, count: 1)  //UInt8
            print("own:")
            Dump(own)
            
            let to = Data(repeating: 1, count: 1) + Data(repeating: 15, count: 1) + Data(repeating: 254, count: 62) + Data(repeating: 1, count: 1) + Data(repeating: 0, count: 1)  //UInt8 * 66
            print("to:")
            Dump(to)
            
            let withInRange = own.inRange(intervalType: .includeExclude, to: to, about: about)
            XCTAssertEqual(withInRange, true)
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
