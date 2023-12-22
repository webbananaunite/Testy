//
//  StreamViewer.swift
//  Testy
//
//  Created by よういち on 2021/07/13.
//  Copyright © 2021 WEB BANANA UNITE Tokyo-Yokohama LPC. All rights reserved.
//
/*
 責任:
 Finger Table テスト用モデル

 概要:
 Menu の代わりに使用した
 Finger Tableの生成を確認するために用いた
 */

import SwiftUI
import blocks

struct StreamViewer: View {
    @EnvironmentObject var model: Model
    @State var myIpAddress: String
    @State var babysitterIpAddress: String
    @State var babysitterNodeDisp: String
    @State var key: String = "099f3ce797b4fcdd28b33987751f821f251b61b7f16b31dbf38888e560a2ec0c1492fc41332ce86b330cc98cb2ac8bdcf482c61703ecfdcd58d7b94f2ae29876"
    
    var validIpAddressV4: Bool {
        if babysitterIpAddress.isEmpty {
            return false
        }
        let ipAddressPattern = #"^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$"#
        let result = babysitterIpAddress.range(
            of: ipAddressPattern,
            options: .regularExpression
        )
        Log("\(babysitterIpAddress) \((result != nil))")

        return (result != nil)
    }

    var body: some View {
        VStack {
            Label("My IP", systemImage: "sun.max")
            TextField("MyIP", text: $myIpAddress)
            .textContentType(.none)
            .textFieldStyle(TYTextFieldStyle())
            .keyboardType(.default)
            .padding(.bottom, 25)
            .frame(width: 200, height: 50, alignment: .center)

            Button("Start/Stop") {
                Log()
                self.switchStreaming()
            }
            .buttonStyle(TYButtonStyle())
            .padding(.bottom, 50)

            Label("BabySitterNode", systemImage: "")
            
            HStack {
                TextField("IP", text: $babysitterNodeDisp)
                .textContentType(.none)
                .textFieldStyle(TYTextFieldStyle())
                .keyboardType(.default)
            }
            .frame(width: 200, height: 50, alignment: .center)
            .padding(.bottom, 25)
            Label("Put Out FingerTable In Memory.", systemImage: "")
            Button("Put Out") {
                Log()
                model.ownNode?.printFingerTableEssential()
                model.ownNode?.storeFingerTable()
            }
            .buttonStyle(TYButtonStyle())
            .padding(.bottom, 50)

            TextField("Key", text: $key, prompt: Text("取得したいリソースを入力します"))
            Button("リソース取得") {
                Log()
                if let myResource = fetchResource(hashedKey: key) {
                    Log(myResource)
                }
            }
            .disabled(!validIpAddressV4)
            .buttonStyle(TYButtonStyle())
            .padding(.bottom, 50)
            Spacer()
        }
        .navigationBarTitle("Socket")
    }
    
    let acceptableStreaming = AcceptStreamingBlocks()
    let connectedStreaming = StreamingBlocks()

    private func switchStreaming() -> Void {
        self.acceptableStreaming.streamStart()
    }
    
    private func ping(ipAddress: String) {
        Log()
        self.connectedStreaming.streamTest(ip: babysitterIpAddress)
        self.connectedStreaming.pingTest()
    }
    
    /*
     リソース取得
     
     A Node
     get holder in finger table
     ↓
     リソースください to holder
     ↓
     holder
     自分の管理リソースか確認
     ↓
     リソースを渡す to node
     */
    private func fetchResource(hashedKey: String) -> String? {
        Log()
        return model.ownNode?.callForFetchResource(hashedKey: hashedKey)
    }
    
    private func fetchResource(key: String) -> String? {
        Log()
        return model.ownNode?.callForFetchResource(key: key)
    }
}
