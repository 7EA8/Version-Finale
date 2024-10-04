//
//  Class Declaration.swift
//  Version Finale
//
//  Created by Tiago Alves on 08.07.2024.
//

import Foundation
import SwiftUI
import Combine

class VocabularyList: ObservableObject, Identifiable, Codable, Hashable, Equatable {
    
    // Fonction pour vérifier l'égalité entre deux listes
    static func == (lhs: VocabularyList, rhs: VocabularyList) -> Bool {
        lhs.id == rhs.id && lhs.name == rhs.name && lhs.words == rhs.words && lhs.date == rhs.date
    }

    // Fonction de hashage pour utiliser cet objet dans un ensemble ou comme clé
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(words)
        hasher.combine(date)
    }

    @Published var name: String
    @Published var words: [VocabularyWord]
    @Published var date: Date
   
    
    
    var id: UUID // ID persistant

    // Initialisation avec un ID persisté (ou nouvel ID si aucun n'est fourni)
    init(id: UUID = UUID(), name: String, words: [VocabularyWord], date: Date = Date(), isStudyWriting: Bool, isStudySwipeCards: Bool, isStudyButtonCard: Bool) {
        self.id = id
        self.name = name
        self.words = words
        self.date = date
       
    }

    // Implémentation de Codable avec l'ajout de l'ID dans la sérialisation
    enum CodingKeys: CodingKey {
        case id, name, words, date
    }

    // Décodeur pour restaurer un objet depuis un format encodé (par exemple JSON)
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id) // Charge l'ID sauvegardé
        name = try container.decode(String.self, forKey: .name)
        words = try container.decode([VocabularyWord].self, forKey: .words)
        date = try container.decode(Date.self, forKey: .date)
        
    }

    // Encodeur pour sauvegarder un objet au format encodé (par exemple JSON)
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id) // Sauvegarde l'ID
        try container.encode(name, forKey: .name)
        try container.encode(words, forKey: .words)
        try container.encode(date, forKey: .date)
        
    }
}

struct VocabularyWord: Identifiable, Codable, Hashable, Equatable {
    let id: UUID
    var name: String
    var translation: String
    

    init(id: UUID = UUID(), name: String, translation: String, imageName: String? = nil, audioFileName: String? = nil) {
        self.id = id
        self.name = name
        self.translation = translation
    }

    // Equatable
    static func == (lhs: VocabularyWord, rhs: VocabularyWord) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.translation == rhs.translation
    }

    // Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(translation)
        
    }
}

class ActivityStats: Identifiable, ObservableObject, Codable, Hashable, Equatable {
    @Published var vocabularyList: VocabularyList
    @Published var id = UUID()
    @Published var vocabularyListId: UUID
    @Published var durationOfActivity: TimeInterval
    @Published var studiedWordsCount: Int
    @Published var numberOfWrongAnswers: Int
    @Published var numberOfTrys: Int
    @Published var numberOfFirstTrys: Int
    @Published var numberOfStudies: Int = 0
    @Published var date: Date = Date()
    @Published var durationOfActivityPerCard: Double
    @Published var percentageOfFirstTries: Double
    @Published var percentageOfAnswerPerCard: Double
    
    // Initialiser les propriétés
    init(
        vocabularyList: VocabularyList,
        vocabularyListId: UUID,
        durationOfActivity: TimeInterval,
        studiedWordsCount: Int,
        numberOfWrongAnswers: Int,
        numberOfTrys: Int,
        numberOfFirstTrys: Int,
        numberOfStudies: Int,
        date: Date,
        durationOfActivityPerCard: Double,
        percentageOfFirstTries: Double,
        percentageOfAnswerPerCard: Double
        
    ) {
        self.vocabularyList = vocabularyList
        self.vocabularyListId = vocabularyList.id
        self.durationOfActivity = durationOfActivity
        self.studiedWordsCount = studiedWordsCount
        self.numberOfWrongAnswers = numberOfWrongAnswers
        self.numberOfTrys = numberOfTrys
        self.numberOfFirstTrys = numberOfFirstTrys
        self.numberOfStudies = numberOfStudies
        self.date = date
        self.durationOfActivityPerCard = durationOfActivityPerCard
        self.percentageOfFirstTries = percentageOfFirstTries
        self.percentageOfAnswerPerCard = percentageOfAnswerPerCard
    }
    
    // Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(vocabularyList)
        hasher.combine(vocabularyListId)
        hasher.combine(durationOfActivity)
        hasher.combine(studiedWordsCount)
        hasher.combine(numberOfWrongAnswers)
        hasher.combine(numberOfTrys)
        hasher.combine(numberOfFirstTrys)
        hasher.combine(numberOfStudies)
        hasher.combine(date)
        hasher.combine(durationOfActivityPerCard)
        hasher.combine(percentageOfFirstTries)
        hasher.combine(percentageOfAnswerPerCard)
    }

    // Equatable (ajouté)
    static func == (lhs: ActivityStats, rhs: ActivityStats) -> Bool {
        return lhs.id == rhs.id &&
            lhs.vocabularyList == rhs.vocabularyList &&
            lhs.vocabularyListId == rhs.vocabularyListId &&
            lhs.durationOfActivity == rhs.durationOfActivity &&
            lhs.studiedWordsCount == rhs.studiedWordsCount &&
            lhs.numberOfWrongAnswers == rhs.numberOfWrongAnswers &&
            lhs.numberOfTrys == rhs.numberOfTrys &&
            lhs.numberOfFirstTrys == rhs.numberOfFirstTrys &&
            lhs.numberOfStudies == rhs.numberOfStudies &&
            lhs.date == rhs.date &&
            lhs.durationOfActivityPerCard == rhs.durationOfActivityPerCard &&
            lhs.percentageOfFirstTries == rhs.percentageOfFirstTries &&
            lhs.percentageOfAnswerPerCard == rhs.percentageOfAnswerPerCard
    }

    // Encode/decode les propriétés conformes à Codable
    enum CodingKeys: String, CodingKey {
        case vocabularyList
        case id
        case vocabularyListId
        case durationOfActivity
        case studiedWordsCount
        case numberOfWrongAnswers
        case numberOfTrys
        case numberOfFirstTrys
        case numberOfStudies
        case date
        case durationOfActivityPerCard
        case percentageOfFirstTries
        case percentageOfAnswerPerCard
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        vocabularyList = try container.decode(VocabularyList.self, forKey: .vocabularyList)
        id = try container.decode(UUID.self, forKey: .id)
        vocabularyListId = try container.decode(UUID.self, forKey: .vocabularyListId)
        durationOfActivity = try container.decode(TimeInterval.self, forKey: .durationOfActivity)
        studiedWordsCount = try container.decode(Int.self, forKey: .studiedWordsCount)
        numberOfWrongAnswers = try container.decode(Int.self, forKey: .numberOfWrongAnswers)
        numberOfTrys = try container.decode(Int.self, forKey: .numberOfTrys)
        numberOfFirstTrys = try container.decode(Int.self, forKey: .numberOfFirstTrys)
        numberOfStudies = try container.decode(Int.self, forKey: .numberOfStudies)
        date = try container.decode(Date.self, forKey: .date)
        durationOfActivityPerCard = try container.decode(Double.self, forKey: .durationOfActivityPerCard)
        percentageOfFirstTries = try container.decode(Double.self, forKey: .percentageOfFirstTries)
        percentageOfAnswerPerCard = try container.decode(Double.self, forKey: .percentageOfAnswerPerCard)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(vocabularyList, forKey: .vocabularyList)
        try container.encode(id, forKey: .id)
        try container.encode(vocabularyListId, forKey: .vocabularyListId)
        try container.encode(durationOfActivity, forKey: .durationOfActivity)
        try container.encode(studiedWordsCount, forKey: .studiedWordsCount)
        try container.encode(numberOfWrongAnswers, forKey: .numberOfWrongAnswers)
        try container.encode(numberOfTrys, forKey: .numberOfTrys)
        try container.encode(numberOfFirstTrys, forKey: .numberOfFirstTrys)
        try container.encode(numberOfStudies, forKey: .numberOfStudies)
        try container.encode(date, forKey: .date)
        try container.encode(durationOfActivityPerCard, forKey: .durationOfActivityPerCard)
        try container.encode(percentageOfFirstTries, forKey: .percentageOfFirstTries)
        try container.encode(percentageOfAnswerPerCard, forKey: .percentageOfAnswerPerCard)
    }
}
