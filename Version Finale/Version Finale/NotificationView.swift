//
//  NotificationView.swift
//  Version Finale
//
//  Created by Tiago Alves on 30.07.2024.
//
import SwiftUI

struct NotificationView: View {
    @EnvironmentObject var lnManager: LocalNotificationManager
    @Environment(\.scenePhase) var scenePhase
    @ObservedObject var vocabularyList: VocabularyList
    @State private var boolAlerte = false
    @State private var boolAlerteListe = false
    
    var body: some View {
        NavigationView {
            VStack {
                if lnManager.isGranted {
                    if !lnManager.pendingRequest.isEmpty {
                        Button("Tout supprimer") {
                            boolAlerte = true
                        }
                        .cornerRadius(10)
                        .alert(isPresented: $boolAlerte){
                            
                            Alert(
                                title: Text("Êtes-vous sûr de vouloir supprimer toutes vos notifications?"),
                                message: Text("Cette action est irréversible."),
                                primaryButton: .cancel(Text("Non")),
                                secondaryButton: .destructive(
                                    Text("Oui"),
                                    action: {lnManager.clearRequests()}
                                )
                            )
                        }
                        .foregroundStyle(.icon)
                        Text("Faites glisser les notifications pour pouvoir supprimer celles dont vous ne voulez pas")
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                        List {
                            ForEach(lnManager.pendingRequest, id: \.identifier) { request in
                                VStack(alignment: .leading) {
                                    Text("\(request.content.title)")
                                    Text("Notification prévue pour: \(formattedTriggerDate(from: request))")
                                        .environment(\.locale, Locale(identifier: "fr"))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .swipeActions {
                                    Button("Supprimer", role: .destructive) {
                                        lnManager.removeRequest(withIdentifier: request.identifier)
                                    }
                                }
                            }
                        }
                        // Ajouter un bouton pour supprimer les notifications d'une catégorie spécifique
                        Button("Supprimer les notifications de la liste \(vocabularyList.name)") {
                            boolAlerteListe = true
                        }
                        .cornerRadius(10)
                        .alert(isPresented: $boolAlerteListe){
                            
                            Alert(
                                title: Text("Êtes-vous sûr de vouloir supprimer les notification de \(vocabularyList.name)?"),
                                primaryButton: .cancel(Text("Non")),
                                secondaryButton: .destructive(
                                    Text("Oui"),
                                    action: {lnManager.removeAllRequests(forCategory: "lastDayCategory_\(vocabularyList.name)")
                                        lnManager.removeAllRequests(forCategory: "dailyCategory_\(vocabularyList.name)")}
                                )
                            )
                        }
                        .foregroundStyle(.icon)
                        
                        
                    } else {
                        Text("""
Choisissez d'abord une date et cliquez sur le bouton "Choisir" du calendrier pour pouvoir accéder à vos notifications
""")
                    }
                } else {
                    Button("Activer les notifications") {
                        lnManager.openSettings()
                    }.buttonStyle(.bordered)
                }
            }
            .navigationTitle("Notifications")
            
            .onChange(of: scenePhase) { newValue,_ in
                if newValue == .active {
                    Task {
                        await lnManager.getCurrentSettings()
                        await lnManager.getPendingRequests()
                    }
                }
            }
        }
    }
    
    private func formattedTriggerDate(from request: UNNotificationRequest) -> String {
        guard let trigger = request.trigger as? UNCalendarNotificationTrigger else {
            return "Unknown"
        }
        let dateComponents = trigger.dateComponents
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents) ?? Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
}
