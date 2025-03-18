//
//  Mail.swift
//  Testy
//
//  Created by よういち on 2020/09/14.
//  Copyright © 2020 WEB BANANA UNITE Tokyo-Yokohama LPC. All rights reserved.
//

#if os(macOS) || os(iOS)
import SwiftUI
import overlayNetwork
import blocks

struct Mail: View {
    @EnvironmentObject var model: Model
    @State var description: String = ""
    @State var combinedSealedBox: Data?
    @State var attachedFileType: FileType?
    
    @State var selectingFile: Bool = false
    @State var takerAddress: OverlayNetworkAddressAsHexString?

    var body: some View {
        /*
         Reveal All Mails on App Screen in Descending Order.
         */
        VStack {
            Text("Received Mails")
                .font(.title)
                .padding()
            Form {
                if let node = model.ownNode {
                    let _ = Log(node.book.blocks.count)
                    let transactions = node.book.extract(node: node, transactionType: .mail) as! [blocks.Mail]
                    let _ = Log(transactions.count)
                    ForEach(transactions, id: \.self) { transaction in
                        let transactionType = transaction.type
                        let claim = transaction.claim
                        let transactionAsDictionary = transaction.contentAsDictionary
                        /*
                         transform content string to Claim Object
                         */
                        let claimObject: ClaimOnMail.Object = transaction.claimObject as? ClaimOnMail.Object ?? ClaimOnMail.Object(destination: String.OverlayNetworkAddressAsHexStringNull)
                        let destination = claimObject.destination
                        let peerPublicKeyForEncryptionAsData = claimObject.publicKeyForEncryption
                        let combinedSealedBox = claimObject.combinedSealedBox
                        let attachedFileType = FileType(rawValue: claimObject.attachedFileType)
                        let description = claimObject.description

                        VStack {
                            Group {
                                Label("From", systemImage: "")
                                    .bold()
                                Text(transaction.makerDhtAddressAsHexString.toString)
                                    .font(.caption)
                                Label("Public Key", systemImage: "")
                                    .bold()
                                Text(transaction.publicKey?.publicKeyToString ?? "")
                                    .font(.caption)
                                Label("Description:", systemImage: "")
                                    .bold()
                                Text(description)
                                    .font(.caption)
                            }
                            .padding(.bottom)
                            Group {
                                Label("Destination", systemImage: "")
                                    .bold()
                                Text(destination.toString)
                                    .font(.caption)
                                Label("Claim", systemImage: "")
                                    .bold()
                                Text(claim.rawValue ?? "")
                                    .font(.caption)
                                Label("Fee for Booker", systemImage: "")
                                    .bold()
                                Text(transaction.feeForBooker.asDecimal.formatted())
                                    .font(.caption)
                                Label("PublicKeyForEncryption", systemImage: "")
                                    .bold()
                                Text(peerPublicKeyForEncryptionAsData?.publicKeyForEncryptionToString ?? "")
                                    .font(.caption)
                            }
                            .padding(.bottom)
                            Group {
                                Label("Debit", systemImage: "")
                                    .bold()
                                Text(transaction.debitOnLeft.asDecimal.formatted())
                                    .font(.caption)
                                Label("Credit", systemImage: "")
                                    .bold()
                                Text(transaction.creditOnRight.asDecimal.formatted())
                                    .font(.caption)
                            }
                            /*
                             Mailに返信する
                             */
                            TextField("返信内容", text: $description)
                            Button("ファイルを添付する") {
                                self.selectingFile.toggle()
                            }
                            Button("返信") {
                                /*
                                 Birther, Taker, ...Other Commands
                                 */
                                if let transactionId = transaction.transactionId, let node = model.ownNode, let transactionPublicKey = transaction.publicKey, let peerPublicKeyForEncryptionAsData = peerPublicKeyForEncryptionAsData {
                                    reply(to: transaction.makerDhtAddressAsHexString, description: description, transactionType: transactionType, claim: claim, transactionId: transactionId, node: node, combinedSealedBox: self.combinedSealedBox, attachedFileType: self.attachedFileType, personalData: nil, peerPublicKeyAsData: transactionPublicKey, peerPublicKeyForEncryptionAsData: peerPublicKeyForEncryptionAsData)
                                }
                            }
                            Button("個人情報入力画面へ") {
                                /*
                                 for Birth-er
                                 */
                                self.takerAddress = transaction.makerDhtAddressAsHexString
                                let peerPublicKeyAsString = transaction.publicKey?.publicKeyToString
                                if let takerAddress = self.takerAddress, let transactionId = transaction.transactionId {
                                    self.model.screens += [.information(takerAddress.toString, transactionAsDictionary, peerPublicKeyAsString, transactionId.transactionIdentificationToString)]
                                }
                            }
                            Button("Birth重複チェックして Publish Transactionする") {
                                /*
                                 for Taker
                                 
                                 #あと　二重チェック
                                 Takerは基本的には、親権者や後見人が行う
                                 
                                 キャッシュ済みBlocksを３情報で検索する
                                 ↓ okなら
                                 添付文書をvalidate（目視
                                 ↓ okなら
                                 Person (Birth-ed) Transaction　2つ を publishする
                                     Person　入金　Taker手数料　→Taker（自分）
                                     Person　入金　出生時 basic income　→Birth-er
                                 ↓
                                 （受信）
                                 ファイル、個人データを復号する
                                 #now
                                 
                                 
                                 Birthのfind takerは１アカウントにつき１回のみ無料とする
                                 ↑
                                 block受け入れるとき、block publishするとき
                                 ↑
                                 blocksライブラリの機能として
                                    birth, basicincomeなど給付のあるものはblocksに入れる必要がある
                                 */
                                self.model.screens += [.birth]
                            }
                        }
                        .fileImporter(isPresented: $selectingFile, allowedContentTypes: FileType.importable, allowsMultipleSelection: false) {
                            selectedFile in
                            do {
                                let urls = try selectedFile.get()
                                Log(urls)
                                if let fileUrl = urls.first, let transactionPublicKey = transaction.publicKey, let peerPublicKeyForEncryptionAsData = peerPublicKeyForEncryptionAsData {
                                    Log(fileUrl)
                                    let fileData = try Data(contentsOf: fileUrl)
                                    self.attachedFileType = FileType(rawValue: fileUrl.pathExtension)
                                    /*
                                     Encript file
                                     ex. Curve25519.KeyAgreement.PrivateKey
                                     */
                                    let peerSigner = Signer(publicKeyAsData: transactionPublicKey, makerDhtAddressAsHexString: transaction.makerDhtAddressAsHexString, publicKeyForEncryptionAsData: peerPublicKeyForEncryptionAsData)
                                    if let peerPublicKeyForEncryption = peerSigner.publicKeyForEncryption {
                                        //暗号
                                        if let sealedBox = model.ownNode?.signer()?.encrypt(message: fileData, peerPublicKeyForEncryption: peerPublicKeyForEncryption) {
                                            self.combinedSealedBox = sealedBox.combined  //Data
                                        }
                                    }
                                }
                            } catch {
                                Log("error occurred. \(error)")
                            }
                        }
                        .padding()
                    }
                }
            }
            .formStyle(.automatic)
            .padding(EdgeInsets(top: 0, leading: 5, bottom: 50, trailing: 5))
        }
    }
    
    func reply(to destinationDhtAddress: OverlayNetworkAddressAsHexString, description: String, transactionType: TransactionType, claim: (any Claim)?, transactionId: TransactionIdentification, node: Node, combinedSealedBox: Data?, attachedFileType: FileType?, personalData: ClaimOnPerson.PersonalData?, peerPublicKeyAsData: PublicKey, peerPublicKeyForEncryptionAsData: PublicKeyForEncryption) {
        Log()
        /*
         Mailの Claim や内容によりmailBody内容を切り替える in replyBody
         */
        let peerSigner = Signer(publicKeyAsData: peerPublicKeyAsData, makerDhtAddressAsHexString: destinationDhtAddress, publicKeyForEncryptionAsData: peerPublicKeyForEncryptionAsData)
        if let personalDataAsDictionary = personalData {
            transactionType.reply(to: destinationDhtAddress, claim: claim, description: description, node: node, combinedSealedBox: combinedSealedBox, attachedFileType: attachedFileType, personalData: personalData, book: node.book, peerSigner: peerSigner)
        }
    }
}

struct Mail_Previews: PreviewProvider {
    static var previews: some View {
        Mail()
    }
}
#endif
