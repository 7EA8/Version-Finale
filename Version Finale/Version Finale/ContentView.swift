//
//  ContentView.swift
//  Version Finale
//
//  Created by Tiago Alves on 04.07.2024.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @EnvironmentObject var lnManager: LocalNotificationManager
    @EnvironmentObject var dataStore: DataStore
    @State private var isShowingAddListView = false
    @State private var isShowingSettings = false
    @State private var isShowingShareSheet = false
    @State private var newListName: String = ""
    @AppStorage("shouldShowOnBoarding") var shouldShowOnBoarding = true

    
    var body: some View {
        let fileURL: URL = getDocumentsDirectory()
        NavigationView {
            ZStack {
                Color(.systemGray6).ignoresSafeArea()
                VStack {
                    if dataStore.vocabularyLists.isEmpty {
                        VStack {
                            Image(systemName: "doc.text.fill")
                                .font(.system(size: 72))
                                .padding()
                                .foregroundStyle(.icon)
                            Text("Aucune liste de vocabulaire")
                            Button(action: {
                                isShowingAddListView = true
                            }) {
                                Text("Ajouter une nouvelle liste")
                                    .padding()
                                    .background(Color.icon)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                    } else {
                        List {
                            ForEach(dataStore.vocabularyLists) { list in
                                NavigationLink(destination: VocabularyListView(
                                    vocabularyList: list, activityStats: dataStore.activityStats
                                )) {
                                    Text(list.name)
                                }
                            }
                            .onDelete { indexSet in
                                // Récupérer la liste à supprimer à partir de l'index
                                indexSet.forEach { index in
                                    let listToDelete = dataStore.vocabularyLists[index]
                                    
                                    // Appeler la méthode deleteVocabularyList pour supprimer la liste et ses stats
                                    dataStore.deleteVocabularyList(listToDelete)
                                }
                            }
                        }
                    }
                }
                .task {
                    try? await lnManager.requestAuthorization()
                }
                .navigationTitle("Listes")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            isShowingAddListView = true
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                   // ToolbarItem(placement: .topBarLeading) {
                     //  Button(action: {
                         //   isShowingSettings = true
                       // }) {
                        //    Image(systemName: "gearshape")
                      //  }
                    //}
                }
                .sheet(isPresented: $isShowingAddListView) {
                    NewListView(isShowingNewListView: $isShowingAddListView, addNewList: { name in
                        dataStore.addVocabularyList(name: name)
                        isShowingAddListView = false  // Dismiss the sheet after adding the list
                    })
                }
               
            }
          //  .navigationBarItems(trailing: Button(action: {
            //    isShowingShareSheet = true  // Trigger share sheet
     //       }) {
       //         Text("Partager fichier JSON")
         //   })
        }
        .fullScreenCover(isPresented: $shouldShowOnBoarding, content: {
            UnboardingView(shouldShowOnBoarding: $shouldShowOnBoarding)
        })
        .sheet(isPresented: $isShowingShareSheet) {
            ShareView(activityItems: [fileURL])
        }
    }
    
     private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

struct ShareView: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
