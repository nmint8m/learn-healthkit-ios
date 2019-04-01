//
//  NotificationVC.swift
//  DemoHealthKit
//
//  Created by Tam Nguyen M. on 4/1/19.
//  Copyright © 2019 Tam Nguyen M. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationVC: UIViewController {

    @IBOutlet weak var hourTextField: UITextField!
    @IBOutlet weak var minuteTextField: UITextField!
    @IBOutlet weak var secondTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (granted, error) in

        }
        HealthKitManager.manager.authen { (granted, error) in
            
        }
        // Do any additional setup after loading the view.
    }

    @IBAction func pushButtonTouchUpInside(_ sender: Any) {
        guard let h = hourTextField.text,
            let m = minuteTextField.text,
            let s = secondTextField.text,
            let hour = Int(h),
            let minute = Int(m),
            let second = Int(s) else { return }
        scheduleNotificationForDate(hour, minute, second)
    }

    private func scheduleNotificationForDate(_ hour: Int, _ minute: Int, _ second: Int) {
        let noti = UNMutableNotificationContent()
        noti.title = "Notification title"
        noti.body = "Notification body"
        noti.categoryIdentifier = "ID_NOTI"
        noti.sound = UNNotificationSound.default

        var date = DateComponents()
        date.hour = hour
        date.minute = minute
        date.second = second

        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)

        let request = UNNotificationRequest(identifier: "ID_NOTI", content: noti, trigger: trigger)

        UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
            print(error ?? "NO ERROR")
        })
    }
}

extension NotificationVC: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(UNNotificationPresentationOptions.sound)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.notification.request.content.categoryIdentifier == "NOTII" {
            // Handle the actions for the expired timer.
            if response.actionIdentifier == "SNOOZE_ACTION" {
                // Invalidate the old timer and create a new one. . .
            }
            else if response.actionIdentifier == "STOP_ACTION" {
                // Invalidate the timer. . .
            }
        }
    }
}
