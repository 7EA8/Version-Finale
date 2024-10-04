//
//  EndofRoundView.swift
//  Version Finale
//
//  Created by Tiago Alves on 12.08.2024.
//

import SwiftUI

struct endOfRoundView: View {
    @Binding var endOfRound: Bool
    @Binding var studiedWords: [VocabularyWord]
    @Binding  var numberForTheEndOfTheRound: Int
    @Binding var wordsToStudy: [VocabularyWord]
    @Binding var StartOfTheRevision: Date?
    
    
    var body: some View {
        VStack{
            List {
                Section{
                    ForEach(studiedWords) { word in
                        VStack(alignment: .leading) {
                            HStack {
                                Text(word.name)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                            }
                            HStack {
                                Text(word.translation)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 4)
                        .contentShape(Rectangle())
                    }
                }  header: {
                    Text("Mots déja appris")
                }
                
                Section{
                    ForEach(wordsToStudy) { word in
                        VStack(alignment: .leading) {
                            HStack {
                                Text(word.name)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                            }
                            HStack {
                                Text(word.translation)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 4)
                        .contentShape(Rectangle())
                    }
                }  header: {
                    Text("Mots à apprendre")
                }
            }.onAppear(){
               
                if endOfRound{
                    numberForTheEndOfTheRound = wordsToStudy.count
                }
                
            }
            .navigationTitle("Fin du tour")
            .navigationBarTitleDisplayMode(.inline)
                Spacer()
                Button(action:{
                    endOfRound = false
                }
                )
                {
                    
                    Text("Continuer")
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(.icon)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 3)
                    
                }.padding()
            }.padding()
        }
    }

