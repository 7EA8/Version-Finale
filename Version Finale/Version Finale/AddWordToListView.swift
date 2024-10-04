//
//  AddWordToListView.swift
//  Version Finale
//
//  Created by Tiago Alves on 04.07.2024.
//
import SwiftUI
import PhotosUI

struct AddWordToListView: View {
    @ObservedObject var vocabularyList: VocabularyList
    @Binding var isShowingAddWordView: Bool
    @State private var newName: String = ""
    @State private var newTranslation: String = ""
    var addNewWord: (String, String, String?, String?) -> Void
    @State private var clickedTheButton: Bool = false
    @State private var attempts: Int = 0
    @Binding var isShowingAddWordsModal: Bool
    @State private var newWordsText = ""
    @EnvironmentObject var dataStore: DataStore
    @FocusState private var keyboardFOcused: Bool
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(spacing: 10) {
                    TextField("Ajouter le mot", text: $newName)
                        .padding()
                        
                        .cornerRadius(10)
                        .shadow(radius: 3)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.icon, lineWidth: 1)
                        )
                        .modifier(Shake(animatableData: CGFloat(attempts)))
                        .autocorrectionDisabled(true)
                        .autocapitalization(.none)
                        .focused($keyboardFOcused)
                        .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    keyboardFOcused = true
                                }
                            }
                    TextField("Ajouter la traduction", text: $newTranslation)
                        .padding()
                        
                        .cornerRadius(10)
                        .shadow(radius: 3)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.icon, lineWidth: 1)
                        )
                        .modifier(Shake(animatableData: CGFloat(attempts)))
                        .autocorrectionDisabled(true)
                        .autocapitalization(.none)
                
                    if (newName.isEmpty && clickedTheButton) || (newTranslation.isEmpty && clickedTheButton) {
                        Text("Il vous manque (au moins) un terme")
                            .foregroundColor(.red)
                            .font(.footnote)
                            .padding(.top, 5)
                    }
                    Button(action: {
                        isShowingAddWordsModal = true
                    }) {
                        Text("Ajouter des mots à partir d'un texte")
                            .padding()
                            .background(.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    Spacer()
                    Button(action: {
                        if !newName.isEmpty && !newTranslation.isEmpty {
                            addNewWord(newName, newTranslation)
                            isShowingAddWordView = false
                            clickedTheButton = false
                        } else {
                            clickedTheButton = true
                            withAnimation(.default) {
                                self.attempts += 1
                            }
                        }
                    }) {
                        Text("Ajouter")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.icon)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 3)
                    }
                    .padding(.horizontal)
                    
                }
                .padding()
                .background(Color(.systemGray6).ignoresSafeArea())
                .navigationTitle("Nouveau mot")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Annuler") {
                            isShowingAddWordView = false
                        }
                    }
                }
            }
            .sheet(isPresented: $isShowingAddWordsModal) {
                AddWordsModalView(isPresented: $isShowingAddWordsModal, newWordsText: $newWordsText, onAddWords: addWordsFromText, isShowingAddWordView: $isShowingAddWordView)
                    .environmentObject(dataStore)
            }
        }
    }
    func addWordsFromText(_ text: String) {
        let wordsArray = text.components(separatedBy: ";")
        
        var i = 0
        while i < wordsArray.count {
            let name = wordsArray[i].trimmingCharacters(in: .whitespacesAndNewlines)
            let translation = (i + 1 < wordsArray.count ? wordsArray[i + 1] : "").trimmingCharacters(in: .whitespacesAndNewlines)
            
            
            if !name.isEmpty && !translation.isEmpty {
                dataStore.addWordToList(vocabularyList: vocabularyList, name: name, translation: translation)
            }
            
            i += 2
        }
        
        dataStore.saveVocabularyLists()
    }
    
     func addNewWord(_ name: String, _ translation: String) {
        dataStore.addWordToList(vocabularyList: vocabularyList, name: name, translation: translation)
        dataStore.saveVocabularyLists()
    }
}
