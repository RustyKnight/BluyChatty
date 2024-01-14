//
//  NotificationsPermissionsViewController.swift
//  BLEChattyNative
//
//  Created by Shane Whitehead on 21/8/18.
//  Copyright © 2018 Beam Communications. All rights reserved.
//

import UIKit
import UserNotifications
import Hydra
import Cadmus
import Hermes

extension UNAuthorizationStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .notDetermined: return "notDetermined"
        case .denied: return "denied"
        case .authorized: return "authorized"
        case .provisional: return "provisional"
        case .ephemeral: return "ephemeral"
        }
    }
}

class NotificationsPermissionsViewController: UIViewController {
    
    static let PermissionsChanged: Notification.Name = Notification.Name(rawValue: "NotificationsPermissions.changed")
    
    @IBOutlet weak var logoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logoImageView.image = BluyChat.imageOfNotifications(imageSize: CGSize(width: 86, height: 86))
    }
    
    @IBAction func requestAuthorisation(_ sender: Any) {
        UNUserNotificationCenter
            .current()
            .settings()
            .done(on: .main) { (settings) -> Void in
                log(debug: "authorizationStatus = \(settings.authorizationStatus)")
                guard settings.authorizationStatus != .notDetermined else {
                    UNUserNotificationCenter
                        .current()
                        .authorise(
                            options: [.alert, .badge, .sound, .carPlay, .criticalAlert, .provisional]
                        )
                        .done(on: .main) { () in
                            NotificationCenter.default.post(name: NotificationsPermissionsViewController.PermissionsChanged, object: nil)
                        }
                        .cauterize()
                    return
                }
                NotificationCenter.default.post(name: NotificationsPermissionsViewController.PermissionsChanged, object: nil)
            }
            .cauterize()
        
    }
    
}
