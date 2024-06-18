//
//  Log.swift
//  Testy
//
//  Created by よういち on 2020/06/19.
//  Copyright © 2020 WEB BANANA UNITE Tokyo-Yokohama LPC. All rights reserved.
//

import Foundation
import UIKit

func Log(_ object: Any = "", functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    #if false
    let className = (fileName as NSString).lastPathComponent
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm:ss"
    let dateString = formatter.string(from: Date())
    print("\(dateString) \(className) \(functionName) l.\(lineNumber) \(object)\n")
    #endif
}

public func LogEssential(_ object: Any = "", functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    #if true
    let className = (fileName as NSString).lastPathComponent
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm:ss"
    let dateString = formatter.string(from: Date())
    print("\(dateString) \(className) \(functionName) l.\(lineNumber) \(object) ***\n")
    #endif
}
