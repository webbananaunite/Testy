//
//  Pin.swift
//  Testy
//
//  Created by よういち on 2020/09/15.
//  Copyright © 2020 WEB BANANA UNITE Tokyo-Yokohama LPC. All rights reserved.
//

#if os(macOS) || os(iOS)
import SwiftUI
import blocks
import SharedDesignSystem

struct Pin: View {
    @EnvironmentObject var model: Model
    @State var pin: String
    let takerAddress: String?
    @State var combinedSealedBox: Data?

    var body: some View {
        VStack(spacing: 18) {
            Text("Taker Address")
                .font(.headline)
            Text(takerAddress ?? "")
                .padding()
                .testyGlassCard()
            Spacer()
            TextField("Input Pin", text: $pin)
                .textFieldStyle(TestyGlassTextFieldStyle())
            Button(action: {
                Log()
                self.authPin()
            }) {
                Text("OK")
            }
            .buttonStyle(TestyGlassButtonStyle())
            Spacer()
        }
        .padding(24)
        .navigationBarTitle("Pin")
        .testyScreen()
    }
    
    func authPin() {
        Log()
        if let takerAddress = self.takerAddress {
            self.model.screens += [.information(takerAddress, nil, nil, nil)]
        }
    }
}

struct Pin_Previews: PreviewProvider {
    static var previews: some View {
        Pin(pin: "", takerAddress: "ABCskldasie8389skldasie8389kadskldasie8389skldasie8389BCskldasie8389skldasie8389kadskldasie8389skldasie83892498")
    }
}
#endif
