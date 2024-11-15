//
//  Profile.swift
//  CalorieCalculation
//
//  Created by Irina Muravyeva on 12.11.2024.
//

import Foundation

struct Profile: Codable {
    let person: String
    let icon: String
    let age: Int
    let sex: Sex
    let height: Double
    let weight: Double
    let activityLevel: ActivityLevel
    let goal: Goals
    let caloriesBMT: Int?
    let caloriesTDEEForGoal: [ActivityLevel: Int]?
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
    case sedentary = "Сидячий, малоподвижный"
    case lightActivity = "1-3 тренировки в неделю"
    case normalActivity = "3-5 тренировок в неделю"
    case highActivity = "5-7 тренировок в неделю или тяжелая физическая работа"
    case extremalActivity = "7 раз в неделю высокие спортивные нагрузки"
    
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
