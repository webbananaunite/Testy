//
//  Model.swift
//  Testy
//
//  Created by よういち on 2020/09/14.
//  Copyright © 2020 WEB BANANA UNITE Tokyo-Yokohama LPC. All rights reserved.
//

import SwiftUI
import blocks

class Model: ObservableObject {
    static let shared = Model()
    private init() {}
    
    /*
     Observed Property
     */
    @Published var didAuth = false
    @Published var resolvedTakerAddress = false
    @Published var didAuthPin = false
    @Published var checkedInformation = false
    @Published var networkUnavailable = false
    @Published var ownNode: Node?
    
    @Published var screens = [Screen]()
    @Published var overlayNetworkStatus: String?

    @Published var balanceInCachedBlock: BK = Decimal.zero      //直近blockまでの残高
    @Published var consumedAmountOfPublishedTransaction: BK = Decimal.zero      //未BlockedのPublished Transactionでの消費高

    /*
     Property
     */
    var babysitterNodeIp: String?
}
