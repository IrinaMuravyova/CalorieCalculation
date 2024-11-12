//
//  Profile.swift
//  CalorieCalculation
//
//  Created by Irina Muravyeva on 12.11.2024.
//

struct Profile {
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

enum Sex {
    case male
    case female
}

enum Goals {
    case weightLoss
    case savingWeight
    case weightGain
}
enum ActivityLevel: Double {
    case sedentary = 1.2
    case lightActivity = 1.375
    case normalActivity = 1.55
    case highActivity = 1.725
    case extremalActivity = 1.9
}
