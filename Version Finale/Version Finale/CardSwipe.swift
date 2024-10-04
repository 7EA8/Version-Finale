//
//  CardSwipeView.swift
//  Version Finale
//
//  Created by Tiago Alves on 04.07.2024.
//
import SwiftUI

struct CardSwipe: View {
    var vocab: String
    var vocab2: String
    @Binding var offset: CGSize
    @Binding var color: Color
    var onRemove: () -> Void
    var namespace: Namespace.ID
    @Binding var isShowingAnswer: Bool
    @State private var debutEtudeCarte: Date? = nil
    @State private var finEtudeCarte: Date? = nil
    @State private var durationDeLaCarte: TimeInterval = 0

    var body: some View {
        ZStack {
            // Background for the entire view
            Color(.systemGray6)
                .edgesIgnoringSafeArea(.all)
            
            ZStack {
                // Card background
                RoundedRectangle(cornerRadius: 25)
                    .fill(color)
                    .frame(width: 320, height: 420)
                    .shadow(radius: 4)
                    .matchedGeometryEffect(id: "card", in: namespace)
                
                VStack {
                    Text(vocab)
                        .font(.largeTitle)
                        .foregroundColor(Color(.systemGray6))
                        .bold()
                        .padding(.bottom, 20)
                    
                    if isShowingAnswer {
                        Text(vocab2)
                            .font(.title)
                            .foregroundColor(.gray)
                    }
                }
                .multilineTextAlignment(.center)
                .padding()
            }
            .onTapGesture {
                withAnimation {
                    isShowingAnswer.toggle()
                }
            }
        }
        .onAppear {
            // Commencer à mesurer le temps dès que la carte apparaît
            debutEtudeCarte = Date()
            print("Début de l'étude pour la carte: \(vocab) à \(String(describing: debutEtudeCarte))")
        }
        .onChange(of: vocab) { newVocab,_ in
            // Calculer la durée de la carte précédente avant de passer à la nouvelle
            if let debutEtudeCarte = debutEtudeCarte {
                finEtudeCarte = Date()
                durationDeLaCarte = finEtudeCarte?.timeIntervalSince(debutEtudeCarte) ?? 0
                print("Fin de l'étude pour la carte: \(vocab) à \(String(describing: finEtudeCarte))")
                print("Temps passé sur cette carte: \(durationDeLaCarte) secondes")
            }
            
            // Réinitialiser pour la nouvelle carte
            debutEtudeCarte = Date()
            isShowingAnswer = false // Réinitialiser la réponse pour la nouvelle carte
            print("Nouvelle carte affichée: \(newVocab)")
        }
        .offset(x: offset.width, y: offset.height * 0.4)
        .rotationEffect(.degrees(Double(offset.width / 20)))
    }
}
