//
//  ContentView.swift
//  Testy
//
//  Created by よういち on 2020/09/14.
//  Copyright © 2020 WEB BANANA UNITE Tokyo-Yokohama LPC. All rights reserved.
//

import SwiftUI
import LocalAuthentication
import blocks
import overlayNetworkObjc

struct TYButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
        .padding(.all, 8.0)
        .overlay(RoundedRectangle(cornerRadius: 10)
            .stroke(Color.red, lineWidth: 1.0)
            .frame(width: 200, height: 50, alignment: .center)
        )
        .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
    }
}

struct TYTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
        .padding(.horizontal, 8.0)
        .padding(.vertical, 16.0)
        .background(RoundedRectangle(cornerRadius: 10)
        .strokeBorder(Color.red, lineWidth: 1.0))
    }
}

enum Screen: Hashable {
//    case auth
    case menu
    case birth
    case mail
    case movein
    case moveout
    case information(String, [String: String]?, String?, String?)
}

//cupsule in root view controller
struct Auth: View {
    @EnvironmentObject var model: Model
    @State var ownNode: Node?
    let serialQueue = DispatchQueue(label: "org.webbanana.org.Testy")

    var body: some View {
        NavigationStack(path: $model.screens) {
            VStack {
                Text("Welcome")
                    .padding(.top, 50)
                Spacer()
                /*
                 Menu へ
                 */
                Button("Join blocks Network") {
                    Log()
                    /*
                     Check in by Biometric Authentication.
                     */
                    self.checkIn()
                }
                .buttonStyle(TYButtonStyle())
                Spacer()
            }
            .navigationBarTitle("SSN, 住民基本台帳")
            .navigationDestination(for: Screen.self) { screen in
                switch screen {
//                case .auth:
//                    Auth().environmentObject(Model.shared)
                case .menu:
                    Menu()
                case .birth:
                    Birth()
                case .mail:
                    Mail()
                case .movein:
                    MoveIn()
                case .moveout:
                    MoveOut()
                case .information(let takerAddress, let transactionAsDictionary, let peerPublicKeyAsString, let transactionId):
                    Information(takerAddress: takerAddress, transactionAsDictionary: transactionAsDictionary, peerPublicKeyAsString: peerPublicKeyAsString, transactionId: transactionId)
                }
            }
        }
        .onAppear() {
            Log()
            Log(model.semaphore.description)
            /*
             Ask Allowing Network Access.
             */
            Node.triggerLocalNetworkPrivacyAlert()
            Log()
            /*
             Ask Allowing make Popup Notification to User.
             */
            UNUserNotificationCenter.current().getNotificationSettings(completionHandler: {
                settings in
                Log(settings.authorizationStatus.rawValue)
                if settings.authorizationStatus != .authorized {    //2
                    Log()
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
                        granted, error in
                        Log(granted)
                        if let error = error {
                            Log(error)
                        }
                    }
                }
            })
        }
        .alert("Can't establish connection.", isPresented: $model.networkUnavailable) {
            Button("OK", role: .cancel) {
                Log()
            }
        }
//        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name.pleaseJoinNetworkNotification)) { data in
//            Log("onReceive")
//            var statusString = ""
//            if let content = (data.object as? UNNotificationContent){
//                Log("title:\(content.title), subtitle:\(content.subtitle)")
//                statusString = content.title
//            }
//            if let description = data.userInfo?["description"] as? String, description != "" {
//                Log(description)
////                statusString = description
//            }
//            if statusString != "" {
//                Task {
//                    await Notification.notifyToUser(statusString)
//                }
//            }
//        }
    }
    
    private func checkIn() -> Void {
        Log()
        
        #if DEBUG
        /*
         Check Momory Alignment for Byte Order.
         
         structure memory alignment
         */
        struct C {
            let a: Int16
            let b: Int8
        }
        Log(MemoryLayout<C>.alignment)//2
        Log(MemoryLayout<C>.size)//3
        Log(MemoryLayout<C>.stride)//4


        struct A {
            let a: Int8
            let b: Int64
            let c: Int32
        }
        Log(MemoryLayout<Int8>.size)//1
        Log(MemoryLayout<Int64>.size)//8
        Log(MemoryLayout<Int32>.size)//4

        Log(MemoryLayout<A>.alignment)//8
        Log(MemoryLayout<A>.size)//20
        Log(MemoryLayout<A>.stride)//24

        struct B {
            let b: Int32
            let a: Bool
            let c: Int64
            let d: Int8
        }
        Log(MemoryLayout<B>.alignment)//8
        Log(MemoryLayout<B>.size)//17
        Log(MemoryLayout<B>.stride)//24

        struct D {
            let b: Int32
            let a: Bool
            let c: Int64
            let d: Int8
            let e: Int16
        }
        Log(MemoryLayout<D>.alignment)//8
        Log(MemoryLayout<D>.size)//20
        Log(MemoryLayout<D>.stride)//24
        #endif

        /*
         生体認証(指紋or顔)
         */
        let localAuthContext = LAContext()
        let reason = "This app uses Touch ID / Face ID to secure your data."
        var authError: NSError?
        
        if localAuthContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            localAuthContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { (success, error) in
                if success {
                    Log("Authenticated")
                    /*
                     認証OK
                     ↓
                     アカウントの情報を取得する
                     ↓
                     機能メニューを表示
                     *Birth済みのとき、Birthボタンは非表示とする
                     機能メニュー
                     Birth
                     Mail - Send
                     MoveIn
                     MoveOut
                     */
                    /*
                     Communication with Using POSIX BSD Sockets.
                     */
                    let socket = Socket()
                    let rawbuf: UnsafeMutableRawBufferPointer = UnsafeMutableRawBufferPointer.allocate(byteCount: Socket.MTU, alignment: MemoryLayout<CChar>.alignment)
                    /*
                     Communicate with BSD Sockets for NAT Traversal.
                     
                     [Node]
                     Create Sockets Commucate with Signaling Server / Peer Node.
                     ↓
                     bind *bound same port number with Signaling Server / Peer Node.
                     ↓
                     connect *async / not wait done
                     ↓
                     do in other thread
                        ↓
                        ( while )
                            Leave out for failed connection.
                            ↓
                            select
                            ↓
                            recv / send data
                            ↓
                            Dequeue in command queue
                            ↓
                            Rearrange sockets for public ip / private ip for peer node
                                Bound same port number with Signaling Server / Peer Node.
                            ↓
                            Do NAT Traversal Process with Signaling Server / Peer Node.
                            ↓
                            Handshaked with Peer Node in Local Network inner NAT Router.
                            ↓
                            Send Command to Peer Node
                            ↓
                            wait 0.5s
                     */
                    guard let ownNode = Node(ownNode: IpaddressV4.null, port: 0, premiumCommand: blocks.Command.other) else {
                        return
                    }
                    socket.start(startMode: .registerMeAndIdling, tls: false, rawBufferPointer: rawbuf, node: ownNode, inThread: true, notifyOwnAddress: {
                        ownAddress in
                        /*
                         Done Making Socket
                         */
                        Log(ownAddress as Any)
                        Log()
                        guard let sourceAddress = ownAddress else {
                            Log()
                            return
                        }
                        actionsAfterMadeSocket()
                    }) {
//                        sentDataNodeIp, acceptedStringlength in
                        sentDataNodeIp, dataRange in
                        /*
                         Received Data on Listening Bound Port.
                         */
                        Log(sentDataNodeIp as Any)
                        Log(dataRange.count)
                        Log(rawbuf) //UnsafeMutableRawBufferPointer(start: 0x000000014980be00, count: 1024)
//                        guard acceptedStringlength > 0, let sentDataNodeIp = sentDataNodeIp else {Log()
//                            return
//                        }
                        guard dataRange.count > 0, let sentDataNodeIp = sentDataNodeIp else {Log()
                            return
                        }
                        /*
                         Transform [CChar] to String
                         */
//                        let acceptedString = rawbuf.toString(byteLength: acceptedStringlength)
                        let acceptedString = rawbuf.toString(byteRange: dataRange)
                        LogEssential(acceptedString)
                        
                        /*
                         Detect Command
                         */
                        DispatchQueue.main.async {
                            //Translate sentDataNodeIp to overlayNetworkAddress
                            guard let ownNode = self.ownNode, let overlayNetworkAddress = socket.findOverlayNetworkAddress(ip: sentDataNodeIp, node: ownNode) else {
                                Log("Invalid Received IP Address (Not Signaling yet): \(sentDataNodeIp)")
                                return
                            }
                            Log(overlayNetworkAddress)
                            ownNode.received(from: overlayNetworkAddress, data: acceptedString)
                        }
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
                        Task { @MainActor in
                            self.model.ownNode = ownNode
                        }
                        LogEssential(ownNode.dhtAddressAsHexString)
                        Log(ownNode.ipAndPortString as Any)

                        guard let ownNode = self.ownNode else {
                            Log()
                            return
                        }
                        let babysitterNode = Dht.getBabysitterNode(ownOverlayNetworkAddress: ownNode.dhtAddressAsHexString.toString)
                        /*
                         Test Mode
                         When Run As Boot Node, Set {RunAsBootNode} as Run Argument / Environment Variable on Edit Scheme on Xcode.
                         */
                        let setArgv = ProcessInfo.processInfo.arguments.contains("RunAsBootNode")
                        let envVar = ProcessInfo.processInfo.environment["RunAsBootNode"] ?? ""
                        if setArgv || envVar != "" {
                            Log()
                            /*
                             behavior as Boot Node.
                             */
                            self.model.babysitterNodeOverlayNetworkAddress = nil
                        } else {
                            Log()
                            self.model.babysitterNodeOverlayNetworkAddress = babysitterNode?.dhtAddressAsHexString
                        }
                        
                        if ownNode.fingerTableIsArchived() {
                            Log()
                            /*
                             Load FingerTable to memory from Device Store.
                             And Done with that.(That's All.)
                             */
                            ownNode.deployFingerTableToMemory()
                            ownNode.printArchivedFingerTable()
                            self.ownNode = ownNode
                            Task { @MainActor in
                                self.model.ownNode = ownNode
                            }
                        } else {
                            ownNode.join(babysitterNode: babysitterNode)    //babysitterNode is nil if bootnode
                        }
                        Log()
                        Task { @MainActor in
                            Log()
                            self.model.screens += [.menu]
                            Log()
                        }
                        Log(model.semaphore.debugDescription)
                        model.semaphore.signal()    //semaphore +1
                        Log(model.semaphore.debugDescription)
                    }
                } else {
                    let message = error?.localizedDescription ?? "Auth Failed"
                    Log(message)
                }
            }
        } else {
            let message = authError?.localizedDescription ?? "Not do Evaluation"
            Log(message)
        }
    }
}

struct Auth_Previews: PreviewProvider {
    static var previews: some View {
        Auth().environmentObject(Model.shared)
    }
}
