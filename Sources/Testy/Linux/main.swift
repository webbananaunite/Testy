//
//  main.swift
//  Testy
//
//  Created by よういち on 2024/08/28.
//  Copyright © 2024 WEB BANANA UNITE Tokyo-Yokohama LPC. All rights reserved.
//

import Foundation
#if canImport(Glibc)
import Glibc
#elseif canImport(Musl)
import Musl
#endif
import blocks

/*
 Boot up in Command line.
 
 Run as boot node
 $ TestyOnLinux RunAsBootNode

 Run as normal node
 $ TestyOnLinux
 */
func main(argv: [String]) -> Void {
    Log("Start Testy.")
    guard argv.count == 1 || argv.count == 2 else {
        Log("Should Have 0 or 1 Parameters.")
        return
    }
    /*
     Doing Up
     
     beheivier as background
     */
    Communication().withUsingPOSIXBSDSocket(communicateInSubThread: false)
//    Communication().withUsingPOSIXBSDSocket()
}
main(argv: CommandLine.arguments)
