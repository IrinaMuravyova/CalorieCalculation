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
    case weightLoss = "Снижение веса"
    case savingWeight = "Поддержание веса"
    case weightGain = "Набор веса"
}

enum ActivityLevel: String, Codable, CaseIterable {
    case sedentary = "<5000 шагов, тренировки отсутствуют" // Сидячий, малоподвижный ()
    case lightActivity = "7-9 тыс. шагов + 2-3 тренировки в неделю" // Легкая активность ()
    case normalActivity = "10-15 тыс. шагов + 3-4 тренировки в неделю" // Средняя активность ()
    case highActivity = "5-7 тренировок в неделю" // Высокая активность ()
    case extremalActivity = "Работники тяжёлого физического труда"
    
    var value: Double {
        switch self {
        case .sedentary: return 1.2
        case .lightActivity: return 1.375
        case .normalActivity: return 1.55
        case .highActivity: return 1.725
        case .extremalActivity: return 1.9
        }
    }
    
    var description: String {
        return self.rawValue
    }
}
