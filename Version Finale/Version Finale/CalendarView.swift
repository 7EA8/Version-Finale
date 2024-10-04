//
//  CalendarView.swift
//  Version Finale
//
//  Created by Tiago Alves on 29.07.2024.
//

import SwiftUI


struct CalendarView: View {
    @ObservedObject var vocabularyList: VocabularyList
    @State private var color: Color = .icon
    @State private var date = Date.now
    let daysOfWeek = Date.capitalizedFirstLettersOfWeekdays
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    @State private var days: [Date] = []
    @State private var selectedDate: Date?
    @EnvironmentObject var dataStore: DataStore
    @EnvironmentObject var lnManager: LocalNotificationManager
    @Environment(\.scenePhase) var scenePhase
    @State private var isShowingNoDateError = false
    @State private var isShowingPastDateError = false
    @State  private var isAnimating = false
    @State private var isShowingNotificationView = false
    @Binding var isShowingCalendar: Bool
    @State private var attempts = 0
    
    var combined: Date?{
        let timeComponents: DateComponents = Calendar.current.dateComponents([.hour,.minute,.second,.timeZone], from: date)
        let dateComponents: DateComponents = Calendar.current.dateComponents([.year,.month,.day], from: selectedDate!)
        let combined: DateComponents = .init(calendar: .current, timeZone: timeComponents.timeZone, year: dateComponents.year, month: dateComponents.month, day: dateComponents.day, hour: timeComponents.hour, minute: timeComponents.minute, second: timeComponents.second)
        return Calendar.current.date(from: combined) ?? Date()
    }
    
    var body: some View {
        VStack {
            HStack{
                Button("Annuler"){
                    isShowingCalendar = false
                }
                Spacer()
                Button("Choisir") {
                    if selectedDate != nil{
                        if let combined = combined {
                            dataStore.updateDateForVocabularyList(vocabularyList: vocabularyList, newDate: combined)
                            isShowingCalendar = false
                            isShowingNoDateError = false
                            isShowingPastDateError = false
                            Task {
                                lnManager.removeAllRequests(forCategory: "lastDayCategory_\(vocabularyList.name)")
                                lnManager.removeAllRequests(forCategory: "dailyCategory_\(vocabularyList.name)")
                                let localNotification = LocalNotification(
                                    identifier: vocabularyList.name,
                                    title: "Notification quotidienne \(vocabularyList.name)",
                                    bodyGenerator: {
                                        quotes.randomElement() ?? "N'oubliez pas de venir travailler"
                                    },
                                    dateComponents: Calendar.current.dateComponents([.hour, .minute], from: vocabularyList.date),
                                    repeats: true,
                                    endDate: vocabularyList.date,
                                    startDate: Date.now, 
                                    category: "dailyCategory_\(vocabularyList.name)"
                                )
                                let DayNotification = LocalNotification(
                                    identifier: vocabularyList.name,
                                    title: "Dernière notification de la liste \(vocabularyList.name)",
                                    bodyGenerator: {"Bonne chance pour votre dernier jour de travail de la liste \(vocabularyList.name)"},
                                    dateComponents: Calendar.current.dateComponents([.hour, .minute], from: vocabularyList.date),
                                    repeats: false,
                                    endDate: vocabularyList.date,
                                    startDate: Date.now, 
                                    category: "lastDayCategory_\(vocabularyList.name)"
                                )
                                await lnManager.schedule(localNotification: localNotification)
                                await lnManager.lastDay(localNotification: DayNotification)
                            }
                            
                            
                        }
                    }else {
                        isShowingNoDateError = true
                        isShowingPastDateError = false
                        withAnimation(.default) {
                            self.attempts += 1
                        }
                        
                        
                    }
                }
            }
                .padding(.top,20)
            VStack{
                Text("Choisir une date de fin")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top)
                    .foregroundStyle(color)
                Text("N'oubliez pas de choisir l'heure des notifications!")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .frame(height: 20)
                    .padding(.bottom,30)
                
            }
            LabeledContent("Couleur du calendrier") {
                ColorPicker("", selection: $color, supportsOpacity: false)
            }
            LabeledContent("Date/Heure") {
                DatePicker("", selection: $date)
                    .environment(\.locale, Locale.init(identifier: "fr"))
            }
            HStack {
                ForEach(daysOfWeek.indices, id: \.self) { index in
                    Text(daysOfWeek[index])
                        .fontWeight(.black)
                        .foregroundStyle(color)
                        .frame(maxWidth: .infinity)
                }
            }
            LazyVGrid(columns: columns) {
                ForEach(days, id: \.self) { day in
                    if day.monthInt != date.monthInt {
                        Text("")
                    } else {
                        Button(action: {
                            // Ensure the selected date is in the future
                            let now = Date.now.startOfDay
                            if day >= now.addingTimeInterval(24 * 60 * 60) {
                                selectedDate = day
                                isShowingPastDateError = false
                            } else {
                                isShowingPastDateError = true
                                isShowingNoDateError = false
                                withAnimation(.default) {
                                    self.attempts += 1
                                }
                                
                            }
                        }) {
                            Text(day.formatted(.dateTime.day()))
                                .fontWeight(.bold)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, minHeight: 40)
                                .background(
                                    Circle()
                                        .foregroundStyle(
                                            selectedDate?.startOfDay == day.startOfDay ? color.opacity(0.6) :
                                                    .now == day.startOfDay ? .red.opacity(0.3) :
                                                color.opacity(0.3)
                                        )
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            VStack{
                if !lnManager.isGranted{
                    Button("Activer les notifications") {
                        lnManager.openSettings()
                    }.buttonStyle(.bordered)
                }else{
                    Button("Gérez vos notifications"){
                        isShowingNotificationView = true
                    }
                }
                HStack{
                    Text("Date précedement choisie:")
                    Text(vocabularyList.date,format:.dateTime.day().month().year().hour().minute())
                }
                .font(.caption)
                .environment(\.locale, Locale(identifier: "fr"))
                .padding(.top,20)
                .padding(.bottom,20)
                
                if selectedDate != nil{
                    HStack{
                        Text("Date actuellement choisie:")
                        Text(selectedDate!,format:.dateTime.day().month().year())
                        Text(date, format:.dateTime.hour().minute())
                    }.padding(.bottom,20)
                        .environment(\.locale, Locale(identifier: "fr"))
                        .foregroundStyle(color)
                        .scaledToFit()
                        .font(.caption)
                }
                if isShowingNoDateError && selectedDate == nil {
                    Text("Pas de date séléctionnée")
                        .foregroundStyle(.red)
                        .modifier(Shake(animatableData: CGFloat(attempts)))
                }
                if isShowingPastDateError{
                    Text("La date choisie est dans le passé")
                        .foregroundStyle(.red)
                        .modifier(Shake(animatableData: CGFloat(attempts)))
                    
                }
                
                Spacer()
            }.sheet(isPresented: $isShowingNotificationView){
                NotificationView(vocabularyList: vocabularyList)
            }
            .padding()
            .onAppear {
                days = date.calendarDisplayDays
            }
            
            .onChange(of: date) {
                days = date.calendarDisplayDays
            }
            .onChange(of: scenePhase) { newValue,_ in
                if newValue == .active {
                    Task {
                        await lnManager.getCurrentSettings()
                        await lnManager.getPendingRequests()
                    }
                }
            }
        }
    }
}
extension Date {
    static var firstDayOfWeek = Calendar.current.firstWeekday
    static var capitalizedFirstLettersOfWeekdays: [String] {
        var calendar = Calendar.current
        calendar.locale = NSLocale(localeIdentifier: "fr_FR") as Locale
        var weekdays = calendar.shortWeekdaySymbols
        if firstDayOfWeek > 1 {
            for _ in 1..<firstDayOfWeek {
                if let first = weekdays.first {
                    weekdays.append(first)
                    weekdays.removeFirst()
                }
            }
        }
        return weekdays.map { $0.capitalized }
    }

    var startOfMonth: Date {
        Calendar.current.dateInterval(of: .month, for: self)!.start
    }

    var endOfMonth: Date {
        let lastDay = Calendar.current.dateInterval(of: .month, for: self)!.end
        return Calendar.current.date(byAdding: .day, value: -1, to: lastDay)!
    }

    var startOfPreviousMonth: Date {
        let dayInPreviousMonth = Calendar.current.date(byAdding: .month, value: -1, to: self)!
        return dayInPreviousMonth.startOfMonth
    }

    var numberOfDaysInMonth: Int {
        Calendar.current.component(.day, from: endOfMonth)
    }

    var firstWeekDayBeforeStart: Date {
        let startOfMonthWeekday = Calendar.current.component(.weekday, from: startOfMonth)
        var numberFromPreviousMonth = startOfMonthWeekday - Self.firstDayOfWeek
        if numberFromPreviousMonth < 0 {
            numberFromPreviousMonth += 7
        }
        return Calendar.current.date(byAdding: .day, value: -numberFromPreviousMonth, to: startOfMonth)!
    }

    var calendarDisplayDays: [Date] {
        var days: [Date] = []
        let firstDisplayDay = firstWeekDayBeforeStart
        var day = firstDisplayDay
        while day < startOfMonth {
            days.append(day)
            day = Calendar.current.date(byAdding: .day, value: 1, to: day)!
        }
        for dayOffset in 0..<numberOfDaysInMonth {
            let newDay = Calendar.current.date(byAdding: .day, value: dayOffset, to: startOfMonth)
            days.append(newDay!)
        }
        return days
    }

    var yearInt: Int {
        Calendar.current.component(.year, from: self)
    }

    var monthInt: Int {
        Calendar.current.component(.month, from: self)
    }

    var dayInt: Int {
        Calendar.current.component(.day, from: self)
    }

    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
}
