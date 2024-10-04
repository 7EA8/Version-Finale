//
//  AddWordsModalView.swift
//  Version Finale
//
//  Created by Tiago Alves on 18.07.2024.
//

import SwiftUI

struct AddWordsModalView: View {
    @Binding var isPresented: Bool
    @Binding var newWordsText: String
    var onAddWords: (String) -> Void
    @Binding var isShowingAddWordView: Bool
    @State private var errorMessage: String? // Variable d'état pour le message d'erreur
    @State private var attempts = 0
    @FocusState private var keyboardFOcused: Bool
    var body: some View {
        NavigationView {
            VStack {
                TextField("""
                          Entrez les mots et leurs traductions, séparés par un point-virgule ou ";".\nExemple : mot1; traduction1; mot2; traduction2
                          """, text: $newWordsText, axis: .vertical)
                .padding()
                .lineLimit(4...)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.icon, lineWidth: 1)
                )                .padding()
                .autocapitalization(.none)
                .modifier(Shake(animatableData: CGFloat(attempts)))
                .focused($keyboardFOcused)
                .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            keyboardFOcused = true
                        }
                    }
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                Spacer()
                
                HStack {
                    
                    Button(action: {
                        if validateInput(newWordsText) {
                            onAddWords(newWordsText)
                            isPresented = false
                            isShowingAddWordView = false
                        }else if !validateInput(newWordsText){
                            withAnimation(.default) {
                                self.attempts += 1
                            }
                        }
                    }) {
                        Text("Ajouter")
                            .bold()
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.icon)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 3)
                    }
                    .padding()
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        isPresented = false
                    }
                }
            }
            .padding()
            .navigationBarTitle("Ajouter des mots", displayMode: .inline)
        }
    }
    
    // Fonction pour valider l'entrée de l'utilisateur
    private func validateInput(_ text: String) -> Bool {
        let wordsArray = text.components(separatedBy: ";")
        if wordsArray.count % 2 != 0 {
            errorMessage = "Veuillez entrer un nombre pair de mots et de traductions."
            return false
        }
        for i in stride(from: 0, to: wordsArray.count, by: 2) {
            let name = wordsArray[i].trimmingCharacters(in: .whitespacesAndNewlines)
            let translation = (i + 1 < wordsArray.count ? wordsArray[i + 1] : "").trimmingCharacters(in: .whitespacesAndNewlines)
            if name.isEmpty || translation.isEmpty {
                errorMessage = "Veuillez vous assurer que tous les mots et traductions sont remplis."
                return false
            }
        }
        errorMessage = nil // Réinitialiser le message d'erreur si tout est valide
        return true
    }
}
