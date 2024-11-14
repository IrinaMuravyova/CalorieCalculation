//
//  ParametersViewController.swift
//  CalorieCalculation
//
//  Created by Irina Muravyeva on 14.11.2024.
//

import UIKit

class ParametersViewController: UIViewController {
    
    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var weighTextField: UITextField!
    @IBOutlet weak var activityLevelTextField: UITextField!
    @IBOutlet weak var goalTextField: UITextField!
    
    var person: String!
    var icon: String!
    var selectedSex: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        maleButton.addTarget(self, action: #selector(sexDidChoose(_:)), for: .touchUpInside)
        femaleButton.addTarget(self, action: #selector(sexDidChoose(_:)), for: .touchUpInside)
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    @objc func sexDidChoose(_ sender: UIButton) {

        let selectedButtonImage = UIImage(systemName: "circle.circle.fill")
        let defaultButtonImage = UIImage(systemName: "circle")

        if selectedSex == sender {
            // Если та же кнопка нажата снова, убираем картинку
            sender.setImage(defaultButtonImage, for: .normal)
            selectedSex = nil // Сбрасываем выбранную кнопку
        } else {
            // Если другая кнопка была выбрана ранее, сбрасываем ее
            selectedSex?.setImage(defaultButtonImage, for: .normal)

            // Устанавливаем картинку на текущую кнопку
            sender.setImage(selectedButtonImage, for: .normal)
            selectedSex = sender // Обновляем выбранную кнопку
        }
    }
}
