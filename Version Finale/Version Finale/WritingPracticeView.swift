//
//  TextView.swift
//  Version Finale
//
//  Created by Tiago Alves on 22.07.2024.
//

import SwiftUI
import Foundation

// Helper extension to find the longest common suffix
extension String {
    func commonSuffix(with other: String) -> String {
        var suffix = ""
        let selfReversed = self.reversed()
        let otherReversed = other.reversed()
        
        for (charSelf, charOther) in zip(selfReversed, otherReversed) {
            if charSelf == charOther {
                suffix.append(charSelf)
            } else {
                break
            }
        }
        
        return String(suffix.reversed())
    }
}

// Custom SequenceMatcher implementation
struct SequenceMatcher {
    var a: String
    var b: String

    init(a: String, b: String) {
        self.a = a
        self.b = b
    }

    func getOpcodes() -> [(operation: Operation, rangeA: Range<String.Index>, rangeB: Range<String.Index>)] {
        var opcodes: [(operation: Operation, rangeA: Range<String.Index>, rangeB: Range<String.Index>)] = []
        let commonPrefix = a.commonPrefix(with: b)
        let commonSuffix = a.commonSuffix(with: b)

        let startA = a.index(a.startIndex, offsetBy: commonPrefix.count)
        let endA = a.index(a.endIndex, offsetBy: -commonSuffix.count)
        let startB = b.index(b.startIndex, offsetBy: commonPrefix.count)
        let endB = b.index(b.endIndex, offsetBy: -commonSuffix.count)

        if commonPrefix.count > 0 {
            opcodes.append((.equal, a.startIndex..<startA, b.startIndex..<startB))
        }

        if startA != endA || startB != endB {
            let rangeA = startA..<endA
            let rangeB = startB..<endB

            if rangeA.isEmpty {
                opcodes.append((.insert, rangeA, rangeB))
            } else if rangeB.isEmpty {
                opcodes.append((.delete, rangeA, rangeB))
            } else {
                opcodes.append((.replace, rangeA, rangeB))
            }
        }

        if commonSuffix.count > 0 {
            opcodes.append((.equal, endA..<a.endIndex, endB..<b.endIndex))
        }

        return opcodes
    }

    enum Operation {
        case equal
        case insert
        case delete
        case replace
    }
}

struct WritingPracticeView: View {
    var vocab: String
    var vocab2: String
    @Namespace var namespace
    @State private var userAnswer: String = ""
    @State private var feedbackMessage: String = ""
    @Binding var isCorrect: Bool
    @Binding var isShowingWritingPractice: Bool
    @State private var isShowingTextField: Bool = true
    var onComplete: () -> Void
    @Binding var wordsToStudy: [VocabularyWord]
    @State private var correctionButtonText: String = "Corriger! La réponse était juste!"
    @FocusState private var keyboardFOcused: Bool
    @Binding var ColorButton: Bool
    @Binding var NombredeMots: Int
    @Binding var numberOfWrongAnswer: Int
    var vocabularyList: VocabularyList
    
    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()
            VStack {
                if isShowingTextField {
                    topBarView()
                    
                    Text("Écrivez la traduction de : \(vocab)")
                        .font(.system(size: 20))
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding()

                    TextField("Tapez votre réponse ici", text: $userAnswer, axis: .vertical)
                        .textInputAutocapitalization(.never)
                        .padding()
                        .autocorrectionDisabled()
                    
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.blue, lineWidth: 1)
                        )
                        .focused($keyboardFOcused)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                keyboardFOcused = true
                            }
                        }
                    Button(action: {
                        checkAnswer()
                        isShowingTextField = false
                    }) {
                        Text("Vérifier la réponse")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                } else {
                    topBarView()
                    
                    Text("Le mot était: \(vocab)")
                        .font(.system(size: 25))
                        .padding(.top, 70)
                    
                    if !userAnswer.isEmpty && !isCorrect {
                        let (highlightedUserAnswer, highlightedCorrectAnswer) = showDiff(strA: userAnswer, strB: vocab2)
                        Text("Votre réponse était: ").font(.system(size: 25)) + highlightedUserAnswer
                        Text("La réponse correcte est: ").font(.system(size: 25)) + highlightedCorrectAnswer
                    }
                    
                    Text(feedbackMessage)
                        .multilineTextAlignment(.center)
                        .padding()
                        .foregroundColor(isCorrect ? .green : .red)
                    
                    if !isCorrect {
                        Button(action: {
                            isCorrect = true
                            onComplete()
                            isShowingTextField = true
                            userAnswer = ""
                        }) {
                            Text("\(correctionButtonText)")
                                .padding()
                                .background(.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .shadow(radius: 10)
                        }
                    }
                    Spacer()
                    controlButtons()
                }
            }
            .padding()
            .cornerRadius(15)
            .matchedGeometryEffect(id: "writingPractice", in: namespace)
        }
    }

    private func showDiff(strA: String, strB: String) -> (Text, Text) {
        let seqMatcher = SequenceMatcher(a: strA, b: strB)
        var outputA = Text("")
        var outputB = Text("")
        
        for tag in seqMatcher.getOpcodes() {
            switch tag.operation {
            case .equal:
                outputA = outputA + Text(String(strA[tag.rangeA])).foregroundColor(.primary)
                outputB = outputB + Text(String(strB[tag.rangeB])).foregroundColor(.primary)
            case .insert:
                outputB = outputB + Text(String(strB[tag.rangeB])).foregroundColor(.red).bold()
            case .delete:
                outputA = outputA + Text(String(strA[tag.rangeA])).foregroundColor(.red).bold()
            case .replace:
                outputA = outputA + Text(String(strA[tag.rangeA])).foregroundColor(.red).bold()
                outputB = outputB + Text(String(strB[tag.rangeB])).foregroundColor(.red).bold()
            }
        }
        return (outputA, outputB)
    }

    private func checkAnswer() {
        let correctAnswer = vocab2
        let normalizedUserAnswer = userAnswer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        if normalizedUserAnswer == correctAnswer.lowercased() {
            feedbackMessage = "Correct !"
            isCorrect = true
        } else {
            feedbackMessage = "Incorrect. La réponse correcte est : \(correctAnswer)"
            isCorrect = false
        }
    }

    @ViewBuilder
    private func topBarView() -> some View {
        if wordsToStudy.count > 0{
            HStack {
                
                Button {
                    ColorButton.toggle()
                } label: {
                    Image(systemName: "checklist")
                }
                .padding()
                
                if isCorrect {
                    let motsrestants = wordsToStudy.count - 1
                    Text("Nombre de mots restants: \n \(motsrestants)/\(vocabularyList.words.count)")
                        .multilineTextAlignment(.center)
                        .padding(.top, 10)
                        .padding(.leading, 20)
                        .foregroundStyle(ColorButton ? Color(.systemGray6) : .black)
                } else {
                    Text("Nombre de mots restants: \n \(wordsToStudy.count)/\(vocabularyList.words.count)")
                        .multilineTextAlignment(.center)
                        .padding(.top, 10)
                        .padding(.leading, 20)
                        .foregroundStyle(ColorButton ? Color(.systemGray6) : Color(.systemGray))
                }
                Spacer()
            }
        }
    }
    @ViewBuilder
    private func controlButtons() -> some View {
        
        if (wordsToStudy.count > 1) || (wordsToStudy.count == 1 && !isCorrect) {
           
            Button(action: {
                onComplete()
                isShowingTextField = true
                userAnswer = ""
            }) {
                Text("Passer au mot suivant")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.icon)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 3)
                    .shadow(radius: 10)
            }
        } else if wordsToStudy.count == 1 && isCorrect {
            Button(action: { onComplete() }) {
                Text("Fin de la liste")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.icon)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 3)
            }
        }
    }
}
