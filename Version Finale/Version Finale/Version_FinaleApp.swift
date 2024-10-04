//
//  Version_FinaleApp.swift
//  Version Finale
//
//  Created by Tiago Alves on 04.07.2024.
//

import SwiftUI

@main
struct Version_FinaleApp: App {
    @StateObject var dataStore = DataStore()
    @StateObject var vocabularyList = VocabularyList(name: "Default List", words: [], isStudyWriting: false, isStudySwipeCards: true, isStudyButtonCard: false)
    @StateObject var lnManager: LocalNotificationManager
    @StateObject var Stats = ActivityStats(vocabularyList: VocabularyList(name: "Default List", words: [], isStudyWriting: false, isStudySwipeCards: true, isStudyButtonCard: false),
                                           vocabularyListId: UUID(),
                                           durationOfActivity: 0,
                                           studiedWordsCount: 0,
                                           numberOfWrongAnswers: 0,
                                           numberOfTrys: 0,
                                           numberOfFirstTrys: 0,
                                           numberOfStudies: 0,
                                           date: Date(),
                                           durationOfActivityPerCard: 0,
                                           percentageOfFirstTries: 0,
                                           percentageOfAnswerPerCard: 0
                                                                        
                                       )
    
    init() {
        let defaultStats = ActivityStats(vocabularyList: VocabularyList(name: "Default List", words: [], isStudyWriting: false, isStudySwipeCards: true, isStudyButtonCard: false),
            vocabularyListId: UUID(),
            durationOfActivity: 0,
            studiedWordsCount: 0,
            numberOfWrongAnswers: 0,
            numberOfTrys: 0,
            numberOfFirstTrys: 0,
            numberOfStudies: 0,
            date: Date(),
            durationOfActivityPerCard: 0,
            percentageOfFirstTries: 0,
            percentageOfAnswerPerCard: 0
                                         
        )
        let defaultVocabularyList = VocabularyList(name: "Default List", words: [], isStudyWriting: false, isStudySwipeCards: true, isStudyButtonCard: false)
        _vocabularyList = StateObject(wrappedValue: defaultVocabularyList)
        _lnManager = StateObject(wrappedValue: LocalNotificationManager())
        _Stats = StateObject(wrappedValue: defaultStats)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataStore)
                .environmentObject(lnManager)
        }
    }
}
// xcrun simctl status_bar "iPhone 15 Pro" override --time "03:27"
