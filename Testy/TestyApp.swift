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
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//        completionHandler()
//    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        Log()
//        if notification.request.content.categoryIdentifier == "DetectedExecutionDone" {
//            notification.request.content.userInfo
            completionHandler([.banner, .list, .badge, .sound])
            return
//        } else {
//        }
//        completionHandler(UNNotificationPresentationOptions(rawValue: 0))
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
//#tmp                scheduleAsBGApp()
                Model.shared.semaphore.signal()     //semaphore +1
            }
            if status == .active {
                Log("App Enter Foreground.")
                //carry out as App come into Foreground.
                /*
                 Wait for update Model.shared.screens to current.
                 */
                Log(Model.shared.semaphore.debugDescription)
//                Model.shared.semaphore.wait()
                let waitResult = Model.shared.semaphore.wait(timeout: .now() + 10)  //Seconds   semaphore > 1 ? throw and -1 : wait
                Log(waitResult)
                Log(Model.shared.semaphore.debugDescription)
                Task {
                    do {
//                        try await Task.sleep(nanoseconds: 2 * 1024 * 1024 * 1024)
                        Log(Model.shared.screens.last)
                        if let screenLast = Model.shared.screens.last {
                            Log("be in \(screenLast) View")
                            if screenLast == .menu {
                                Log()
                                Task {
                                    await Notification.notifyToViews("Just Wait Have Join blocks Network.", name: Notification.Name.detectExecuteDoneNotification)
                                    await detectExecuteDone()
                                }
                            }
                        } else {
                            Log("be in Auth View")
//                            Task {
//                                await Notification.notifyToViews("Please Tap Join blocks Network Button.", name: Notification.Name.pleaseJoinNetworkNotification)
//                            }
                        }
                    } catch {
                        Log(error)
                    }
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
    
    func scheduleAsBGApp() {
        let request = BGAppRefreshTaskRequest(identifier: detectDoneTaskId)
        request.earliestBeginDate = Date.now
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            Log("Could not schedule app refresh: \(error)")
        }
    }
    
    let detectCycleTimeAsNanoSeconds: UInt64 = 5 * 1024 * 1024 * 1024
    let thresholdRatio: Float = 1.0
    @State var detectedTimesCounter: UInt8 = 0
    func detectExecuteDone() async {
        /*
         Take cpu ratio for detect done making finger table.
         */
        do {
            let cpuRatio = cpuUsageAsPercent()
            Log(cpuRatio)
            if cpuRatio < thresholdRatio {
                detectedTimesCounter += 1
                Log(detectedTimesCounter)
                if detectedTimesCounter >= 3 {
                    Log()
                    await Notification.notifyToViews("Have Joined blocks Network.", name: Notification.Name.detectExecuteDoneNotification)
                    return
                }
            } else {
                Log()
            }
            /*
             execute recursively.
             //#now
             */
            try await Task.sleep(nanoseconds: detectCycleTimeAsNanoSeconds)
            await detectExecuteDone()
        } catch {
            Log(error)
        }
    }
    
//    public static func notifyToUser(_ description: String, after: TimeInterval = 0.5, repeating: Bool = false) async {
//        Log()
//        do {
//            let notifiedContent = UNMutableNotificationContent()
//            notifiedContent.categoryIdentifier = NSNotification.Name.detectExecuteDoneNotification.rawValue
//            notifiedContent.title = description
//            notifiedContent.body = ""
//            notifiedContent.sound = .default
//            let notifiedTrigger = UNTimeIntervalNotificationTrigger(timeInterval: after, repeats: repeating)
//            let notifiedRequest = UNNotificationRequest(identifier: NSNotification.Name.detectExecuteDoneNotification.rawValue, content: notifiedContent, trigger: notifiedTrigger)
//            try await UNUserNotificationCenter.current().add(notifiedRequest)
//            Log()
//        } catch {
//            Log(error)
//        }
//    }
//    
//    func notifyToViews(_ description: String, after: TimeInterval = 0.5, repeating: Bool = false) async {
//        Log()
//        Task { @MainActor in
//            Log()
//            let notifiedContent = UNMutableNotificationContent()
//            notifiedContent.title = description
//            notifiedContent.subtitle = ""
//            notifiedContent.sound = .default
//            NotificationCenter.default.post(name: NSNotification.Name.detectExecuteDoneNotification, object: notifiedContent, userInfo: ["description": description])
//        }
//    }
}
