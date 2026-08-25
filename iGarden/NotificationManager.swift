//
//  NotificationManager.swift
//  iGarden
//

import Foundation
import UserNotifications

enum NotificationSettings {
    static let enabledKey = "wateringRemindersEnabled"
    static let minutesKey = "wateringReminderMinutes"

    static var enabled: Bool {
        UserDefaults.standard.object(forKey: enabledKey) as? Bool ?? true
    }

    /// Tidspunkt på dagen for varsler, som minutter etter midnatt. Standard 09:00.
    static var minutesSinceMidnight: Int {
        UserDefaults.standard.object(forKey: minutesKey) as? Int ?? 9 * 60
    }
}

/// Planlegger lokale vanningsvarsler. Tillatelse bes om ved første
/// planlegging, ikke ved appstart. Plantens Firestore-id er varselidentifikator.
enum NotificationManager {
    /// Planlegger (eller fjerner og planlegger på nytt) varselet for én plante.
    static func reschedule(for plant: Plant) {
        guard let id = plant.id else { return }
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [id])

        guard NotificationSettings.enabled, let next = plant.nextWateringDate else { return }

        var components = Calendar.current.dateComponents([.year, .month, .day], from: next)
        components.hour = NotificationSettings.minutesSinceMidnight / 60
        components.minute = NotificationSettings.minutesSinceMidnight % 60
        guard let fireDate = Calendar.current.date(from: components), fireDate > .now else {
            // Forfalte planter vises allerede som "Trenger vann" i appen.
            return
        }

        let plantName = plant.name
        Task {
            guard await requestAuthorizationIfNeeded() else { return }
            let content = UNMutableNotificationContent()
            content.title = String(localized: "På tide å vanne")
            content.body = String(localized: "\(plantName) trenger vann 🌱")
            content.sound = .default
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            try? await center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
        }
    }

    static func cancel(for plant: Plant) {
        guard let id = plant.id else { return }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }

    /// Brukes når innstillingene endres: fjerner alt og planlegger på nytt.
    static func rescheduleAll(_ plants: [Plant]) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        guard NotificationSettings.enabled else { return }
        for plant in plants {
            reschedule(for: plant)
        }
    }

    private static func requestAuthorizationIfNeeded() async -> Bool {
        let center = UNUserNotificationCenter.current()
        switch await center.notificationSettings().authorizationStatus {
        case .notDetermined:
            return (try? await center.requestAuthorization(options: [.alert, .badge, .sound])) ?? false
        case .denied:
            return false
        default:
            return true
        }
    }
}
