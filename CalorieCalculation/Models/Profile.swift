//
//  Profile.swift
//  CalorieCalculation
//
//  Created by Irina Muravyeva on 12.11.2024.
//

import Foundation

struct Profile: Codable {
    var nickname: String
    var icon: String
    var age: Int?
    var sex: Sex?
    var height: Double?
    var weight: Double?
    var activityLevel: ActivityLevel?
    var goal: Goals?
    var caloriesBMT: Double?
    var caloriesTDEEForGoal: Double?
}

enum Sex: Codable {
    case male
    case female
}

enum Goals: String, Codable, CaseIterable {
    case weightLoss = "weight_loss" // "Снижение веса"
    case savingWeight = "maintenance" // "Поддержание веса"
    case weightGain = "muscle_gain" // "Набор веса"

    var localized: String {
            return NSLocalizedString(self.rawValue, comment: "")
        }
}

enum ActivityLevel: String, Codable, CaseIterable {
    case sedentary = "no_activity" // "<5000 шагов, тренировки отсутствуют" // Сидячий, малоподвижный ()
    case lightActivity = "low_activity" // "7-9 тыс. шагов + 2-3 тренировки в неделю" // Легкая активность ()
    case normalActivity = "normal_activity" // "10-15 тыс. шагов + 3-4 тренировки в неделю" // Средняя активность ()
    case highActivity = "high_activity" // "5-7 тренировок в неделю" // Высокая активность ()
    case extremalActivity = "extremal_activity" // "Работники тяжёлого физического труда"
    
    var value: Double {
        switch self {
        case .sedentary: return 1.2
        case .lightActivity: return 1.375
        case .normalActivity: return 1.55
        case .highActivity: return 1.725
        case .extremalActivity: return 1.9
        }
    }
    
    var localized: String {
            return NSLocalizedString(self.rawValue, comment: "")
        }
    
    var description: String {
        return self.rawValue
    }
}
