//
//  Communication.swift
//  Testy
//
//  Created by よういち on 2024/09/03.
//  Copyright © 2024 WEB BANANA UNITE Tokyo-Yokohama LPC. All rights reserved.
//

import Foundation
#if os(macOS) || os(iOS)
import Darwin.C
//@_silgen_name("fork") private func system_fork() -> Int32
#elseif canImport(Glibc)
import Glibc
//private let system_fork = Glibc.fork
#elseif canImport(Musl)
import Musl
//private let system_fork = Musl.fork
#elseif os(Windows)
import ucrt
//private let system_fork = ucrt.fork
#else
#error("UnSupported platform")
#endif
import blocks

public class Communication {
    var ownNode: Node?
#if os(iOS)
    var model: Model?

    init(ownNode: Node? = nil, model: Model? = nil) {
        Log("init Communication.")
        self.ownNode = ownNode
        self.model = model
    }
#elseif os(Linux)
    let serialQueue = DispatchQueue(label: "org.webbanana.org.Testy")
#endif

    /*
     Doing Up
     
     beheivier as background   x daemon（spawnしなくて良い）
     */
    /*
     Communication with Using POSIX BSD Sockets.
     */
    public func withUsingPOSIXBSDSocket(communicateInSubThread: Bool = true) {
        Log("Communication withUsingPOSIXBSDSocket.")
        let socket = Socket()
        let rawbuf: UnsafeMutableRawBufferPointer = UnsafeMutableRawBufferPointer.allocate(byteCount: Socket.MTU, alignment: MemoryLayout<CChar>.alignment)
        guard let ownNode = Node(ownNode: IpaddressV4.null, port: 0, premiumCommand: blocks.Command.other) else {
            Log()
            return
        }
        socket.start(startMode: .registerMeAndIdling, tls: false, rawBufferPointer: rawbuf, node: ownNode, inThread: communicateInSubThread, notifyOwnAddress: {
            ownAddress in
            /*
             Done Making Socket
             */
            LogCommunicate(ownAddress as Any)
            Log()
            guard let _ = ownAddress else {
                Log()
                /*
                 Signaling Server UnAvailable.
                 */
                #if os(iOS)
                Task { @MainActor in
                    await Notification.notifyToViews("Signaling Server UnAvailable.", name: Notification.Name.detectExecuteDoneNotification)
                }
                #elseif os(Linux)
                Log("Signaling Server UnAvailable.")
                #endif
                return
            }
            actionsAfterMadeSocket()
        }) {
            [self] sentDataNodeIp, dataRange in
            /*
             Received Data on Listening Bound Port.
             */
            Log(sentDataNodeIp as Any)
            Log(dataRange.count)
            Log(rawbuf) //UnsafeMutableRawBufferPointer(start: 0x000000014980be00, count: 1024)
            guard dataRange.count > 0, let sentDataNodeIp = sentDataNodeIp else {Log()
                return
            }
            /*
             Transform [CChar] to String
             */
            let acceptedString = rawbuf.toString(byteRange: dataRange)
            LogEssential(acceptedString)
            
            /*
             Detect Command
             */
#if os(iOS)
            DispatchQueue.main.async {
                //Translate sentDataNodeIp to overlayNetworkAddress
                guard let overlayNetworkAddress = socket.findOverlayNetworkAddress(ip: sentDataNodeIp, node: ownNode) else {
                    LogEssential("Invalid Received IP Address (Not Signaling yet): \(sentDataNodeIp)")
                    return
                }
                LogEssential(overlayNetworkAddress)
                ownNode.received(from: overlayNetworkAddress, data: acceptedString)
            }
#elseif os(Linux)
            serialQueue.async {
                /*
                 Enqueue Command in Serial Queue
                 
                 #TakeDownMemoryPressure
                 */
                //Translate sentDataNodeIp to overlayNetworkAddress
                guard let overlayNetworkAddress = socket.findOverlayNetworkAddress(ip: sentDataNodeIp, node: ownNode) else {
                    Log("Invalid Received IP Address (Not Signaling yet): \(sentDataNodeIp)")
                    return
                }
                Log(overlayNetworkAddress)
                ownNode.received(from: overlayNetworkAddress, data: acceptedString)
            }
#endif
        }
        func actionsAfterMadeSocket() {
            Log()
            /*
             library()した dhtAddresshexstring, binaryaddress, 情報をrestoreする
             ip, portはその都度検出したものに書き換える
             */
            if ownNode.restore() {
                LogEssential("Restored Node Information.")
            } else {
                LogEssential("Can NOT Restore Node Information.")
            }
            
            /*
             Node#finger tableも復元したものを model.nodeに格納する
             */
            /*
             Arranged Node Information
             */
            Log(ownNode.signer()?.publicKeyForSignature?.rawRepresentation.base64String ?? "")
            Log(ownNode.signer()?.privateKeyForSignature?.rawRepresentation.base64String ?? "")
            Log("own: \(ownNode.signer()?.makerDhtAddressAsHexString ?? "")")
            Log(ownNode.signer()?.publicKeyForEncryption?.rawRepresentation.base64String ?? "")
            Log(ownNode.signer()?.privateKeyForEncryption?.rawRepresentation.base64String ?? "")
            self.ownNode = ownNode
            Log()
            #if os(iOS)
            Task { @MainActor in
                self.model?.ownNode = ownNode
            }
            #endif
            LogEssential(ownNode.dhtAddressAsHexString)
            Log(ownNode.ipAndPortString as Any)
            
            guard let ownNode = self.ownNode else {
                Log()
                return
            }
            let babysitterNode = Dht.getBabysitterNode(ownOverlayNetworkAddress: ownNode.dhtAddressAsHexString.toString)
            /*
             Test Mode
             Behavior as Boot Node, Set {RunAsBootNode} as Run Argument / Environment Variable on Edit Scheme on Xcode.
             */
            #if os(iOS)
            if Node.behaviorAsBootNode() {
                Log()
                /*
                 behavior as Boot Node.
                 */
                self.model?.babysitterNodeOverlayNetworkAddress = nil
            } else {
                Log()
                self.model?.babysitterNodeOverlayNetworkAddress = babysitterNode?.dhtAddressAsHexString
            }
            #endif
            if ownNode.fingerTableIsArchived() {
                Log()
                /*
                 Load FingerTable to memory from Device Store.
                 And Done with that.(That's All.)
                 */
                ownNode.deployFingerTableToMemory()
                ownNode.printArchivedFingerTable()
                self.ownNode = ownNode
                #if os(iOS)
                Task { @MainActor in
                    self.model?.ownNode = ownNode
                }
                #endif
                /*
                 if Not Behavior as Boot Node,
                 Do Stabilize Finger Table.
                 */
                #if os(iOS)
                if self.model?.babysitterNodeOverlayNetworkAddress != nil {
                    ownNode.stabilize()
                }
                #endif
            } else {
                ownNode.join(babysitterNode: babysitterNode)    //babysitterNode is nil if bootnode
            }
            Log()
            #if os(iOS)
            Task { @MainActor in
                Log()
                self.model?.screens += [.menu]
                Log()
            }
//            Log(model?.semaphore.debugDescription)
            model?.semaphore.signal()    //semaphore +1
//            Log(model?.semaphore.debugDescription)
            #endif
        }
    }
    
}
