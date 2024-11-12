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

enum Goals: Codable {
    case weightLoss
    case savingWeight
    case weightGain
}
enum ActivityLevel: Double, Codable {
    case sedentary = 1.2
    case lightActivity = 1.375
    case normalActivity = 1.55
    case highActivity = 1.725
    case extremalActivity = 1.9
}
