//
//  LocalNotificationManager.swift
//  Version Finale
//
//  Created by Tiago Alves on 30.07.2024.
//

import Foundation
import NotificationCenter
import SwiftUI



@MainActor
class LocalNotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    let notificationCenter = UNUserNotificationCenter.current()
    @Published var isGranted = false
    @Published var pendingRequest: [UNNotificationRequest] = []
    var notificationCategories: [String: [String]] = [:]
    
    override init() {
        super.init()
        notificationCenter.delegate = self
        Task {
            await getCurrentSettings()
            await getPendingRequests()
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        await getPendingRequests()
        return [.sound, .banner]
    }
    
    func requestAuthorization() async throws {
        try await notificationCenter.requestAuthorization(options: [.sound, .badge, .alert])
        await getCurrentSettings()
    }
    
    func getCurrentSettings() async {
        let currentSettings = await notificationCenter.notificationSettings()
        isGranted = (currentSettings.authorizationStatus == .authorized)
    }
    
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                Task {
                    await UIApplication.shared.open(url)
                }
            }
        }
    }
    
    func schedule(localNotification: LocalNotification) async {
        let content = UNMutableNotificationContent()
        content.title = localNotification.title
        content.body = localNotification.bodyGenerator()
        content.sound = .default
        
        if localNotification.scheduleType == .time {
                    guard let timeInterval = localNotification.timeInterval else { return }
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: localNotification.repeats)
                    let request = UNNotificationRequest(identifier: localNotification.identifier, content: content, trigger: trigger)
                    try? await notificationCenter.add(request)
                    
                    // Ajouter l'identifiant à la catégorie
                    addNotificationIdentifier(localNotification.identifier, toCategory: localNotification.category)
                    
                } else if localNotification.scheduleType == .calendar {
                    guard let startDate = localNotification.startDate, let endDate = localNotification.endDate else { return }
                    
                    var currentDate = startDate
                    while currentDate < endDate {
                        var dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: currentDate)
                        dateComponents.hour = Calendar.current.component(.hour, from: endDate)
                        dateComponents.minute = Calendar.current.component(.minute, from: endDate)
                        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                        let request = UNNotificationRequest(identifier: "\(localNotification.identifier)_\(currentDate.timeIntervalSince1970)", content: content, trigger: trigger)
                        try? await notificationCenter.add(request)
                        
                        // Ajouter l'identifiant à la catégorie
                        addNotificationIdentifier(request.identifier, toCategory: localNotification.category)
                        
                        // Incrémenter la date d'un jour
                        currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
                    }
                }
                await getPendingRequests()
            }
    
    func lastDay(localNotification: LocalNotification) async {
        let content = UNMutableNotificationContent()
        content.title = localNotification.title
        content.body = localNotification.bodyGenerator()
        content.sound = .default
        
        guard let startDate = localNotification.startDate, let endDate = localNotification.endDate else { return }
        let dayDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: endDate)
        let triggerday = UNCalendarNotificationTrigger(dateMatching: dayDateComponents, repeats: false)
        let requestday = UNNotificationRequest(identifier: "\(localNotification.identifier)_\(startDate.timeIntervalSince1970)", content: content, trigger: triggerday)
        try? await notificationCenter.add(requestday)
        
        addNotificationIdentifier(requestday.identifier, toCategory: localNotification.category)
        
        await getPendingRequests()
    }
    
    func getPendingRequests() async {
        pendingRequest = await notificationCenter.pendingNotificationRequests()
    }

    func removeRequest(withIdentifier identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        if let index = pendingRequest.firstIndex(where: { $0.identifier == identifier }) {
            pendingRequest.remove(at: index)
        }
    }
    
    func clearRequests() {
        notificationCenter.removeAllPendingNotificationRequests()
        pendingRequest.removeAll()
    }
    
    func removeAllRequests(forCategory category: String) {
            guard let identifiers = notificationCategories[category] else { return }
            notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
            notificationCategories[category] = nil
            Task {
                await getPendingRequests()
            }
        }
    
    private func addNotificationIdentifier(_ identifier: String, toCategory category: String) {
            if notificationCategories[category] == nil {
                notificationCategories[category] = []
            }
            notificationCategories[category]?.append(identifier)
        }
}
