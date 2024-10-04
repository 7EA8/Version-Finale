//
//  LocalNotification.swift
//  Version Finale
//
//  Created by Tiago Alves on 30.07.2024.
//

import Foundation

struct LocalNotification {
    internal init(identifier: String, 
                  title: String,
                  bodyGenerator: @escaping () -> String,
                  timeInterval: Double,
                  repeats: Bool,
                  endDate: Date,
                  startDate: Date,
                  category: String) {
        self.identifier = identifier
        self.scheduleType = .time
        self.title = title
        self.bodyGenerator = bodyGenerator
        self.timeInterval = timeInterval
        self.dateComponents = nil
        self.repeats = repeats
        self.endDate = endDate
        self.startDate = Date.now
        self.category = category
    }
    internal init(identifier: String,
                  title: String,
                  bodyGenerator: @escaping () -> String,
                  dateComponents: DateComponents,
                  repeats: Bool,
                  endDate: Date,
                  startDate: Date,
                  category:String) {
        self.identifier = identifier
        self.scheduleType = .calendar
        self.title = title
        self.bodyGenerator = bodyGenerator
        self.timeInterval = nil
        self.dateComponents = dateComponents
        self.repeats = repeats
        self.endDate = endDate
        self.startDate = Date.now
        self.category = category
    }
    
    enum ScheduleType {
        case time,calendar
    }
    
    var scheduleType: ScheduleType
    var identifier : String
    var title : String
    var bodyGenerator: () -> String
    var timeInterval: Double?
    var dateComponents: DateComponents?
    var repeats: Bool
    var endDate: Date?
    var startDate: Date?
    var category: String
}
