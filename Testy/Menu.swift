//
//  Menu.swift
//  Testy
//
//  Created by よういち on 2020/09/14.
//  Copyright © 2020 WEB BANANA UNITE Tokyo-Yokohama LPC. All rights reserved.
//

import SwiftUI
import blocks

struct Menu: View {
    @EnvironmentObject var model: Model
    var body: some View {
        VStack {
            Text("App Status")
                .bold()
            Text(model.overlayNetworkStatus ?? "Just Wait Have Join blocks Network.")
                .padding(.bottom, 50)
        }
        /*
         機能メニューを表示
         
         機能メニュー
         Birth
         Mail - Send
         MoveIn
         MoveOut
         */
        VStack {
            /*
             残高表示
             */
            HStack {
                let balance = model.balanceInCachedBlock.asDecimal - model.consumedAmountOfPublishedTransaction.asDecimal
                Text("Balance")
                Text(balance.formatted())
            }
            
            Button("Birth") {
                Log()
                model.ownNode?.printFingerTableEssential()
                Log(model.ownNode?.fingers.count)
                self.model.screens += [.birth]
            }
            .buttonStyle(TYButtonStyle())
            .padding(.bottom, 50)
            
            /*
             Ask for BasicIncome by Any Account Monthly.
                Tap BasicIncome Button
                or
                as Boot the App, Prompt to Demand Basicincome.
             ↓
             As publish Block, check duplicate by Booker.
                Reject as Duplication.
             ↓
             As received a Block, check duplicate by All node.
                Reject as Duplication.

             */
            Button("Demand Basic Income Monthly") {
                Log()
                publishDemandBasicIncomeTransaction()
            }
            .buttonStyle(TYButtonStyle())
            .padding(.bottom, 50)
            Button("Mail") {
                Log()
                self.model.screens += [.mail]
            }
            .buttonStyle(TYButtonStyle())
            .padding(.bottom, 50)
            Button("MoveIn") {
                Log()
                self.model.screens += [.movein]
            }
            .buttonStyle(TYButtonStyle())
            .padding(.bottom, 50)
            Button("MoveOut") {
                Log()
                self.model.screens += [.moveout]
            }
            .buttonStyle(TYButtonStyle())
            Spacer()
        }
        .navigationBarTitle("Menu")
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
