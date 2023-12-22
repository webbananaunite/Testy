//
//  TestyApp.swift
//  Testy
//
//  Created by よういち on 2023/11/27.
//  Copyright © 2023 WEB BANANA UNITE Tokyo-Yokohama LPC. All rights reserved.
//

import Foundation
import SwiftUI

@main
struct TestyApp: App {
    /*
     Enable the line, if Use AppDelegate System.

     Use SwiftUIApp in the App, then specify Info.plist, None AppDelegate and SeneDelegate.
     
     <key>UIApplicationSceneManifest</key>
     <dict>
         <key>UIApplicationSupportsMultipleScenes</key>
         <false/>
     </dict>

     */
//    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    @Environment(\.scenePhase) private var appStatus

    var body: some Scene {
        WindowGroup {
            Auth()
                .environmentObject(Model.shared)
        }
        //        Settings {
        //            SettingsView(model: model) // Passed as an observed object.
        //        }
        .onChange(of: appStatus) { status in
            if status == .background {
                Log("App Enter Background.")
            }
            if status == .active {
                Log("App Enter Forground.")
            }
            if status == .inactive {
                Log("App in Pause.")
            }
        }
    }
}
