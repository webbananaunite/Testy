//
//  ContentView.swift
//  Testy
//
//  Created by よういち on 2020/09/14.
//  Copyright © 2020 WEB BANANA UNITE Tokyo-Yokohama LPC. All rights reserved.
//

#if os(macOS) || os(iOS)
import SwiftUI
import LocalAuthentication
import blocks
import SharedDesignSystem

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
            VStack(spacing: 28) {
                Spacer()
                VStack(alignment: .leading, spacing: 12) {
                    Text("SSN, 住民基本台帳")
                        .font(.largeTitle.weight(.bold))
                    Text(model.overlayNetworkStatus ?? "Welcome")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .testyGlassCard()

                VStack(spacing: 16) {
                    Label("Secure access to the blocks network", systemImage: "faceid")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Button("Join blocks Network") {
                        Log()
                        /*
                         Check in by Biometric Authentication.
                         */
                        self.checkIn()
                    }
                    .buttonStyle(TestyGlassButtonStyle())
                }
                .frame(maxWidth: .infinity)
                .testyGlassCard()
                Spacer()
            }
            .padding(24)
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
        .testyScreen()
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
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name.detectExecuteDoneNotification)) { data in
            Log("onReceive")
            Log(data.object)
            Log(data.userInfo)
            var statusString = ""
            if let content = (data.object as? UNNotificationContent){
                Log("title:\(content.title), subtitle:\(content.subtitle)")
                statusString = content.title
            }
            if let description = data.userInfo?["description"] as? String, description != "" {
                Log(description)
//                statusString = description
            }
            if statusString != "" {
                Task {
                    model.overlayNetworkStatus = statusString
                    await Notification.notifyToUser(statusString)
                }
            }
        }
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
                    Communication(ownNode: self.ownNode, model: self.model).withUsingPOSIXBSDSocket()
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
#endif
