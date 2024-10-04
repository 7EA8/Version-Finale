//
//  StatsView.swift
//  Version Finale
//
//  Created by Tiago Alves on 12.08.2024.
//

import SwiftUI

struct StatsView: View {
    @EnvironmentObject var dataStore: DataStore // Utilisation de DataStore
    var vocabularyList: VocabularyList
    var activityStats: ActivityStats
  
    @State private var firstStudy = false

    
    private var formatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute, .second, .nanosecond]
        formatter.unitsStyle = .abbreviated
        formatter.calendar?.locale = Locale(identifier: "fr_FR")
        
        return formatter
    }
    
    private var selectedStats: [ActivityStats] {
        dataStore.activityStats.filter { $0.vocabularyListId == vocabularyList.id }
    }
    private var lastStats: ActivityStats?{
        dataStore.activityStats
            .filter { $0.vocabularyListId == vocabularyList.id }
            .last
    }
    
    
    var body: some View {
        
        VStack{
            if let stat = lastStats {
                let TrysperCard = stat.numberOfTrys / stat.studiedWordsCount
                let formattedDuration = formatter.string(from: stat.durationOfActivity)
                Section{
                    // Affichage des dernières stats
                    VStack(alignment: .leading) {
                        Text("Statistiques")
                            .font(.headline)
                            .padding(.bottom, 10)
                        
                        Text("Date: \(stat.date, format: .dateTime.hour().second().minute().day().month().year())")
                        Text("Temps d'étude: \(formattedDuration ?? "Pas calculéé")")
                        Text("Temps d'étude moyen par carte: \(stat.durationOfActivityPerCard)")
                        Text("Nombre d'études: \(stat.numberOfStudies)")
                        Text("Nombre de mots étudiés: \(stat.studiedWordsCount)")
                        Text("Nombre d'erreurs: \(stat.numberOfWrongAnswers)")
                        Text("Nombre d'essais: \(stat.numberOfTrys)")
                        Text("Nombre de réussites au premier essai: \(stat.numberOfFirstTrys)")
                        Text("Pourcentage de réussites au premier essai par carte: \(stat.percentageOfFirstTries)%")
                        Text("Pourcentage d'erreurs par essai: \(stat.percentageOfAnswerPerCard)%")
                        Text("Nombre d'essais moyens par carte: \(TrysperCard)")
                        
                    }
                    .environment(\.locale, Locale(identifier: "fr"))
                    .padding()
                }
                //if stat.numberOfStudies > 1 {
                  //  NavigationLink(destination: StatsGraphView(activityStats: [activityStats], vocabularyList: vocabularyList)) { Text("Graphiques de votre évolution")
                    //        .frame(maxWidth: .infinity)
                        //.padding()
                      //      .background(.icon)
                          //  .foregroundColor(.white)
                        //.cornerRadius(10)}
                    
                    
                //}
            }
            }
            .onAppear {
                // Charge les stats au moment où la vue apparaît
                dataStore.loadActivityStats()
            }
        }
    }
