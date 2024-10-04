//
//  SwipeCardsView.swift
//  Version Finale
//
//  Created by Tiago Alves on 17.07.2024.
//
import SwiftUI
import ConfettiSwiftUI

struct SwipeCardsView: View {
    @EnvironmentObject var dataStore: DataStore
        var vocabularyList: VocabularyList
        var activityStats: [ActivityStats]
        var Stats: ActivityStats
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
        @State private var isShowingAnswer: Bool = false
        @State private var wordsToStudy: [VocabularyWord]
        @State private var studiedWords: [VocabularyWord] = []
        @State private var showConfetti = 0
        @State private var offset = CGSize.zero
        @State private var color = Color(.label)
        @State private var lastTapTime: Date?
        @State private var isRemovingCard = false
        @State private var currentWord: VocabularyWord?
        @Namespace private var animationNamespace
        
        @State private var isCorrect: Bool = false
        @State private var NombredeMots = 0
        @State private var ColorButton = false
        @State private var StartOfTheRevision: Date?
        @State private var EndOfTheRevision: Date?
        @State private var DurationOfTheRevision: TimeInterval = 0
        @State private var numberOfWrongAnswer = 0
        @State private var numberOfTrys = 0
        @State private var numberOfRound = 0
        @State private var numberOfFirstTrys = 0
        @Binding  var numberOfStudies: Int
        @State private var endOfRound = false
        @State private var numberForTheEndOfTheRound: Int = -1
        @State private var isShowingStats = false
        @Binding var numberOfTimesShown: Int
        @Binding var isStudySwipeCards: Bool
        @Binding var isStudyWriting: Bool
        @Binding var isStudyButtonCard: Bool
        @Binding var soon: Int
        @Binding var late: Int
        @State private var studyComplete = false
        @State private var navigateToStats = false
    private var lastStats: ActivityStats?{
        dataStore.activityStats
            .filter { $0.vocabularyListId == vocabularyList.id }
            .last
    }
    private var formatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute, .second, .nanosecond]
        formatter.unitsStyle = .abbreviated
        formatter.calendar?.locale = Locale(identifier: "fr_FR")
        
        return formatter
    }
        init(
            vocabularyList: VocabularyList,
            numberForTheEndOfTheRound: Int,
            activityStats: [ActivityStats],
            numberOfTimesShown: Binding<Int>,
            Stats: ActivityStats,
            numberOfStudies: Binding<Int>,
            isStudySwipeCards: Binding<Bool>,
            isStudyWriting: Binding<Bool>,
            isStudyButtonCard: Binding<Bool>,
            soon: Binding<Int>,
            late: Binding<Int>
        ) {
            self.vocabularyList = vocabularyList
            self._wordsToStudy = State(initialValue: vocabularyList.words)
            self.activityStats = activityStats
            self.Stats = Stats
            self._numberOfTimesShown = numberOfTimesShown
            self._numberOfStudies = numberOfStudies
            self._isStudySwipeCards = isStudySwipeCards
            self._isStudyWriting = isStudyWriting
            self._isStudyButtonCard = isStudyButtonCard
            self._soon = soon
            self._late = late
        }
    
    var body: some View {
       
            ZStack {
                Color(.systemGray6)
                    .edgesIgnoringSafeArea(.all)
                
                if endOfRound {
                    endRoundContent()
                } else if !wordsToStudy.isEmpty {
                    ZStack {
                        studyContent()
                        
                    }
                    .onAppear {
                        if StartOfTheRevision == nil {
                            StartOfTheRevision = Date()
                        }
                        
                    }
                    .onDisappear {
                        
                        if wordsToStudy.isEmpty {
                            
                            EndOfTheRevision = Date()
                          
                            if let startOfTheRevision = StartOfTheRevision, let endOfTheRevision = EndOfTheRevision {
                                DurationOfTheRevision = endOfTheRevision.timeIntervalSince(startOfTheRevision)
                             
                            }
                        }
                    }
                } else {
                    
                    felicitationContent()
                        .padding()
                        .background(Color(.systemGray6).ignoresSafeArea())
                        
                }
            }
            .onAppear(){
                print("quel est le nombre d'études mtn?\(numberOfStudies)")
            }
            .onChange(of: wordsToStudy) {
                offset = .zero
                color = Color(.label)
                isRemovingCard = false
                
            }.navigationBarBackButtonHidden(true) // Cache le bouton "Back" par défaut
            .toolbar {
                
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(action: {
                                    if wordsToStudy.isEmpty{
                                        calculateStatsIfNeeded()
                                    }
                                    presentationMode.wrappedValue.dismiss() // Quitte la vue
                                }) {
                                    HStack {
                                        Image(systemName: "chevron.left")
                                        Text("\(vocabularyList.name)")
                                    }
                                }
                            }
            }
    }
    private func statsContent() -> some View {
        StatsView(vocabularyList: vocabularyList, activityStats: Stats)
            .zIndex(0)
    }
    private func felicitationContent() -> some View {
        
        VStack{
           
            if !navigateToStats{
                Text("Félicitations!!!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                   
                Text("Vous avez complété tous les mots!")
                    .onAppear {
                        showConfetti += 1
                        
                    }
                    .multilineTextAlignment(.center)
                    .font(.title2)
                    .padding()
                    
                Button(action: {
                  
                           navigateToStats = true
                       
                }) {
                    Text("Statistiques")
                        .font(.title)
                        .padding()
                        .background(Color.icon)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                
                ConfettiCannon(counter: $showConfetti, repetitions: 3, repetitionInterval: 0.5)
                
                Button(action: {
                    handleConfettiButtonTap()
                }) {
                    Text("PLUS DE CONFETTIS")
                        .font(.footnote)
                }
                .padding()
                .shadow(radius: 3)
                .disabled(lastTapTime != nil && lastTapTime!.timeIntervalSinceNow > -1.0)
                
                
                
            }else {
                let durationOfActivityPerCard = (DurationOfTheRevision / Double(studiedWords.count))
                 let percentageOfFirstTries = (Double(numberOfFirstTrys) / Double(studiedWords.count)) * 100
                 let percentageOfAnswerPerCard = (Double(numberOfWrongAnswer) / Double(numberOfTrys)) * 100
                let TrysperCard = numberOfTrys / studiedWords.count
               
                    Section{
                        // Affichage des dernières stats
                        VStack(alignment: .leading) {
                            Text("Statistiques")
                                .font(.headline)
                                .padding(.bottom, 10)
                            
                            Text("Date: \(.now, format: .dateTime.hour().second().minute().day().month().year())")
                            Text("Temps d'étude: \(DurationOfTheRevision)")
                            Text("Temps d'étude moyen par carte: \(durationOfActivityPerCard)")
                            Text("Nombre d'études: \(numberOfStudies)")
                            Text("Nombre de mots étudiés: \(studiedWords.count)")
                            Text("Nombre d'erreurs: \(numberOfWrongAnswer)")
                            Text("Nombre d'essais: \(numberOfTrys)")
                            Text("Nombre de réussites au premier essai: \(numberOfFirstTrys)")
                            Text("Pourcentage de réussites au premier essai par carte: \(Int(percentageOfFirstTries))%")
                            Text("Pourcentage d'erreurs par essai: \(Int(percentageOfAnswerPerCard))%")
                            Text("Nombre d'essais moyens par carte: \(TrysperCard)")
                            
                        }
                        .environment(\.locale, Locale(identifier: "fr"))
                        .padding()
                    }
                    
                
            }
        }
    }

    // Nouvelle méthode pour calculer les statistiques
    private func calculateStatsIfNeeded() {
       let durationOfActivityPerCard = (DurationOfTheRevision / Double(studiedWords.count))
        let percentageOfFirstTries = (Double(numberOfFirstTrys) / Double(studiedWords.count)) * 100
        let percentageOfAnswerPerCard = (Double(numberOfWrongAnswer) / Double(numberOfTrys)) * 100
print("\(numberOfStudies)")
        print("\(DurationOfTheRevision)")
        dataStore.addActivityStats(
            for: vocabularyList,
            durationOfActivity: DurationOfTheRevision,
            studiedWords: studiedWords,
            numberOfWrongAnswers: numberOfWrongAnswer,
            numberOfTrys: numberOfTrys,
            numberOfFirstTrys: numberOfFirstTrys,
            numberOfStudies: numberOfStudies,
            durationOfActivityPerCard: durationOfActivityPerCard,
            percentageOfFirstTries: percentageOfFirstTries,
            percentageOfAnswerPerCard: percentageOfAnswerPerCard
        )
    print("\(numberOfStudies) nombre d'études stockéer")
        print("garder")
    }

    private func studyContent() -> some View{
        VStack{
            if numberForTheEndOfTheRound == numberOfRound {
                Text("")
                    .onAppear {
                        endOfRound = true
                        numberOfRound = 0
                    }
            }
            
            VStack {
                if isStudyWriting{
                    Text("").onAppear(){
                        print("écriture")}
                    if let currentWord = wordsToStudy.first {
                        WritingPracticeView(
                            vocab: currentWord.name,
                            vocab2: currentWord.translation,
                            namespace: _animationNamespace,
                            isCorrect: $isCorrect,
                            isShowingWritingPractice: $isStudyWriting,
                            onComplete: handleWritingPracticeComplete,
                            wordsToStudy: $wordsToStudy,
                            ColorButton: $ColorButton,
                            NombredeMots: $NombredeMots,
                            numberOfWrongAnswer: $numberOfWrongAnswer, vocabularyList: vocabularyList
                        )
                        
                    }
                }
                if isStudySwipeCards{
                    HStack {
                        Button {
                            ColorButton.toggle()
                        } label: {
                            Image(systemName: "checklist")
                        }
                        .padding()
                        Text(" Nombre de mots restants: \n \(wordsToStudy.count)/\(vocabularyList.words.count)")
                            .multilineTextAlignment(.center)
                            .padding(.top, 10)
                            .padding(.leading, 20)
                            .foregroundStyle(ColorButton ? Color(.systemGray6) : Color(.label))
                        Spacer()
                    }
                    VStack {
                        if vocabularyList.words.count == wordsToStudy.count {
                            Text("")
                                .onAppear {
                                    numberForTheEndOfTheRound = wordsToStudy.count
                                }
                        }
                        
                        if numberForTheEndOfTheRound == numberOfRound {
                            Text("")
                                .onAppear {
                                    endOfRound = true
                                    numberOfRound = 0
                                }
                        }
                        
                        if var currentWord = wordsToStudy.first {
                            if wordsToStudy.count != 1 {
                                CardSwipe(
                                    vocab: currentWord.name,
                                    vocab2: currentWord.translation,
                                    offset: $offset,
                                    color: $color,
                                    onRemove: handleCardRemove,
                                    namespace: animationNamespace,
                                    isShowingAnswer: $isShowingAnswer
                                )
                                .onAppear(){
                                    currentWord = wordsToStudy.first!
                                }
                                .transition(.asymmetric(insertion: .scale, removal: .opacity))
                                .zIndex(isRemovingCard ? 1 : 0)
                                .gesture(
                                    DragGesture()
                                        .onChanged { gesture in
                                            withAnimation(.interpolatingSpring(mass: 1, stiffness: 100, damping: 10, initialVelocity: 0)) {
                                                offset = gesture.translation
                                                changeColor(width: gesture.translation.width)
                                            }
                                        }
                                        .onEnded { gesture in
                                            withAnimation(.interpolatingSpring(mass: 1, stiffness: 100, damping: 10, initialVelocity: 0)) {
                                                handleSwipe(gesture: gesture)
                                            }
                                        }
                                )
                            }else{
                                CardSwipe(
                                    vocab: currentWord.name,
                                    vocab2: currentWord.translation,
                                    offset: $offset,
                                    color: $color,
                                    onRemove: handleCardRemove,
                                    namespace: animationNamespace,
                                    isShowingAnswer: $isShowingAnswer
                                )
                                
                                .transition(.asymmetric(insertion: .scale, removal: .opacity))
                                .zIndex(isRemovingCard ? 1 : 0)
                                .gesture(
                                    DragGesture()
                                        .onChanged { gesture in
                                            withAnimation(.interpolatingSpring(mass: 1, stiffness: 100, damping: 10, initialVelocity: 0)) {
                                                offset = gesture.translation
                                                changeColor(width: gesture.translation.width)
                                            }
                                        }
                                        .onEnded { gesture in
                                            withAnimation(.interpolatingSpring(mass: 1, stiffness: 100, damping: 10, initialVelocity: 0)) {
                                                handleSwipe(gesture: gesture)
                                            }
                                        }
                                )
                                
                            }
                            
                        }
                    }
                    
                    .onAppear {
                        NombredeMots = wordsToStudy.count
                    }
                }
                if isStudyButtonCard{
                    HStack{
                        Button{
                            ColorButton.toggle()
                        } label: {
                            Image(systemName: "checklist")
                        }
                        .padding()
                        Text(" Nombre de mots restants: \n \(wordsToStudy.count)/\(vocabularyList.words.count)")
                        
                            .multilineTextAlignment(.center)
                            .padding(.top,10)
                            .padding(.leading, 20)
                            .foregroundStyle(ColorButton ? Color(.systemGray6) : Color(.label))
                        Spacer()
                    }
                    if let currentWord = wordsToStudy.first {
                        CardSelectionView(vocab: currentWord.name,
                                          vocab2: currentWord.translation,
                                          offset: $offset,
                                          color: $color,
                                          onRemove: handleCardRemove,
                                          onPutSoon: handleCardPutSoon,
                                          onPutLate: handleCardPutLate,
                                          vocabularyList: vocabularyList,
                                          namespace: animationNamespace,
                                          isShowingAnswer: $isShowingAnswer,
                                          soon: $soon,
                                          late: $late)
                        
                        .transition(.asymmetric(insertion: .scale, removal: .opacity))
                        .zIndex(isRemovingCard ? 1 : 0)
                        HStack{
                            Button(action: {
                                handleButtonTapInconnu()
                            }) {
                                Text("Inconnu")
                                    .frame(width: 75)
                                    .padding()
                                    .background(.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            Button(action: {
                                handleButtonTapMoyen()
                            }) {
                                Text("Moyen")
                                    .frame(width: 75)
                                    .padding()
                                    .background(.yellow)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            Button(action: {
                                handleButtonTapConnu()
                            }) {
                                Text("Connu")
                                    .frame(width: 75)
                                    .padding()
                                    .background(.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }.padding()
                        
                    }
                    
                }
            }
        }

    }
    
    private func endRoundContent() -> some View{
        endOfRoundView(endOfRound: $endOfRound, studiedWords: $studiedWords, numberForTheEndOfTheRound: $numberForTheEndOfTheRound, wordsToStudy: $wordsToStudy, StartOfTheRevision: $StartOfTheRevision )
            .onAppear(){
            resetRound()
            }
    }
    private func handleSwipe(gesture: DragGesture.Value) {
        let threshold: CGFloat = 150
        if gesture.translation.width > threshold || gesture.translation.width < -threshold {
            let removalDirection = gesture.translation.width > 0 ? 1 : -1
            withAnimation(.easeInOut) {
                offset = CGSize(width: removalDirection * 500, height: 0)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if removalDirection == -1 {
                    if wordsToStudy.count > 1 {
                        moveCardToEnd()
                    } else if wordsToStudy.count == 1 {
                        moveCardToEnd()
                    }
                } else {
                    handleCardRemove()
                }
            }
        } else {
            withAnimation(.spring()) {
                offset = .zero
            }
        }
    }

    private func moveCardToEnd() {
        if let currentWord = wordsToStudy.first{
            let index = soon
            if wordsToStudy.count != 1{
                wordsToStudy.removeFirst()
                wordsToStudy.insert(currentWord, at: index)
                
            }
        }
            numberOfTrys += 1
            numberOfWrongAnswer += 1
            numberOfRound += 1
            currentWord = wordsToStudy.first // Update current word
        
    }
    private func handleCardPutSoon() {
        isRemovingCard = true
        if let wordStudied = wordsToStudy.first {
            let index = soon
            if wordsToStudy.count != 1 && index != 0 && index < wordsToStudy.count{
                wordsToStudy.removeFirst()
                wordsToStudy.insert(wordStudied, at: index)
            }else{
                wordsToStudy.removeFirst()
                wordsToStudy.append(wordStudied)
            }
            numberOfWrongAnswer += 1
            numberOfTrys += 1
            numberOfRound += 1
            
                currentWord = wordsToStudy.first // Update current word
            
        }
    }
    private func handleCardPutLate() {
        let index = late 
        
        isRemovingCard = true
        if let wordStudied = wordsToStudy.first {
            if wordsToStudy.count != 1 && index != 0 && index < wordsToStudy.count{
                wordsToStudy.removeFirst()
                wordsToStudy.insert(wordStudied, at: index)
            }else{
                wordsToStudy.removeFirst()
                wordsToStudy.append(wordStudied)
            }
            
            numberOfTrys += 1
            numberOfRound += 1
           
                currentWord = wordsToStudy.first // Update current word
            
        }
    }

    private func handleCardRemove() {
        isRemovingCard = true
        if let removedWord = wordsToStudy.first {
            wordsToStudy.removeFirst()
            studiedWords.append(removedWord)
            if numberOfTrys < vocabularyList.words.count {
                numberOfFirstTrys += 1
            }
            numberOfTrys += 1
            numberOfRound += 1
            
                currentWord = wordsToStudy.first // Update current word
            
        }
    }
    
    private func changeColor(width: CGFloat) {
        switch width {
        case -500...(-150):
            color = .red
        case 150...500:
            color = .green
        default:
            color = Color(.label)
        }
    }
    
    private func handleConfettiButtonTap() {
        guard lastTapTime == nil || lastTapTime!.timeIntervalSinceNow <= -1.0 else {
            return
        }
        lastTapTime = Date()
        showConfetti += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.lastTapTime = nil
        }
    }
    
    private func handleWritingPracticeComplete() {
       
            if !isCorrect {
                moveCardToEnd()
            } else {
                handleCardRemove()
            }
            // Mettre à jour currentWord pour le mot suivant après la pratique
            currentWord = wordsToStudy.first
        
    }
    private func resetRound() {
            
            currentWord = wordsToStudy.first
            offset = .zero
        color = Color(.label)
            isRemovingCard = false
            
        }
    private func handleButtonTapConnu() {
        
            withAnimation(.easeInOut(duration: 0.75)) {
                color = .green
                offset = CGSize(width: 500, height: 0)
            }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                   handleCardRemove() // Retirer la carte après l'animation
                   offset = .zero // Réinitialiser l'offset pour la prochaine carte
            color = Color(.label)
               }
        }
    private func handleButtonTapInconnu() {
        
            withAnimation(.easeInOut(duration: 0.75)) {
                color = .red
                offset = CGSize(width: -500, height: 0)
            }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            handleCardPutSoon() // Retirer la carte après l'animation
                   offset = .zero // Réinitialiser l'offset pour la prochaine carte
            color = Color(.label)
               }
        }
    private func handleButtonTapMoyen() {
        
            withAnimation(.easeInOut(duration: 0.75)) {
                color = .yellow
                offset = CGSize(width: 500, height: 0)
            }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            handleCardPutLate()// Retirer la carte après l'animation
                   offset = .zero // Réinitialiser l'offset pour la prochaine carte
            color = Color(.label)
               }
        }
}
struct TestData {
    static let testWords: [VocabularyWord] = [
        VocabularyWord(id: UUID(), name: "123", translation: "123"),
        VocabularyWord(id: UUID(), name: "456", translation: "456"),
        VocabularyWord(id: UUID(), name: "789", translation: "789")
    ]
    
    static let testList = VocabularyList(name: "Test List", words: testWords, isStudyWriting: false, isStudySwipeCards: false, isStudyButtonCard: true)
    
    static let defaultActivityStats = ActivityStats(vocabularyList: testList, vocabularyListId: UUID(), durationOfActivity: 0, studiedWordsCount: 0, numberOfWrongAnswers: 0, numberOfTrys: 0, numberOfFirstTrys: 0, numberOfStudies: 0, date: Date(), durationOfActivityPerCard: 0, percentageOfFirstTries: 0, percentageOfAnswerPerCard: 0)
}

struct SwipeCardsView_Previews: PreviewProvider {
    static var previews: some View {
        // Note: Assurez-vous d'utiliser les données de test appropriées pour l'initialisation de la vue
        SwipeCardsView(
            vocabularyList: TestData.testList,
            
            numberForTheEndOfTheRound: 0,
            activityStats: [TestData.defaultActivityStats],
            
            numberOfTimesShown: .constant(0),
            Stats: TestData.defaultActivityStats,
            numberOfStudies: .constant(0),
            isStudySwipeCards: .constant(false),
            isStudyWriting: .constant(false),
            isStudyButtonCard: .constant(true),
            soon: .constant(1),
            late: .constant(1)
        )
        .environmentObject(DataStore())
    }
}
