//
//  VocabularyListView.swift
//  Version Finale
//
//  Created by Tiago Alves on 04.07.2024.
//
import SwiftUI
import PhotosUI
import AVFoundation
import MobileCoreServices

struct VocabularyListView: View {
    @EnvironmentObject var dataStore: DataStore
    @ObservedObject var vocabularyList: VocabularyList
    @State private var isShowingAddWordView = false
    @State private var wordToEdit: VocabularyWord?
    @State private var isStudyingList = false
    @State private var isShowingShareSheet = false
    @State private var isShowingAddWordsModal = false
    @State private var isShowingCalendar = false
    @State private var newWordsText = ""
    @Environment(\.dismiss) private var dismiss
    @State private var numberOfTimesShown = 0
    @State private var numberOfStudies = 0
    @State private var isStudyChoicePresented: Bool = false
    @AppStorage("isStudySwipeCards") var isStudySwipeCards = true
    @AppStorage("isStudyButtonCard") var isStudyButtonCard = false
    @AppStorage("isStudyWriting") var isStudyWriting = false
    @AppStorage("soon") var soon: Int = 1
    @AppStorage("late") var late: Int = 1
    var activityStats: [ActivityStats]

        @State private var shareItems: [Any] = []
    
    
    
    var body: some View {
       
        
        VStack {
            if vocabularyList.words.isEmpty {
                emptyListView
            } else {
                filledListView
                
            }
        }
        .onAppear(){
            numberOfStudies = dataStore.getNumberOfStudies(for: vocabularyList)
        }
        .background(Color(.systemGray6))
        .navigationTitle(vocabularyList.name)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "chevron.backward")
                        Text("Listes de vocabulaire")
                    }
                }
            }
            
                ToolbarItem(placement: .topBarTrailing) {
                    if vocabularyList.words.count > 0{
                        Button {
                            isStudyChoicePresented = true
                        } label: {
                            HStack {
                                Image(systemName: "gearshape")
                                
                            }
                        }
                    }
            }
        }
        
        .onAppear(){
            if !isStudyingList{
                numberOfTimesShown = 0
            }
        }
        .onDisappear {
            dataStore.saveVocabularyLists()
        }
        .transition(AnyTransition.scale.animation(.spring(duration: 0.1)))
        
        .sheet(isPresented: $isShowingAddWordsModal) {
            AddWordsModalView(isPresented: $isShowingAddWordsModal, newWordsText: $newWordsText, onAddWords: addWordsFromText, isShowingAddWordView: $isShowingAddWordView)
        }
        .sheet(isPresented: $isShowingCalendar) {
            CalendarView(vocabularyList: vocabularyList, isShowingCalendar: $isShowingCalendar)
        }
        .sheet(isPresented: $isStudyChoicePresented){
            SettingsView(isStudyChoicePresented: $isStudyChoicePresented, vocabularyList: vocabularyList, isStudySwipeCards: $isStudySwipeCards, isStudyWriting: $isStudyWriting, isStudyButtonCard: $isStudyButtonCard,soon: $soon, late: $late)
        }
        .sheet(isPresented: $isShowingShareSheet) {
            ShareSheet(activityItems: shareItems)
        }

    }
    
    private var emptyListView: some View {
        ZStack{
            Color(.systemGray6)
            VStack {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(.icon)
                    .padding()
                Text("Votre liste est vide!")
                Button(action: {
                    isShowingAddWordView = true
                }) {
                    Text("Veuillez ajouter un mot")
                        .padding()
                        .background(Color.icon)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .sheet(isPresented: $isShowingAddWordView) {
                    AddWordToListView(vocabularyList: vocabularyList, isShowingAddWordView: $isShowingAddWordView, addNewWord: addNewWord, isShowingAddWordsModal: $isShowingAddWordsModal)
                        .environmentObject(dataStore)
                }
            }
        }
        
    }
    private var filledListView: some View {
        VStack {
        //    Button(action: {
        //        if let jsonData = dataStore.generateVocabularyListJSON() {
        //                        let tempFileURL = FileManager.default.temporaryDirectory.appendingPathComponent("vocabularyLists.json")
        //                        do {
        //                            try jsonData.write(to: tempFileURL, options: .atomic)
        //                            shareItems = [tempFileURL]
        //                            isShowingShareSheet = true
        //                        } catch {
        //                            print("Erreur lors de l'écriture du fichier temporaire: \(error)")
        //                        }
        //                    }
         //               }) {
        //                    Text("Télécharger les listes de vocabulaire")
        //                        .frame(maxWidth: .infinity)
        //                        .padding()
        //                        .background(Color.blue)
        //                        .foregroundColor(.white)
        //                        .cornerRadius(10)
        //                }
        //
        //                Button(action: {
        //                    if let jsonData = dataStore.generateActivityStatsJSON() {
        //                        let tempFileURL = FileManager.default.temporaryDirectory.appendingPathComponent("activityStats.json")
        //                        do {
        //                            try jsonData.write(to: tempFileURL, options: .atomic)
        //                            shareItems = [tempFileURL]
        //                            isShowingShareSheet = true
        //                        } catch {
        //                            print("Erreur lors de l'écriture du fichier temporaire: \(error)")
        //                        }
        //                    }
        //                }) {
        //                    Text("Télécharger les statistiques d'activité")
        //                        .frame(maxWidth: .infinity)
        //                        .padding()
        //                        .background(Color.blue)
        //                        .foregroundColor(.white)
        //                        .cornerRadius(10)
           //             }
            HStack {
                Button(action: {
                    isShowingCalendar = true
                }) {
                    Image(systemName: "calendar")
                }
                .padding(.leading,25)
                .padding(.top,5)
                .padding(.bottom,3)
                Spacer()
                if numberOfStudies > 1 {
                    NavigationLink(destination: StatsGraphView(activityStats: activityStats, vocabularyList: vocabularyList)) {
                        Text("Graphiques de votre évolution")
                            
                        .padding()
                            .background(.icon)
                            .foregroundColor(.white)
                        .cornerRadius(10)}
                    
                    
                }
                Spacer()
                
                Button(action: {
                    isShowingShareSheet = true
                }) {
                    Image(systemName: "arrowshape.turn.up.forward")
                }
                .padding(.trailing,25)
                .padding(.top,5)
                .padding(.bottom,3)
               
            }
            List {
                ForEach(vocabularyList.words) { word in
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
                    .onTapGesture {
                        wordToEdit = word
                    }
                }
                .onDelete { indexSet in
                    vocabularyList.words.remove(atOffsets: indexSet)
                    dataStore.saveVocabularyLists()
                }
            }
            .listStyle(InsetGroupedListStyle())
            
            Button(action: {
                isShowingAddWordView = true
            }) {
                Text("Ajouter un nouveau mot")
                    .frame(width: 250)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            .sheet(isPresented: $isShowingAddWordView) {
                AddWordToListView(vocabularyList: vocabularyList, isShowingAddWordView: $isShowingAddWordView, addNewWord: addNewWord, isShowingAddWordsModal: $isShowingAddWordsModal)
                    .environmentObject(dataStore)
            }
            .sheet(item: $wordToEdit) { word in
                EditWordView(word: word, isShowingEditWordView: .constant(true)) { updatedWord in
                    if let index = vocabularyList.words.firstIndex(where: { $0.id == updatedWord.id }) {
                        vocabularyList.words[index] = updatedWord
                        dataStore.saveVocabularyLists()
                    }
                }
            }
            
            
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
                
                let listStats = dataStore.activityStats.first(where: { $0.vocabularyListId == vocabularyList.id }) ?? defaultStats
               
            NavigationLink(destination:{
                if isStudyWriting || isStudyButtonCard || isStudySwipeCards{
                    SwipeCardsView(
                        vocabularyList: vocabularyList,
                        numberForTheEndOfTheRound: 0,
                        activityStats: dataStore.activityStats,
                        numberOfTimesShown: $numberOfTimesShown,
                        Stats: listStats,
                        numberOfStudies: $numberOfStudies,
                        isStudySwipeCards: $isStudySwipeCards,
                        isStudyWriting: $isStudyWriting,
                        isStudyButtonCard: $isStudyButtonCard,
                        soon: $soon,
                        late: $late)
                }else{
                    Text("Il faut choisir une méthode d'étude")
                }
            } ) {
                Text("Étudier la liste")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.icon)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .simultaneousGesture(TapGesture().onEnded {
                if numberOfStudies == 0 {
                    isStudyChoicePresented = true
                }
                numberOfStudies += 1
             
                
                print("Nombre d'études après mise à jour: \(numberOfStudies)")
            })
            .onAppear {
                // Récupérer la valeur depuis le DataStore
                numberOfStudies = dataStore.getNumberOfStudies(for: vocabularyList)
                print("Nombre d'études après chargement: \(numberOfStudies)")
            }
            .padding()

                
            
        }
        
        .background(Color(.systemGray6))
        
    }
    
    private func generateShareText() -> String {
        return vocabularyList.words.enumerated().map { (index, word) in
            let separator = index == vocabularyList.words.count - 1 ? "" : ";"
            return "\(word.name); \(word.translation)\(separator)"
        }.joined(separator: "\n")
    }

    
    private func addWordsFromText(_ text: String) {
        let wordsArray = text.components(separatedBy: ";")
        
        var i = 0
        while i < wordsArray.count {
            let name = wordsArray[i].trimmingCharacters(in: .whitespacesAndNewlines)
            let translation = (i + 1 < wordsArray.count ? wordsArray[i + 1] : "").trimmingCharacters(in: .whitespacesAndNewlines)
            
            if !name.isEmpty && !translation.isEmpty {
                dataStore.addWordToList(vocabularyList: vocabularyList, name: name, translation: translation)
            }
            
            i += 2
        }
        
        dataStore.saveVocabularyLists()
    }
    
    private func addNewWord(_ name: String, _ translation: String, imageName: String?, audioFileName: String?) {
        dataStore.addWordToList(vocabularyList: vocabularyList, name: name, translation: translation)
        dataStore.saveVocabularyLists()
    }
    
}

struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct ShareStats: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

