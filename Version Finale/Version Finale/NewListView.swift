//
//  CreateListe.swift
//  Version Finale
//
//  Created by Tiago Alves on 04.07.2024.
//
import SwiftUI

struct NewListView: View {
    @Binding var isShowingNewListView: Bool
    @State private var listName: String = ""
    var addNewList: (String) -> Void
    @State private var clickedTheButton: Bool = false
    @State private var attempts: Int = 0
    @FocusState private var keyboardFOcused: Bool
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Nom de la nouvelle liste", text: $listName)
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
                if listName.isEmpty && clickedTheButton {
                    Text("Votre liste n'a pas de nom")
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.top, 5)
                }
                
                Button(action: {
                    if !listName.isEmpty {
                        addNewList(listName)
                        isShowingNewListView = false
                    } else {
                        clickedTheButton = true
                        withAnimation(.default) {
                            self.attempts += 1
                        }
                    }
                }) {
                    Text("Créer")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.icon)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 3)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .background(Color(.systemGray6).ignoresSafeArea())
            .navigationTitle("Nouvelle Liste")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        isShowingNewListView = false
                    }
                }
            }
        }
    }
}



