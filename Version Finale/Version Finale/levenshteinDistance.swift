//
//  levenshteinDistance.swift
//  Version Finale
//
//  Created by Tiago Alves on 22.07.2024.
//

import SwiftUI

// Fonction pour calculer la distance de Levenshtein
func levenshteinDistance(_ a: String, _ b: String) -> Int {
    let aChars = Array(a)
    let bChars = Array(b)
    let m = aChars.count
    let n = bChars.count
    
    // Tableau de coûts
    var dist = [[Int]](repeating: [Int](repeating: 0, count: n + 1), count: m + 1)
    
    // Initialisation
    for i in 0...m {
        dist[i][0] = i
    }
    for j in 0...n {
        dist[0][j] = j
    }
    
    // Calcul de la distance de Levenshtein
    for i in 1...m {
        for j in 1...n {
            if aChars[i - 1] == bChars[j - 1] {
                dist[i][j] = dist[i - 1][j - 1]
            } else {
                let deletion = dist[i - 1][j] + 1
                let insertion = dist[i][j - 1] + 1
                let substitution = dist[i - 1][j - 1] + 1
                dist[i][j] = min(deletion, min(insertion, substitution))
            }
        }
    }
    
    return dist[m][n]
}

// Fonction pour déterminer si la distance est permissible
func isDistancePermissible(_ distance: Int, length: Int) -> Bool {
    // Par exemple, si on considère une distance permissible de 20% de la longueur
    let permissibleThreshold = Int(Double(length) * 0.15)
    return distance <= permissibleThreshold
}

// Vue SwiftUI pour comparer deux mots
struct LevenshteinDistanceView: View {
    @State private var word1: String = ""
    @State private var word2: String = ""
    @State private var distance: Int = 0
    @State private var isPermissible: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Comparaison de la distance de Levenshtein")
                .font(.headline)
            
            TextField("Entrez le premier mot", text: $word1)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Entrez le deuxième mot", text: $word2)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: {
                calculateDistance()
            }) {
                Text("Comparer")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Text("Distance de Levenshtein : \(distance)")
            Text("Distance permissible : \(isPermissible ? "Oui" : "Non")")
                .foregroundColor(isPermissible ? .green : .red)
        }
        .padding()
    }
    
    private func calculateDistance() {
        distance = levenshteinDistance(word1, word2)
        let maxLength = max(word1.count, word2.count)
        isPermissible = isDistancePermissible(distance, length: maxLength)
    }
}

// Preview de la vue
//struct LevenshteinDistanceView_Previews: PreviewProvider {
  //  static var previews: some View {
    //    LevenshteinDistanceView()
      //      .previewLayout(.sizeThatFits)
        //    .padding()
    //}
//}
import SwiftUI
import NaturalLanguage

struct SemanticComparisonView: View {
    @State private var sentence1: String = ""
    @State private var sentence2: String = ""
    @State private var resultMessage: String = ""

    var body: some View {
        VStack(spacing: 20) {
            TextField("Entrez la première phrase", text: $sentence1)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Entrez la deuxième phrase", text: $sentence2)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: compareSentences) {
                Text("Comparer")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Text(resultMessage)
                .padding()
        }
        .padding()
    }
    
    private func compareSentences() {
        guard !sentence1.isEmpty, !sentence2.isEmpty else {
            resultMessage = "Veuillez entrer les deux phrases."
            return
        }
        
        let similarityScore = calculateSimilarity(sentence1: sentence1, sentence2: sentence2)
        resultMessage = "La similarité entre les phrases est: \(similarityScore)"
    }
    
    private func calculateSimilarity(sentence1: String, sentence2: String) -> Double {
        guard let embedding1 = embedSentence(sentence1),
              let embedding2 = embedSentence(sentence2) else {
            return 0.0
        }
        
        return cosineSimilarity(embedding1, embedding2)
    }
    
    private func embedSentence(_ sentence: String) -> [Double]? {
        let embedding = NLEmbedding.sentenceEmbedding(for: .english)
        guard let vector = embedding?.vector(for: sentence) else {
            return nil
        }
        return vector.map { Double($0) }
    }
    
    private func cosineSimilarity(_ vector1: [Double], _ vector2: [Double]) -> Double {
        guard vector1.count == vector2.count else { return 0.0 }
        
        let dotProduct = zip(vector1, vector2).map(*).reduce(0.0, +)
        let magnitude1 = sqrt(vector1.map { $0 * $0 }.reduce(0.0, +))
        let magnitude2 = sqrt(vector2.map { $0 * $0 }.reduce(0.0, +))
        
        return dotProduct / (magnitude1 * magnitude2)
    }
}

struct SemanticComparisonView_Previews: PreviewProvider {
    static var previews: some View {
        SemanticComparisonView()
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
