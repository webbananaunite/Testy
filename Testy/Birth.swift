//
//  Birth.swift
//  Testy
//
//  Created by よういち on 2020/09/14.
//  Copyright © 2020 WEB BANANA UNITE Tokyo-Yokohama LPC. All rights reserved.
//

import SwiftUI
import blocks
import overlayNetwork
import QuickLook

/*
 [住民基本台帳]   公共システム
 Person（Inheritance登録内容追加）         アカウント情報／ユーザー
    SystemID
    Name
    Where(Address)
    Registered Date
    前の住所
    世帯主
 
 Birth(Inheritance登録内容追加)          出生届
    Json        トランザクションの内容
        ex. { transactionId: xxx, date:yyyymmdd hhmmss.ss, maker: xxx, from: xxx, to: xxx, amount: xxx, unit: xxx, rentTime: yyyymmdd hhmm }

 MoveIn(Inheritance登録内容追加)         転入届
    Json
 
 MoveOut(Inheritance登録内容追加)        転出届
 */
/*
 ＜Birthの流れ＞
 Takerアドレスを設定
     Takerがわかっている時
        TakerアドレスをQRコード読み取り or コピペ入力
     Takerがいない時
         Takerを探す
            Takerが見つからない場合にはUnMover宛にMail
 ↓
 個人情報「住所・氏名・生年月日・電話番号」をTakerにMail
 ↓
 Takerから署名済み個人情報が届く（Hash->ECDSA256->Base64）
 ↓
 Birthトランザクションを発行
    Mail#Birthをinvokeする
 */
struct Birth: View {
    @EnvironmentObject var model: Model
    @State var takerAddress: String?
    @State var doneCheckDuplicatePerson: Bool = false
    @State var personDuplicationResult: String = ""
    @State private var openPdfViewer = false
    @State private var showingPreview = false
    @State var fileUrl: URL?

    //cachesDirectory: Temp directory
    private static let temporaryDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first! + "/mailAttachedfile/"
    
    var body: some View {
        /*
         実現する機能
         Blocks.swiftのAbstractを参照
         ↓
         Birth       出生届
             自然人が一人１回だけBirthできる
             １８歳以上の成人のみBirth＆Transactionできる（未成年は利用できない）
             自分自身をBirthする
                 身元保証人(Taker)１名の個人情報への署名が必要
             TakerにはBirthした人の公開鍵（アドレス）がわからない
  
             Json     トランザクションの内容
                 ex. { transactionId: xxx, date:yyyymmdd hhmmss.ss, maker: xxx, from: xxx, to: xxx, amount: xxx, unit: xxx, rentTime: yyyymmdd hhmm }
  
        ＜Birthの流れ＞
         実在証明書を取得する
         Informationを書いて
         ↓
         Taker / UnMover をみつける (find taker
         ↓
         Takerの公開鍵で暗号する
         ↓
         TakerにMailでInformaitonをBirth意図(Intent)とともに送付する
         
         ＊緯度経度の地に何か置いておく？　で証明する？
         
         ↓
         （Taker）秘密鍵で個人情報「住所座標・氏名・生年月日・（出生地座標）・電話番号」に署名（Hash->ECDSA256->Base64）して返信する
            ＊座標コードに何を使うか

         
         参考）
         quadKey　ジオハッシュの一つ
         https://www.fuzina.com/blog/2020/01/11/quadkeyで範囲検索を行う.html
         https://learn.microsoft.com/en-us/bingmaps/articles/bing-maps-tile-system?redirectedfrom=MSDN
         メルカトル図法
         精度が高く、範囲も正方形、隣接タイルの取得も容易
         19で1ブロックほど、16で町レベル、14で区レベル、12で市レベル
         
         細部のレベル    地図の幅と高さ(ピクセル)    地上解像度(メートル/ピクセル)    マップスケール
         (96 dpiで)
         1    512    78,271.5170    1 : 295,829,355.45
         ...
         14    4,194,304    9.5546    1 : 36,111.98
         16    16,777,216    2.3887    1 : 9,028.00
         23    2,147,483,648    0.0187    1 : 70.53
         
         ↓
         （Birth）Person - Birthする
         */
        VStack {
            /*
             Reveal all Mail about Birth.
             */
            Text("Received Birth Requests")
                .font(.title)
                .padding()
            Form {
                if let node = model.ownNode {
                    let _ = Log(node.book.blocks.count)
                    let transactions = node.book.extract(node: node, transactionType: .person) as! [ImplementedPerson]
                    let _ = Log(transactions.count)
                    ForEach(transactions, id: \.self) { transaction in
                        /*
                         transform content string to Claim Object
                         */
                        let claimObject: ClaimOnPerson.Object = transaction.claimObject as! ClaimOnPerson.Object
                        let destination = claimObject.destination
                        let peerPublicKeyForEncryptionAsData = claimObject.publicKeyForEncryption
                        let combinedSealedBox = claimObject.combinedSealedBox
                        let attachedFileType = FileType(rawValue: claimObject.attachedFileType)
                        let description = claimObject.description
                        let personalData = claimObject.personalData

                        VStack {
                            Group {
                                Label("Transfer:", systemImage: "")
                                Group {
                                    Label("Debit", systemImage: "")
                                        .bold()
                                    Text(transaction.debitOnLeft.asDecimal.formatted())
                                        .font(.caption)
                                    Label("Credit", systemImage: "")
                                        .bold()
                                    Text(transaction.creditOnRight.asDecimal.formatted())
                                        .font(.caption)
                                    Label("Fee for Booker", systemImage: "")
                                        .bold()
                                    Text(transaction.feeForBooker.asDecimal.formatted())
                                        .font(.caption)
                                }
                            }
                            Button("Birth重複チェック") {
                                if let signer = node.signer() {
                                    if transaction.validate() {
                                        //valid
                                        personDuplicationResult = "It's Fine."
                                        doneCheckDuplicatePerson = true
                                    } else {
                                        //Duplicated
                                        personDuplicationResult = "It's Duplicated Person."
                                        doneCheckDuplicatePerson = true
                                    }
                                }
                            }
                            .disabled(transaction.claim.rawValue != ClaimOnPerson.askForTaker.rawValue)
                            Button("添付文書を見る(ダウンロード)") {
                                /*
                                 for Taker
                                 
                                 自分の秘密鍵で文書を復号
                                 ↓
                                 添付文書をvalidate（目視
                                 ↓ okなら
                                 Person (Birth-ed) Transaction を publishする
                                 入金　Taker手数料　→Taker（自分）
                                 入金　出生時 basic income　→Birth-er
                                 
                                 
                                 （Taker）秘密鍵で個人情報「住所座標・氏名・生年月日・（出生地座標）・電話番号」に署名（Hash->ECDSA256->Base64）して返信する
                                 ＊座標コードに何を使うか
                                 */
                                
                                /*
                                 Decrypt Base64 String to File Content String.
                                 */
                                if let transactionPublicKey = transaction.publicKey {
                                    let peerSigner = Signer(publicKeyAsData: transactionPublicKey, makerDhtAddressAsHexString: transaction.makerDhtAddressAsHexString, publicKeyForEncryptionAsData: peerPublicKeyForEncryptionAsData)
                                    if let peerPublicKeyForEncryption = peerSigner.publicKeyForEncryption {
                                        if let fileAsEncryptedData = combinedSealedBox.base64DecodedData {
                                            //decryption
                                            if let fileAsData = model.ownNode?.signer()?.decrypt(combinedSealedBox: fileAsEncryptedData, peerPublicKeyForEncryption: peerPublicKeyForEncryption) {
                                                /*
                                                 save data to temporary directory.
                                                 ↓
                                                 represent the file in temporary directory.
                                                 */
                                                do {
                                                    let url = URL(fileURLWithPath: Birth.temporaryDirectory + "fileName" + "." + (attachedFileType?.rawValue ?? ""))
                                                    try fileAsData.write(to: url)
                                                    self.fileUrl = url
                                                    //represent the file in temporary directory.
                                                    self.showingPreview = true
                                                } catch {
                                                    Log(error)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .sheet(isPresented: $showingPreview) {
                                VStack {
                                    HStack {
                                        Spacer()
                                        Button("閉じる") {
                                            self.showingPreview = false
                                        }
                                        .padding()
                                    }
                                    if let fileUrl = self.fileUrl {
                                        PreviewController(url: fileUrl)
                                    }
                                }
                            }
                            Button("Publish Transaction(Person)") {
                                /*
                                 Person (Birth-ed) Transaction を publishする
                                 入金　Taker手数料　→Taker（自分）
                                 入金　出生時 basic income　→Birth-er
                                 
                                 transaction 2 pieces
                                 */
                                if let transactionId = transaction.transactionId, let transactionPublicKey = transaction.publicKey, let node = model.ownNode, let signer = node.signer() {
                                    let peerSigner = Signer(publicKeyAsData: transactionPublicKey, makerDhtAddressAsHexString: transaction.makerDhtAddressAsHexString, publicKeyForEncryptionAsData: peerPublicKeyForEncryptionAsData)
                                    /*
                                     Make Transaction Content by Claim.
                                     */
                                    let claimObject = ClaimOnPerson.born.construct(destination: transaction.makerDhtAddressAsHexString, publicKeyForEncryption: nil, combinedSealedBox: combinedSealedBox, description: "", attachedFileType: attachedFileType?.rawValue ?? "", personalData: ClaimOnPerson.PersonalData(name: "", birth: "", place: "", bornPlace: "", phone: ""))
                                    
                                    if let publicKeyAsData = signer.publicKeyAsData,
                                       let personTransaction = TransactionType.person.construct(claim: ClaimOnPerson.born, claimObject: claimObject, makerDhtAddressAsHexString: transaction.makerDhtAddressAsHexString, publicKey: publicKeyAsData, book: node.book, signer: signer, peerSigner: peerSigner) as? ImplementedPerson {
                                        Log()
                                        /*
                                         Add Basic income deposit to Birth-er, and Born Fee to own.
                                         */
                                        var addedBasicIncomeTransaction = personTransaction
                                        addedBasicIncomeTransaction.addBasicIncomeAtborn(to: transaction.makerDhtAddressAsHexString)
                                        var addedBornTransaction = personTransaction
                                        addedBornTransaction.addBornFeeToOwn()
                                        var transactions = Transactions(transactions: [addedBasicIncomeTransaction, addedBornTransaction])
                                        transactions.send(node: node, signer: signer)
                                    }
                                }
                            }
                            .disabled(transaction.claim.rawValue != ClaimOnPerson.askForTaker.rawValue)
                        }
                    }
                }   //if
            }   //Form
            .formStyle(.automatic)
            .padding(EdgeInsets(top: 0, leading: 5, bottom: 50, trailing: 5))
            Button("Find Taker") {
                self.findTaker()
            }
            .buttonStyle(TYButtonStyle())
            .padding()
            Button("QR Code") {
                self.qrRead()
            }
            .buttonStyle(TYButtonStyle())
            .padding()
            Button("Input Taker Address") {
                self.inputAddress()
            }
            .buttonStyle(TYButtonStyle())
            .padding()
            .alert(personDuplicationResult, isPresented: $doneCheckDuplicatePerson) {
                Button("OK", role: .cancel) {
                    Log()
                }
            }
        }   //VStack
        .navigationBarTitle("Birth")
    }
    //#now should modify for showing message as done inited finger table.
    
    func reply(to destinationDhtAddress: OverlayNetworkAddressAsHexString, description: String, transactionType: TransactionType, claim: (any Claim)?, transactionId: String, node: Node, combinedSealedBox: Data?, attachedFileType: FileType?, personalData: ClaimOnPerson.PersonalData?, peerPublicKey: PublicKey, peerPublicKeyForEncryptionAsData: PublicKeyForEncryption) {
        Log()
        /*
         Mailの Claim や内容によりmailBody内容を切り替える in replyBody
         */
        let peerSigner = Signer(publicKeyAsData: peerPublicKey, makerDhtAddressAsHexString: destinationDhtAddress, publicKeyForEncryptionAsData: peerPublicKeyForEncryptionAsData)
        if let personalDataAsDictionary = personalData {
            transactionType.reply(to: destinationDhtAddress, claim: claim, description: description, node: node, combinedSealedBox: combinedSealedBox, attachedFileType: attachedFileType, personalData: personalData, book: node.book, peerSigner: peerSigner)
        }
    }

    /*
     BirthのためにTakerを探す
     */
    private func findTaker() {
        Log()
        /*
         Publish FindTaker Claim.
         */
        if let ownNode = self.model.ownNode {
            Log()
            /*
             Send .findTaker Command to BabySitter node.  Optional("hI+onwABLj4eUNRRnltD4k6utv4nkz9tDOt9bluz2ak=")  43char = 240+18 = 258
             */
            LogEssential(ownNode.signer()?.base64EncodedPrivateKeyForSignatureString)
            LogEssential(ownNode.signer()?.base64EncodedPublicKeyForSignatureString)
            if let signer = ownNode.signer(), let publicKeyAsData = signer.publicKeyAsData, let publicKeyForEncryptionAsData = signer.publicKeyForEncryption?.rawRepresentation {
                Log()
                //Build Content
                let claimObject = ClaimOnPerson.findTaker.construct(destination: ClaimOnPerson.destinationBroadCast, publicKeyForEncryption: publicKeyForEncryptionAsData, combinedSealedBox: "", description: "", attachedFileType: "", personalData: ClaimOnPerson.PersonalData.null)
                Log()
                if var personTransaction = TransactionType.person.construct(claim: ClaimOnPerson.findTaker, claimObject: claimObject, makerDhtAddressAsHexString: ownNode.dhtAddressAsHexString, publicKey: publicKeyAsData, book: ownNode.book, signer: signer, date: Date.now) as? ImplementedPerson {
                    personTransaction.send(node: ownNode, signer: signer)
                }
            }
        }
    }
    private func qrRead() {
        Log()
        //#あと
        
        if let takerAddress = self.takerAddress {
            self.model.screens += [.information(takerAddress, nil, nil, nil)]
        }
    }
    private func inputAddress() {
        Log()
        if let takerAddress = self.takerAddress {
            self.model.screens += [.information(takerAddress, nil, nil, nil)]
        }
    }
}

/*
 Thank:
 https://nilcoalescing.com/blog/PreviewFilesWithQuickLookInSwiftUI/

 https://developer.apple.com/documentation/quicklook/qlpreviewcontroller
 Applicable File types:
 iWork documents
 Microsoft Office documents
 Rich text format, or RTF, documents
 PDF files
 Images
 Text files with a uniform type identifier that conforms to the public.text type. To learn more, see Uniform type identifiers.
 Comma-separated values, or CSV, files
 3D models in the USDZ format with both standalone and AR views for viewing the model
 */
struct PreviewController: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {
    }

    class Coordinator: QLPreviewControllerDataSource {
        let parent: PreviewController

        init(parent: PreviewController) {
            self.parent = parent
        }
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            return 1
        }
        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            return parent.url as NSURL
        }
    }
}

struct Birth_Previews: PreviewProvider {
    static var previews: some View {
        Birth(takerAddress: "").environmentObject(Model.shared)
    }
}
