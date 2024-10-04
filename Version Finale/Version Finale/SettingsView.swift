//
//  SettingsView.swift
//  Version Finale
//
//  Created by Tiago Alves on 30.07.2024.
//

import SwiftUI

struct SettingsView: View {
    
    @Binding var isStudyChoicePresented: Bool
    var vocabularyList: VocabularyList
    @Binding var isStudySwipeCards: Bool
    @Binding var isStudyWriting: Bool
    @Binding var isStudyButtonCard: Bool
    @Binding var soon: Int
    @Binding var late: Int
    
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Choisissez votre mode d'étude")) {
                    Toggle("Glisser les cartes", isOn: Binding(
                        get: { isStudySwipeCards },
                        set: { newValue in
                            updateStudyMode(swipeCards: newValue, writing: false, buttonCard: false)
                        }
                    ))
                    
                    Toggle("Écrire", isOn: Binding(
                        get: { isStudyWriting },
                        set: { newValue in
                            updateStudyMode(swipeCards: false, writing: newValue, buttonCard: false)
                        }
                    ))
                    
                    Toggle("Utiliser les cartes", isOn: Binding(
                        get: { isStudyButtonCard },
                        set: { newValue in
                            updateStudyMode(swipeCards: false, writing: false, buttonCard: newValue)
                        }
                    ))
                    
                    if !isStudySwipeCards && !isStudyWriting && !isStudyButtonCard {
                        Text("Il faut au moins choisir un mode d'étude")
                            .foregroundStyle(.red)
                    }
                    
                    
                }
                if isStudyButtonCard && vocabularyList.words.count > 0{
                Section(header: Text("Sélectionner à quelle place les cartes doivent être mises") .multilineTextAlignment(.center)){
                
                        Picker("Inconnu", selection: $soon) {
                            ForEach(1...vocabularyList.words.count, id: \.self) { number in
                                Text("\(number)")
                            }
                        }
                        Picker("Moyen", selection: $late) {
                            ForEach(1...vocabularyList.words.count, id: \.self) { number in
                                Text("\(number)")
                            }
                        }
                        if late < soon {
                            Text("Veuillez choisir un nombre plus élévé pour les cartes inconnues que les cartes moyennement connues")
                                .foregroundStyle(.red)
                                .multilineTextAlignment(.center)
                            
                            
                        }
                    }
                }
                if isStudySwipeCards{
                    Section(header: Text("Sélectionner à quelle place les cartes non-connues doivent être mises") .multilineTextAlignment(.center)){
                    
                            Picker("Inconnu", selection: $soon) {
                                ForEach(1...vocabularyList.words.count, id: \.self) { number in
                                    Text("\(number)")
                                }
                            }
                        }
                }
                if isStudyWriting{
                    Section(header: Text("Sélectionner à quelle place les mots non-connus doivent être mis") .multilineTextAlignment(.center)){
                    
                            Picker("Inconnu", selection: $soon) {
                                ForEach(1...vocabularyList.words.count, id: \.self) { number in
                                    Text("\(number)")
                                }
                            }
                        }
                }

            
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Choisir", role: .destructive) {
                        if isStudySwipeCards || isStudyWriting || isStudyButtonCard {
                            isStudyChoicePresented = false
                        }
                        print("Mode d'étude sélectionné")
                    }
                }
            }
            .navigationTitle("Choix du mode d'étude")
            
        }
    }
    // Méthode pour mettre à jour les modes d'étude
    private func updateStudyMode(swipeCards: Bool, writing: Bool, buttonCard: Bool) {
        isStudySwipeCards = swipeCards
        isStudyWriting = writing
        isStudyButtonCard = buttonCard
    }
}
