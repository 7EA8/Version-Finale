//
//  ChangeWordView.swift
//  Version Finale
//
//  Created by Tiago Alves on 06.07.2024.
//

import SwiftUI

struct EditWordView: View {
    @State var word: VocabularyWord
    @Binding var isShowingEditWordView: Bool
    var saveChanges: (VocabularyWord) -> Void
    @Environment(\.dismiss) var dismiss
    @State private var attempts: Int = 0
    @State private var CLickedTheButton: Bool = false
    @FocusState private var keyboardFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Modifier le mot", text: $word.name)
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
                    .focused($keyboardFocused)
                    .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                keyboardFocused = true
                            }
                        }
                TextField("Modifier la traduction", text: $word.translation)
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
                if CLickedTheButton{
                    Text("(Au moins) un des termes est vide")
                        .foregroundStyle(.red)
                }
                Button(action: {
                    if !word.name.isEmpty && !word.translation.isEmpty{
                        CLickedTheButton = false
                        saveChanges(word)
                        dismiss()
                    }else{
                        withAnimation(.default) {
                            self.attempts += 1
                            CLickedTheButton = true
                        }
                    }
                }) {
                    
                    Text("Sauvegarder")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.icon)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                Spacer()
            }
            .padding()
            .navigationTitle("Modifier le mot")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct EditWordView_Previews: PreviewProvider {
    static var previews: some View {
        EditWordView(
            word: VocabularyWord(name: "Bonjour", translation: "Hello"),
            isShowingEditWordView: .constant(true),
            saveChanges: { _ in }
        )
    }
}

