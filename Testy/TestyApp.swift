//
//  TestyApp.swift
//  Testy
//
//  Created by よういち on 2023/11/27.
//  Copyright © 2023 WEB BANANA UNITE Tokyo-Yokohama LPC. All rights reserved.
//

import Foundation
import SwiftUI
import overlayNetworkObjc
import BackgroundTasks

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        Log()
            completionHandler([.banner, .list, .badge, .sound])
            return
    }
}

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
    private var notificationDelegate = NotificationDelegate()
    init() {
        UNUserNotificationCenter.current().delegate = self.notificationDelegate
    }

    @Environment(\.scenePhase) private var appStatus
    let detectDoneTaskId = "org.webbanana.testy.detectDone"
    
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
                //carry out as App go into Background.
//              scheduleAsBGApp()
                Model.shared.semaphore.signal()     //semaphore +1
            }
            if status == .active {
                Log("App Enter Foreground.")
                //carry out as App come into Foreground.
                Task {
                    await detectExecuteDone()
                }
            }
            if status == .inactive {
                Log("App in Pause.")
            }
        }
//        .backgroundTask(.appRefresh(detectDoneTaskId)) {
//            /*
//             Execute for 2 min (max).
//             */
//            await detectExecuteDone()
//        }
//        .backgroundTask(.urlSession("org.webbanana.testy.yyy")) {
//
//        }
    }
    
//    func scheduleAsBGApp() {
//        let request = BGAppRefreshTaskRequest(identifier: detectDoneTaskId)
//        request.earliestBeginDate = Date.now
//        do {
//            try BGTaskScheduler.shared.submit(request)
//        } catch {
//            Log("Could not schedule app refresh: \(error)")
//        }
//    }
    
    let detectCycleTimeAsNanoSeconds: UInt64 = 3 * 1024 * 1024 * 1024
    func detectExecuteDone() async {
        /*
         Detect is there File Overlay Network Finger Table.
         */
        do {
            if let ownNode = Model.shared.ownNode, ownNode.availableFingerTable() {
                Log()
                await Notification.notifyToViews("Have Joined blocks Network.", name: Notification.Name.detectExecuteDoneNotification)
                return
            }
            /*
             execute recursively.
             */
            try await Task.sleep(nanoseconds: detectCycleTimeAsNanoSeconds)
            await detectExecuteDone()
        } catch {
            Log(error)
        }
    }
}
