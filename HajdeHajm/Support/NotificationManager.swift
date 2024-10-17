//
//  NotificationManager.swift
//  HajdeHajm
//
//  Created by Kujtim Saliu on 17.10.24.
//

import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification authorization granted")
                self.scheduleNotifications()
            } else if let error = error {
                print("Error requesting notification authorization: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        let firstContent = UNMutableNotificationContent()
        firstContent.title = "Time to order lunch!"
        firstContent.body = "Let's order to eat yayyyy"
        firstContent.sound = .default
        
        let secondContent = UNMutableNotificationContent()
        secondContent.title = "Last call for lunch orders!"
        secondContent.body = "Let's order to eat yayyyy"
        secondContent.sound = .default
        
        for weekday in 2...6 {  // Monday = 2, Friday = 6
            let firstTrigger = self.createTrigger(weekday: weekday, hour: 11, minute: 10)
            let secondTrigger = self.createTrigger(weekday: weekday, hour: 11, minute: 20)
            
            let firstRequest = UNNotificationRequest(identifier: "lunchReminder1-\(weekday)", content: firstContent, trigger: firstTrigger)
            let secondRequest = UNNotificationRequest(identifier: "lunchReminder2-\(weekday)", content: secondContent, trigger: secondTrigger)
            
            center.add(firstRequest)
            center.add(secondRequest)
        }
    }
    
    private func createTrigger(weekday: Int, hour: Int, minute: Int) -> UNCalendarNotificationTrigger {
        var dateComponents = DateComponents()
        dateComponents.weekday = weekday
        dateComponents.hour = hour
        dateComponents.minute = minute
        return UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
    }
}

