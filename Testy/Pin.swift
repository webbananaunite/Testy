//
//  Pin.swift
//  Testy
//
//  Created by よういち on 2020/09/15.
//  Copyright © 2020 WEB BANANA UNITE Tokyo-Yokohama LPC. All rights reserved.
//

import SwiftUI
import blocks

struct Pin: View {
    @EnvironmentObject var model: Model
    @State var pin: String
    let takerAddress: String?
    @State var combinedSealedBox: Data?

    var body: some View {
        VStack {
            Text("Taker Address")
            Text(takerAddress ?? "")
            .padding()
            Spacer()
            TextField("Input Pin", text: $pin)
            .padding()
                Button(action: {
                    Log()
                    self.authPin()
                }) {
                    Text("OK")
                }
            Spacer()
        }
        .navigationBarTitle("Pin")
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
