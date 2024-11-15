//
//  ViewController.swift
//  CalorieCalculation
//
//  Created by Irina Muravyeva on 12.11.2024.
//

import UIKit

class ViewController: UIViewController {

    var profiles: [Profile]!
    let deficitCalorie = 0.2 // 20%
    let overageCalorie = 0.2 // 20%
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profiles = StorageManager.shared.fetchProfiles()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if profiles.count == 0 {
            performSegue(withIdentifier: "greeting", sender: self)
        }
    }
}

// MARK: - Calculation according to the Harris-Benedict formula
extension ViewController {
    
    // Функция для расчёта BMR по формуле Харриса-Бенедикта
    func calculateBMR(weight: Double, height: Double, age: Int, sex: Sex) -> Double {
        if sex == Sex.male {
            // Для мужчин
            return 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * Double(age))
        } else {
            // Для женщин
            return 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * Double(age))
        }
    }

    // Функция для расчёта суточной нормы калорий (TDEE)
    func calculateTDEE(bmr: Double, activityLevel: Double) -> Double {
        return bmr * activityLevel
    }
    
    // Функция для расчёта суточной нормы калорий для достижения выбранной цели
    func calculateTDEEForGoal(tdee: Double, goal: Goals) -> Double {
        switch goal {
        case .weightLoss:
            return tdee * ( 1 - deficitCalorie)
        case .weightGain:
            return tdee * (1 + overageCalorie)
        default:
            return tdee
        }
    }
    
    func calculateNutritionalNeeds(weight: Double, calorieNeedsForGoal: Double) -> (protein: Double, fat: Double, carbs: Double) {
 
        // Распределение макронутриентов:
        let proteinCalories = weight * 2.0 * 4.0 // 2 г белка на кг массы тела, 1 г белка = 4 ккал
        let fatCalories = weight * 1.0 * 9.0   // 1 г жира на кг массы тела, 1 г жира = 9 ккал
        
        // Углеводы — оставшиеся калории
        let carbsCalories = calorieNeedsForGoal - proteinCalories - fatCalories
        
        // Преобразуем углеводы в граммы
        let carbsGrams = carbsCalories / 4.0 // 1 г углеводов = 4 ккал
        
        return (protein: proteinCalories / 4.0, fat: fatCalories / 9.0, carbs: carbsGrams)
    }

}
