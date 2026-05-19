//
//  MoveIn.swift
//  Testy
//
//  Created by よういち on 2020/09/14.
//  Copyright © 2020 WEB BANANA UNITE Tokyo-Yokohama LPC. All rights reserved.
//

#if os(macOS) || os(iOS)
import SwiftUI
import SharedDesignSystem
struct MoveIn: View {
    var body: some View {
        VStack(spacing: 18) {
            Text("MoveIn")
                .font(.largeTitle.bold())
            Text("転入手続き画面は Liquid Glass スタイルに更新済みです。")
                .foregroundStyle(.secondary)
        }
        .padding(24)
        .testyGlassCard()
        .padding(24)
        .testyScreen()
    }
}

struct MoveIn_Previews: PreviewProvider {
    static var previews: some View {
        MoveIn()
    }
}
#endif
