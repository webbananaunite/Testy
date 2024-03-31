//
//  Notification.swift
//  Testy
//
//  Created by よういち on 2024/01/11.
//  Copyright © 2024 WEB BANANA UNITE Tokyo-Yokohama LPC. All rights reserved.
//

import Foundation
import UserNotifications

extension Notification.Name {
    static let pleaseJoinNetworkNotification = Notification.Name("org.webbanana.Testy.pleaseJoinNetworkNotification")
    static let detectExecuteDoneNotification = Notification.Name("org.webbanana.Testy.detectExecuteDoneNotification")
}

extension Notification {
    public static func notifyToUser(_ description: String, after: TimeInterval = 0.5, repeating: Bool = false) async {
        Log()
        Task { @MainActor in
            do {
                let notifiedContent = UNMutableNotificationContent()
                notifiedContent.categoryIdentifier = NSNotification.Name.detectExecuteDoneNotification.rawValue
                notifiedContent.title = description
                notifiedContent.body = ""
                notifiedContent.sound = .default
                let notifiedTrigger = UNTimeIntervalNotificationTrigger(timeInterval: after, repeats: repeating)
                let notifiedRequest = UNNotificationRequest(identifier: NSNotification.Name.detectExecuteDoneNotification.rawValue, content: notifiedContent, trigger: notifiedTrigger)
                try await UNUserNotificationCenter.current().add(notifiedRequest)
                Log()
            } catch {
                Log(error)
            }
        }
    }
    
    public static func notifyToViews(_ description: String, name: Notification.Name, after: TimeInterval = 0.5, repeating: Bool = false) async {
        Log(name.rawValue)
        Task { @MainActor in
            Log()
            let notifiedContent = UNMutableNotificationContent()
            notifiedContent.title = description
            notifiedContent.subtitle = ""
            notifiedContent.sound = .default
//            NotificationCenter.default.post(name: NSNotification.Name.detectExecuteDoneNotification, object: notifiedContent, userInfo: ["description": description])
            NotificationCenter.default.post(name: name, object: notifiedContent, userInfo: ["description": description])
        }
    }
}
