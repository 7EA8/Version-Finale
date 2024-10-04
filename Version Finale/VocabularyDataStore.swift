//
//  VocabularyData.swift
//  Version Finale
//
//  Created by Tiago Alves on 08.07.2024.
//

import Foundation
import SwiftUI
import Combine
import UniformTypeIdentifiers

// Extension pour UserDefaults pour la sérialisation des objets
extension UserDefaults {
    func setEncodable<T: Encodable>(_ value: T, forKey key: String) {
        if let encoded = try? JSONEncoder().encode(value) {
            set(encoded, forKey: key)
        }
    }

    func decodable<T: Decodable>(forKey key: String) -> T? {
        if let data = data(forKey: key), let decoded = try? JSONDecoder().decode(T.self, from: data) {
            return decoded
        }
        return nil
    }
}

// Document JSON pour l'exportation/importation
struct JSONDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    
    var url: URL?
    
    init(url: URL?) {
        self.url = url
    }
    
    init(configuration: ReadConfiguration) throws {
        self.url = nil
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        guard let url = url else { throw CocoaError(.fileNoSuchFile) }
        let data = try Data(contentsOf: url)
        return FileWrapper(regularFileWithContents: data)
    }
}


class DataStore: ObservableObject {
    @Published var vocabularyLists: [VocabularyList] = []
    @Published var activityStats: [ActivityStats] = []
    
    private let localFileName = "vocabularyLists.json"
    private let statsFileName = "activityStats.json"
    private let iCloudStore = NSUbiquitousKeyValueStore.default
    
    init() {
        loadVocabularyLists()
        loadActivityStats()
        NotificationCenter.default.addObserver(self, selector: #selector(syncWithiCloud), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: iCloudStore)
        iCloudStore.synchronize()
    }
    func deleteVocabularyList(_ vocabularyList: VocabularyList) {
           // Supprimer la liste de vocabulaire
           if let listIndex = vocabularyLists.firstIndex(where: { $0.id == vocabularyList.id }) {
               vocabularyLists.remove(at: listIndex)
           }
           
           // Supprimer les statistiques associées
           activityStats.removeAll(where: { $0.vocabularyListId == vocabularyList.id })
           
           // Sauvegarder les changements
           saveVocabularyLists()
           saveActivityStats()
       }
    
    func addVocabularyList(name: String) {
        let newList = VocabularyList(name: name, words: [], isStudyWriting: false, isStudySwipeCards: true, isStudyButtonCard: false)
        vocabularyLists.insert(newList, at: 0)
        saveVocabularyLists()
    }
    
    func saveVocabularyLists() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(vocabularyLists) {
            // Save locally
            let fileURL = getDocumentsDirectory().appendingPathComponent(localFileName)
            try? encoded.write(to: fileURL)
            
            // Save to iCloud
            iCloudStore.set(encoded, forKey: localFileName)
            iCloudStore.synchronize()
        }
    }
    
    func loadVocabularyLists() {
        // Load from local storage
        let fileURL = getDocumentsDirectory().appendingPathComponent(localFileName)
        if let data = try? Data(contentsOf: fileURL) {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode([VocabularyList].self, from: data) {
                vocabularyLists = decoded
            }
        }
        
        // Load from iCloud
        if let iCloudData = iCloudStore.data(forKey: localFileName) {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode([VocabularyList].self, from: iCloudData) {
                vocabularyLists = decoded
            }
        }
    }
    
    @objc private func syncWithiCloud(notification: Notification) {
        loadVocabularyLists() // Sync with iCloud changes
    }
    
    func updateDateForVocabularyList(vocabularyList: VocabularyList, newDate: Date) {
        if let listIndex = vocabularyLists.firstIndex(where: { $0.id == vocabularyList.id }) {
            vocabularyLists[listIndex].date = newDate
            saveVocabularyLists()
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func addWordToList(vocabularyList: VocabularyList, name: String, translation: String) {
        let newWord = VocabularyWord(name: name, translation: translation)
        vocabularyList.words.append(newWord)
    }
    
    func updateWordInList(vocabularyList: VocabularyList, updatedWord: VocabularyWord) {
        if let listIndex = vocabularyLists.firstIndex(where: { $0.id == vocabularyList.id }) {
            if let wordIndex = vocabularyLists[listIndex].words.firstIndex(where: { $0.id == updatedWord.id }) {
                vocabularyLists[listIndex].words[wordIndex] = updatedWord
                saveVocabularyLists()
            }
        }
    }
    
    
    func addActivityStats(for list: VocabularyList, durationOfActivity: TimeInterval, studiedWords: [VocabularyWord], numberOfWrongAnswers: Int, numberOfTrys: Int, numberOfFirstTrys: Int, numberOfStudies: Int, durationOfActivityPerCard: Double,  percentageOfFirstTries: Double, percentageOfAnswerPerCard: Double) {
            let stats = ActivityStats(
                vocabularyList: list, 
                vocabularyListId: list.id,
                durationOfActivity: durationOfActivity,
                studiedWordsCount: studiedWords.count,
                numberOfWrongAnswers: numberOfWrongAnswers,
                numberOfTrys: numberOfTrys,
                numberOfFirstTrys: numberOfFirstTrys,
                numberOfStudies: numberOfStudies,
                date: Date(),
                durationOfActivityPerCard: durationOfActivityPerCard,
                percentageOfFirstTries:  percentageOfFirstTries,
                percentageOfAnswerPerCard: percentageOfAnswerPerCard
            )
            activityStats.append(stats)
            saveActivityStats()
        }
    
    // Sauvegarder les statistiques dans un fichier
        func saveActivityStats() {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(activityStats) {
                let fileURL = getDocumentsDirectory().appendingPathComponent(statsFileName)
                try? encoded.write(to: fileURL)
            }
        }
        
        // Charger les statistiques depuis un fichier
        func loadActivityStats() {
            let fileURL = getDocumentsDirectory().appendingPathComponent(statsFileName)
            if let data = try? Data(contentsOf: fileURL) {
                let decoder = JSONDecoder()
                if let decoded = try? decoder.decode([ActivityStats].self, from: data) {
                    activityStats = decoded
                }
            }
        }
        
    func getNumberOfStudies(for vocabularyList: VocabularyList) -> Int {
           return activityStats.last(where: { $0.vocabularyListId == vocabularyList.id })?.numberOfStudies ?? 0
       }
    
    func updateNumberOfStudies(for vocabularyList: VocabularyList, newValue: Int) {
            if let index = activityStats.firstIndex(where: { $0.vocabularyListId == vocabularyList.id }) {
                activityStats[index].numberOfStudies = newValue
            }
        }
    func generateVocabularyListJSON() -> Data? {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            do {
                let data = try encoder.encode(vocabularyLists)
                return data
            } catch {
                print("Erreur lors de l'encodage en JSON: \(error)")
                return nil
            }
        }
        
        func generateActivityStatsJSON() -> Data? {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            do {
                let data = try encoder.encode(activityStats)
                return data
            } catch {
                print("Erreur lors de l'encodage en JSON: \(error)")
                return nil
            }
        }
 
}

