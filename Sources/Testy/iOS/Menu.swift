//
//  Menu.swift
//  Testy
//
//  Created by よういち on 2020/09/14.
//  Copyright © 2020 WEB BANANA UNITE Tokyo-Yokohama LPC. All rights reserved.
//

#if os(macOS) || os(iOS)
import SwiftUI
import SharedDesignSystem
import blocks

struct Menu: View {
    @EnvironmentObject var model: Model
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("App Status")
                        .font(.headline)
                    Text(model.overlayNetworkStatus ?? "Just Wait Have Join blocks Network.")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .testyGlassCard()

                VStack(alignment: .leading, spacing: 8) {
                    let balance = model.balanceInCachedBlock.asDecimal - model.consumedAmountOfPublishedTransaction.asDecimal
                    Text("Balance")
                        .font(.headline)
                    Text(balance.formatted())
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .testyGlassCard()

                VStack(spacing: 14) {
                    Button("Birth") {
                        Log()
                        model.ownNode?.printQueueEssential()
                        Log(model.ownNode?.fingers.count)
                        self.model.screens += [.birth]
                    }
                    .buttonStyle(TestyGlassButtonStyle())

                    Button("Demand Basic Income Monthly") {
                        Log()
                        publishDemandBasicIncomeTransaction()
                    }
                    .buttonStyle(TestyGlassButtonStyle())

                    Button("Mail") {
                        Log()
                        model.ownNode?.printSocketQueueEssential()
                        self.model.screens += [.mail]
                    }
                    .buttonStyle(TestyGlassButtonStyle())

                    Button("MoveIn") {
                        Log()
                        model.ownNode?.printFingerTableEssential()
                        self.model.screens += [.movein]
                    }
                    .buttonStyle(TestyGlassButtonStyle())

                    Button("MoveOut") {
                        Log()
                        self.model.screens += [.moveout]
                    }
                    .buttonStyle(TestyGlassButtonStyle())
                }
                .testyGlassCard()
            }
            .padding(20)
        }
        .navigationBarTitle("Menu")
        .testyScreen()
        .onAppear {
            Log()
            /*
             Caluculate Balance on Cached Book.
             */
            if let node = model.ownNode {
                model.balanceInCachedBlock = node.book.balance(dhtAddressAsHexString: node.dhtAddressAsHexString)
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
    
    /*
     Publish Transaction for Basic Income.
     */
    func publishDemandBasicIncomeTransaction() {
        Log()
        let claimObject = ClaimOnPerson.demandBasicIncome.construct(destination: "", publicKeyForEncryption: nil, combinedSealedBox: "", description: "", attachedFileType: "", personalData: ClaimOnPerson.PersonalData.null)
        if let node = model.ownNode, let signer = node.signer(), let publicKeyAsData = signer.publicKeyAsData {
            if let basicIncomeTransaction = TransactionType.person.construct(claim: ClaimOnPerson.demandBasicIncome, claimObject: claimObject, makerDhtAddressAsHexString: node.dhtAddressAsHexString, publicKey: publicKeyAsData, book: node.book, signer: signer, creditOnRight: Work.basicincomeMonthly.income()) {
                basicIncomeTransaction.publish(on: node, with: signer)
            }
        }
    }
}
//
//extension Notification.Name {
//    static let detectExecuteDoneNotification = Notification.Name("org.webbanana.Testy.detectExecuteDoneNotification")
//}

struct Menu_Previews: PreviewProvider {
    static var previews: some View {
        Menu()
    }
}
#endif
