//
//  Information.swift
//  Testy
//
//  Created by よういち on 2020/09/15.
//  Copyright © 2020 WEB BANANA UNITE Tokyo-Yokohama LPC. All rights reserved.
//

#if os(macOS) || os(iOS)
import SwiftUI
import blocks
import overlayNetwork
import CoreLocationUI
import CoreLocation
import MapKit

struct Information: View {
    @EnvironmentObject var model: Model
    @StateObject var quadKey = QuadKey()
    @StateObject var quadKeyForBornedPlace = QuadKey()

    @State var realName = "田中太郎"
    @State var quadkeyString = "" //20文字固定
    @State var bornedquadkeyString = ""
    
    @State var realBirth = Date()
    @State var realTelephoneNumber = "0426778368"
    @State var description: String = ""
    
    let takerAddress: OverlayNetworkAddressAsHexString?
    @State var combinedSealedBoxForFile: Data?
    let transactionAsDictionary: [String: String]?
    @State var selectingFile: Bool = false
    
    let peerPublicKeyAsString: String?
    
    let transactionId: TransactionIdentification?
    @State var locationManager = CLLocationManager()
    @State var peerSigner: Signer?

    var body: some View {
        /*
         個人情報を入力
         個人情報「住所・氏名・生年月日・電話番号」をTakerにMail
         */
        ZStack {
            VStack {
                Form {
                    TextField("氏名", text: $realName)
                        .textContentType(.name)
                        .padding()
                    if let latlong = quadKey.latlong {
                        /*
                         latlong to quadkey
                         */
                        let quadKeyString = getQuadKey(latlong: latlong)
                        Text("Latitude: \(latlong.latitude) Longitude: \(latlong.longitude)")
                            .padding()
                        Text("QuadKey: \(quadKeyString)")
                            .padding()
                    } else {
                        Text("現在の住所地で出生証明を取得手続きを行なってください。")
                            .padding()
                    }
                    LocationButton(LocationButton.Title.currentLocation) {
                        quadKey.fetchCurrentLatlong()
                    }.foregroundColor(Color.white)
                        .cornerRadius(27)
                        .frame(width: 210, height: 54)
                        .padding(.bottom, 30)
                    
                    DatePicker(selection: $realBirth, displayedComponents: .date, label: {
                        Text("生年月日")
                    })
                    .padding()
                    if let latlong = quadKeyForBornedPlace.latlong {
                        /*
                         latlong to quadkey
                         */
                        let quadKeyString = getQuadKey(latlong: latlong, isBorned: true)
                        Text("Latitude: \(latlong.latitude) Longitude: \(latlong.longitude)")
                            .padding()
                        Text("QuadKey: \(quadKeyString)")
                            .padding()
                    } else {
                        Text("出生地の座標を取得")
                            .padding()
                    }
                    LocationButton(LocationButton.Title.currentLocation) {
                        quadKeyForBornedPlace.fetchCurrentLatlong()
                    }.foregroundColor(Color.white)
                        .cornerRadius(27)
                        .frame(width: 210, height: 54)
                        .padding(.bottom, 30)
                    TextField("電話番号", text: $realTelephoneNumber)
                        .textContentType(.telephoneNumber)
                        .padding()
                }
                
                VStack {
                    TextField("備考", text: $description)
                    Button("ファイルを添付する") {
                        self.selectingFile.toggle()
                    }
                    
                    Button("Mail to Taker") {
                        Log()
                        self.checkValue()
                        self.mailToTaker()
                    }
                    .buttonStyle(TYButtonStyle())
                }
                //allowedContentTypes: [.item] is allowing all file types.
                .fileImporter(isPresented: $selectingFile, allowedContentTypes: FileType.importable, allowsMultipleSelection: false) {
                    selectedFile in
                    do {
                        let urls = try selectedFile.get()
                        Log(urls)
                        if let fileUrl = urls.first {
                            Log(fileUrl)
                            let fileData = try Data(contentsOf: fileUrl)
                            /*
                             Cript a file.
                             */
                            if let peerPublicKeyForEncryption = self.peerSigner?.publicKeyForEncryption {
                                //暗号
                                if let sealedBox = model.ownNode?.signer()?.encrypt(message: fileData, peerPublicKeyForEncryption: peerPublicKeyForEncryption) {
                                    self.combinedSealedBoxForFile = sealedBox.combined  //Data
                                }
                            }
                        }
                    } catch {
                        Log("error occurred. \(error)")
                    }
                }
            }
            if let latlong = quadKeyForBornedPlace.latlong {
                VStack {
                    Map(center: latlong, quadKey: self.quadKeyForBornedPlace)
                        .edgesIgnoringSafeArea(.all)
                }
            }
        }
        .navigationBarTitle("個人情報")
        .onAppear {
            if let peerPublicKeyAsData = self.peerPublicKeyAsString?.base64DecodedData, let takerAddress = self.takerAddress,
               let peerPublicKeyForEncryptionAsBase64String = transactionAsDictionary?["PublicKeyForEncryption"],
               let peerPublicKeyForEncryptionAsData = peerPublicKeyForEncryptionAsBase64String.base64DecodedData {    //Data Encoded base64 String
                self.peerSigner = Signer(publicKeyAsData: peerPublicKeyAsData, makerDhtAddressAsHexString: takerAddress, publicKeyForEncryptionAsData: peerPublicKeyForEncryptionAsData)
            }
        }
    }
    
    func getQuadKey(latlong: CLLocationCoordinate2D, isBorned: Bool = false) -> String {
        let quadKeyString = quadKey.transform(latlong: latlong)
        Log(quadKeyString)  //{levelOfDetail}文字数
        if isBorned {
            self.bornedquadkeyString = quadKeyString
        } else {
            self.quadkeyString = quadKeyString
        }
        return quadKeyString
    }
    
    func checkValue() {
        Log()
    }
    
    func mailToTaker() {
        Log()
        /*
         as publish Transaction, check balance (left amount).
         */
        guard self.model.balanceInCachedBlock.asDecimal - self.model.consumedAmountOfPublishedTransaction.asDecimal - TransactionType.person.fee().asDecimal >= 0 else {
            Log("No Amount in Balance.")
            return
        }
        /*
         Transaction作成
         */
        self.model.checkedInformation = true
        if let node = model.ownNode, let takerAddress = self.takerAddress, let transactionAsDictionary = self.transactionAsDictionary, let transactionId = self.transactionId, let bornedLatlong = quadKeyForBornedPlace.latlong {
            /*
             Mail   Birth
             ↓　　　　↓ QR 直接アドレス入力
             Information入力画面
             */
            let claimRawValue = transactionAsDictionary["Claim"] ?? ""
            let claim = TransactionType.mail.construct(rawValue: claimRawValue)
            let personalData = ClaimOnPerson.PersonalData(name: self.realName, birth: self.realBirth.toUTCString, place: self.quadkeyString, bornPlace: self.bornedquadkeyString, phone: self.realTelephoneNumber)
            send(to: takerAddress, claim: claim, transactionId: transactionId, node: node, personalData: personalData)
        }
    }
    
    func send(to destinationDhtAddress: OverlayNetworkAddressAsHexString, claim: (any Claim)?, transactionId: TransactionIdentification, node: Node, personalData: ClaimOnPerson.PersonalData) {
        Log()
        /*
         Mailの Claim や内容によりmailBody内容を切り替える
         */
        if let claim = claim, let signer = model.ownNode?.signer() {
            Log()
            //encrypt personal data
            if let peerPublicKeyForEncryption = self.peerSigner?.publicKeyForEncryption {
                let claimObject = ClaimOnPerson.askForTaker.construct(destination: destinationDhtAddress, publicKeyForEncryption: peerPublicKeyForEncryption.rawRepresentation, combinedSealedBox: "", description: description, attachedFileType: "", personalData: personalData)
                if let publicKeyForSignatureAsData = node.signer()?.publicKeyAsData {
                    Log()
                    if var mail = TransactionType.mail.construct(claim: claim, claimObject: claimObject, makerDhtAddressAsHexString: destinationDhtAddress, publicKey: publicKeyForSignatureAsData, book: node.book, signer: signer) as? blocks.Mail, let signer = model.ownNode?.signer() {
                            Log()
                            mail.send(node: node, signer: signer)
                    }
                }
            }
        }
    }
}

struct Infomation_Previews: PreviewProvider {
    static var previews: some View {
        Information(realName: "", realBirth: Date(), realTelephoneNumber: "", takerAddress: "", transactionAsDictionary: [:], peerPublicKeyAsString: nil, transactionId: nil).environmentObject(Model.shared)
    }
}
#endif
