//
//  statsGraphView.swift
//  Version Finale
//
//  Created by Tiago Alves on 13.08.2024.
//

import SwiftUI
import Charts

struct StatsGraphView: View {
    @EnvironmentObject var dataStore: DataStore
    var activityStats: [ActivityStats]
    var vocabularyList: VocabularyList
    
    @State private var currentStudy: ActivityStats?

    private var selectedStats: [ActivityStats] {
        dataStore.activityStats.filter { $0.vocabularyListId == vocabularyList.id }
            .sorted { $0.numberOfStudies < $1.numberOfStudies }
    }
    
    private var areaBackground: Gradient {
        Gradient(colors: [.icon, .icon.opacity(0.1)])
    }
    
    private var averageTrys: Double {
        let totalTrys = selectedStats.reduce(0) { $0 + $1.numberOfTrys }
        return selectedStats.isEmpty ? 0.0 : Double(totalTrys) / Double(selectedStats.count)
    }
    
    private var averageStudies: Double {
        let totalStudies = selectedStats.reduce(0) { $0 + $1.numberOfStudies }
        return selectedStats.isEmpty ? 0.0 : Double(totalStudies) / Double(selectedStats.count)
    }
    
    private var averageDuration: Double {
        let totalDuration = selectedStats.reduce(0) { $0 + $1.durationOfActivity }
        return selectedStats.isEmpty ? 0.0 : Double(totalDuration) / Double(selectedStats.count)
    }
    
    private var averageError: Double {
        let totalErrors = selectedStats.reduce(0) { $0 + $1.numberOfWrongAnswers }
        return selectedStats.isEmpty ? 0.0 : Double(totalErrors) / Double(selectedStats.count)
    }
    
    private var averagePercentageOfFirstTries: Double {
        let totalPercentage = selectedStats.reduce(0) { $0 + $1.percentageOfFirstTries }
        return selectedStats.isEmpty ? 0.0 : Double(totalPercentage) / Double(selectedStats.count)
    }
    
    private var averagePercentageOfWrongAnswers: Double {
        let totalPercentage = selectedStats.reduce(0) { $0 + $1.percentageOfAnswerPerCard }
        return selectedStats.isEmpty ? 0.0 : Double(totalPercentage) / Double(selectedStats.count)
    }
    
    private var averageNumberOfFirstTries: Double {
        let totalFirstTries = selectedStats.reduce(0) { $0 + $1.numberOfFirstTrys }
        return selectedStats.isEmpty ? 0.0 : Double(totalFirstTries) / Double(selectedStats.count)
    }
    
    var body: some View {
        let minXValue = selectedStats.map { $0.numberOfStudies }.min() ?? 1
        let maxRange = selectedStats.count
        
        List {
            VStack {
                Text("Nombre d'essais par étude")
                    .padding()
                
                Chart {
                    ForEach(selectedStats) { data in
                        LineMark(
                            x: .value("Nombre d'études", data.numberOfStudies),
                            y: .value("Nombre d'essais", data.numberOfTrys)
                        )
                        .symbol(.circle)
                        .foregroundStyle(.icon)
                        .interpolationMethod(.catmullRom)
                        
                        AreaMark(
                            x: .value("Nombre d'études", data.numberOfStudies),
                            y: .value("Nombre d'essais", data.numberOfTrys)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(areaBackground)
                    }
                    
                    RuleMark(y: .value("Moyenne des essais", averageTrys))
                        .foregroundStyle(.orange.opacity(0.5))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                    
                    if let currentStudy = currentStudy {
                        PointMark(
                            x: .value("Nombre d'études", currentStudy.numberOfStudies),
                            y: .value("Nombre d'essais", currentStudy.numberOfTrys)
                        )
                        .foregroundStyle(.orange)
                        .symbol(.circle)
                        .annotation {
                            Text("\(currentStudy.numberOfTrys)")
                                .background(.orange)
                                .foregroundStyle(.icon)
                                .clipShape(.buttonBorder)
                        }
                    }
                }
                .chartXScale(domain: minXValue...maxRange)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .frame(height: 300)
                .padding()
                .chartOverlay { proxy in
                    GeometryReader { geometry in
                        Rectangle().fill(.clear).contentShape(Rectangle())
                            .gesture(DragGesture().onChanged { value in
                                updateCursorPosition(at: value.location, geometry: geometry, proxy: proxy)
                            })
                            .onTapGesture { location in
                                updateCursorPosition(at: location, geometry: geometry, proxy: proxy)
                            }
                    }
                }
                
                Divider()
                
                Text("Durée d'étude par révision")
                    .padding()
                
                Chart(selectedStats) { data in
                    RuleMark(y: .value("Temps moyen d'étude", averageDuration))
                        .foregroundStyle(.orange.opacity(0.5))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                    
                    LineMark(
                        x: .value("Nombre d'études", data.numberOfStudies),
                        y: .value("Temps d'étude", data.durationOfActivity)
                    )
                    .symbol(.circle)
                    .foregroundStyle(.icon)
                    .interpolationMethod(.catmullRom)
                    
                    AreaMark(
                        x: .value("Nombre d'études", data.numberOfStudies),
                        y: .value("Temps d'étude", data.durationOfActivity)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(areaBackground)
                    
                    if let currentStudy = currentStudy {
                        PointMark(
                            x: .value("Nombre d'études", currentStudy.numberOfStudies),
                            y: .value("Temps d'étude", currentStudy.durationOfActivity)
                        )
                        .foregroundStyle(.orange)
                        .symbol(.circle)
                        .annotation {
                            Text("\(Int(currentStudy.durationOfActivity))s")
                                .background(.orange)
                                .foregroundStyle(.icon)
                                .clipShape(.buttonBorder)
                        }
                    }
                }
                .chartXScale(domain: minXValue...maxRange)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .frame(height: 300)
                .padding()
                .chartOverlay { proxy in
                    GeometryReader { geometry in
                        Rectangle().fill(.clear).contentShape(Rectangle())
                            .gesture(DragGesture().onChanged { value in
                                updateCursorPosition(at: value.location, geometry: geometry, proxy: proxy)
                            })
                            .onTapGesture { location in
                                updateCursorPosition(at: location, geometry: geometry, proxy: proxy)
                            }
                    }
                }
                
                Divider()
                
                Text("Nombre de premiers essais par étude")
                    .padding()
                    .multilineTextAlignment(.center)
                
                Chart(selectedStats) { data in
                    RuleMark(y: .value("Moyenne des premiers essais", averageNumberOfFirstTries))
                        .foregroundStyle(.orange.opacity(0.5))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                    
                    LineMark(
                        x: .value("Nombre d'études", data.numberOfStudies),
                        y: .value("Nombre de premiers essais", data.numberOfFirstTrys)
                    )
                    .symbol(.circle)
                    .foregroundStyle(.icon)
                    .interpolationMethod(.catmullRom)
                    
                    AreaMark(
                        x: .value("Nombre d'études", data.numberOfStudies),
                        y: .value("Nombre de premiers essais", data.numberOfFirstTrys)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(areaBackground)
                    
                    if let currentStudy = currentStudy {
                        PointMark(
                            x: .value("Nombre d'études", currentStudy.numberOfStudies),
                            y: .value("Nombre de premiers essais", currentStudy.numberOfFirstTrys)
                        )
                        .foregroundStyle(.orange)
                        .symbol(.circle)
                        .annotation {
                            Text("\(currentStudy.numberOfFirstTrys)")
                                .background(.orange)
                                .foregroundStyle(.icon)
                                .clipShape(.buttonBorder)
                        }
                    }
                }
                .chartXScale(domain: minXValue...maxRange)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .frame(height: 300)
                .padding()
                .chartOverlay { proxy in
                    GeometryReader { geometry in
                        Rectangle().fill(.clear).contentShape(Rectangle())
                            .gesture(DragGesture().onChanged { value in
                                updateCursorPosition(at: value.location, geometry: geometry, proxy: proxy)
                            })
                            .onTapGesture { location in
                                updateCursorPosition(at: location, geometry: geometry, proxy: proxy)
                            }
                    }
                }
                
                Divider()
                
                Text("Nombre d'erreurs par étude")
                    .padding()
                
                Chart(selectedStats) { data in
                    RuleMark(y: .value("Moyenne des erreurs", averageError))
                        .foregroundStyle(.orange.opacity(0.5))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                    
                    LineMark(
                        x: .value("Nombre d'études", data.numberOfStudies),
                        y: .value("Nombre d'erreurs", data.numberOfWrongAnswers)
                    )
                    .symbol(.circle)
                    .foregroundStyle(.icon)
                    .interpolationMethod(.catmullRom)
                    
                    AreaMark(
                        x: .value("Nombre d'études", data.numberOfStudies),
                        y: .value("Nombre d'erreurs", data.numberOfWrongAnswers)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(areaBackground)
                    
                    if let currentStudy = currentStudy {
                        PointMark(
                            x: .value("Nombre d'études", currentStudy.numberOfStudies),
                            y: .value("Nombre d'erreurs", currentStudy.numberOfWrongAnswers)
                        )
                        .foregroundStyle(.orange)
                        .symbol(.circle)
                        .annotation {
                            Text("\(Int(currentStudy.numberOfWrongAnswers))")
                                .background(.orange)
                                .foregroundStyle(.icon)
                                .clipShape(.buttonBorder)
                        }
                    }
                }
                .chartXScale(domain: minXValue...maxRange)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .frame(height: 300)
                .padding()
                .chartOverlay { proxy in
                    GeometryReader { geometry in
                        Rectangle().fill(.clear).contentShape(Rectangle())
                            .gesture(DragGesture().onChanged { value in
                                updateCursorPosition(at: value.location, geometry: geometry, proxy: proxy)
                            })
                            .onTapGesture { location in
                                updateCursorPosition(at: location, geometry: geometry, proxy: proxy)
                            }
                    }
                }
                
                Divider()
                
                Text("Pourcentage de premiers essais par étude")
                    .padding()
                    .multilineTextAlignment(.center)
                
                Chart(selectedStats) { data in
                    RuleMark(y: .value("Moyenne du pourcentage de premiers essais", averagePercentageOfFirstTries))
                        .foregroundStyle(.orange.opacity(0.5))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                    
                    LineMark(
                        x: .value("Nombre d'études", data.numberOfStudies),
                        y: .value("Pourcentage de premiers essais", data.percentageOfFirstTries)
                    )
                    .symbol(.circle)
                    .foregroundStyle(.icon)
                    .interpolationMethod(.catmullRom)
                    
                    AreaMark(
                        x: .value("Nombre d'études", data.numberOfStudies),
                        y: .value("Pourcentage de premiers essais", data.percentageOfFirstTries)
                    )
                    
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(areaBackground)
                   
                    
                    if let currentStudy = currentStudy {
                        PointMark(
                            x: .value("Nombre d'études", currentStudy.numberOfStudies),
                            y: .value("Pourcentage de premiers essais", currentStudy.percentageOfFirstTries)
                        )
                        .foregroundStyle(.orange)
                        .symbol(.circle)
                        .annotation {
                            Text("\(Int(currentStudy.percentageOfFirstTries))%")
                                .background(.orange)
                                .foregroundStyle(.icon)
                                .clipShape(.buttonBorder)
                        }
                    }
                }
                .chartXScale(domain: minXValue...maxRange)
                .chartYAxis {
                    AxisMarks(format: Decimal.FormatStyle.Percent.percent.scale(1), position: .leading)
                }
                .frame(height: 300)
                .padding()
                .chartOverlay { proxy in
                    GeometryReader { geometry in
                        Rectangle().fill(.clear).contentShape(Rectangle())
                            .gesture(DragGesture().onChanged { value in
                                updateCursorPosition(at: value.location, geometry: geometry, proxy: proxy)
                            })
                            .onTapGesture { location in
                                updateCursorPosition(at: location, geometry: geometry, proxy: proxy)
                            }
                    }
                }
                
                Divider()
                
                Text("Pourcentage d'erreurs par étude")
                    .padding()
                
                Chart(selectedStats) { data in
                    RuleMark(y: .value("Moyenne du Pourcentage d'erreurs", averagePercentageOfWrongAnswers))
                        .foregroundStyle(.orange.opacity(0.5))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                    
                    LineMark(
                        x: .value("Nombre d'études", data.numberOfStudies),
                        y: .value("Pourcentage d'erreurs", data.percentageOfAnswerPerCard)
                    )
                    .symbol(.circle)
                    .foregroundStyle(.icon)
                    .interpolationMethod(.catmullRom)
                    
                    AreaMark(
                        x: .value("Nombre d'études", data.numberOfStudies),
                        y: .value("Pourcentage d'erreurs", data.percentageOfAnswerPerCard)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(areaBackground)
                    
                    if let currentStudy = currentStudy {
                        PointMark(
                            x: .value("Nombre d'études", currentStudy.numberOfStudies),
                            y: .value("Pourcentage d'erreurs", currentStudy.percentageOfAnswerPerCard)
                        )
                        .foregroundStyle(.orange)
                        .symbol(.circle)
                        .annotation {
                            Text("\(Int(currentStudy.percentageOfAnswerPerCard))%")
                                .background(.orange)
                                .foregroundStyle(.icon)
                                .clipShape(.buttonBorder)
                        }
                    }
                }
                .chartXScale(domain: minXValue...maxRange)
                .chartYAxis {
                    AxisMarks(format: Decimal.FormatStyle.Percent.percent.scale(1), position: .leading)
                }
                .frame(height: 300)
                .padding()
                .chartOverlay { proxy in
                    GeometryReader { geometry in
                        Rectangle().fill(.clear).contentShape(Rectangle())
                            .gesture(DragGesture().onChanged { value in
                                updateCursorPosition(at: value.location, geometry: geometry, proxy: proxy)
                            })
                            .onTapGesture { location in
                                updateCursorPosition(at: location, geometry: geometry, proxy: proxy)
                            }
                    }
                }
            }
        }
    }
    
    private func updateCursorPosition(at location: CGPoint, geometry: GeometryProxy, proxy: ChartProxy) {
        let origin = geometry[proxy.plotFrame!].origin
        let studiesPos = proxy.value(atX: location.x - origin.x, as: Int.self) ?? 0
        
        currentStudy = selectedStats.min { abs($0.numberOfStudies - studiesPos) < abs($1.numberOfStudies - studiesPos) }
    }
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        let vocabularyList = VocabularyList(id: UUID(), name: "Exemple de Liste", words: [
            VocabularyWord(name: "Bonjour", translation: "Hello"),
            VocabularyWord(name: "Merci", translation: "Thank you")
        ], isStudyWriting: false, isStudySwipeCards: true, isStudyButtonCard: false)

        let activityStats = [ActivityStats(
            vocabularyList: vocabularyList,
            vocabularyListId: vocabularyList.id,
            durationOfActivity: 2,
            studiedWordsCount: 1,
            numberOfWrongAnswers: 3,
            numberOfTrys: 10,
            numberOfFirstTrys: 1,
            numberOfStudies: 1,
            date: Date(),
            durationOfActivityPerCard: 2,
            percentageOfFirstTries: 100,
            percentageOfAnswerPerCard: 8
        ), ActivityStats(
            vocabularyList: vocabularyList,
            vocabularyListId: vocabularyList.id,
            durationOfActivity: 20,
            studiedWordsCount: 1,
            numberOfWrongAnswers: 3,
            numberOfTrys: 1,
            numberOfFirstTrys: 1,
            numberOfStudies: 2,
            date: Date(),
            durationOfActivityPerCard: 2,
            percentageOfFirstTries: 8,
            percentageOfAnswerPerCard: 100
        )]

        let dataStore = DataStore()
        dataStore.activityStats = activityStats

        return StatsGraphView(
            activityStats: activityStats,
            vocabularyList: vocabularyList
        )
        .environmentObject(dataStore)
    }
}

