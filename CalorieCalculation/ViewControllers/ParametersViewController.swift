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
    var activeTextField: UITextField?
    
    var activityLevelPickerView = UIPickerView()
    var goalPickerView = UIPickerView()
    var selectedActivityLevel: ActivityLevel?
    var selectedGoal: Goals?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        maleButton.addTarget(self, action: #selector(sexDidChoose(_:)), for: .touchUpInside)
        femaleButton.addTarget(self, action: #selector(sexDidChoose(_:)), for: .touchUpInside)
        
        setupPickerView(activityLevelPickerView, tag: 1)
        setupPickerView(goalPickerView, tag: 2)
        activityLevelTextField.inputView = activityLevelPickerView
        goalTextField.inputView = goalPickerView
        
        // Добавляем распознаватель жестов для скрытия клавиатуры по нажатию на экран
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPicker))
        view.addGestureRecognizer(tapGesture)
        
        // Добавляем кнопку "OK" на панели инструментов
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "OK", style: .done, target: self, action: #selector(doneButtonTapped))
        toolbar.setItems([doneButton], animated: true)
        
        ageTextField.inputAccessoryView = toolbar
        heightTextField.inputAccessoryView = toolbar
        weighTextField.inputAccessoryView = toolbar

    }
    
    @IBAction func createProfileButtonTapped(_ sender: UIButton) {
        guard let age = ageTextField.text,
            let height = heightTextField.text,
            let weight = weighTextField.text,
            let activityLevel = selectedActivityLevel ,
            let goal = selectedGoal else { return }
        guard let age = Int(age), 
            let height = Double(height),
            let weight = Double(weight) else { return }
        guard let selectedSex = selectedSex else { return }
        
        let sex: Sex = selectedSex == maleButton ? .male : .female
        
        StorageManager.shared.add(newProfile:
            Profile(
                person: person,
                icon: icon,
                age: age,
                sex: sex,
                height: height,
                weight: weight,
                activityLevel: activityLevel,
                goal: goal,
                caloriesBMT: nil,
                caloriesTDEEForGoal: nil
            )
        )
        
        let profiles = StorageManager.shared.fetchProfiles()
        if let currentProfile = profiles.first(where: {$0.person == person}) {
            StorageManager.shared.saveIndexOf(activeProfile: currentProfile)
        }
        
        // возвращаюсь к главному VC
        view.window?.rootViewController?.dismiss(animated: true) {
            if let navigationController = self.view.window?.rootViewController as? UINavigationController {
                navigationController.popToRootViewController(animated: true)
            }
        }
    }
    
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
    
    func setupPickerView(_ pickerView: UIPickerView, tag: Int) {
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.tag = tag
    }
        
    @objc func dismissPicker() {
        view.endEditing(true) // Скрывает клавиатуру и PickerView
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    @objc func doneButtonTapped() {
        // Скрываем клавиатуру
        activeTextField?.resignFirstResponder()
    }
    
    // Функция для показа предупреждения
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UIPickerViewDataSource,UIPickerViewDelegate
extension ParametersViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    // UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            return ActivityLevel.allCases.count
        } else if pickerView.tag == 2 {
            return Goals.allCases.count
        }
        return 0
    }
    
    // UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            return ActivityLevel.allCases[row].description
        } else if pickerView.tag == 2 {
            return Goals.allCases[row].rawValue
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 {
            activityLevelTextField?.text = ActivityLevel.allCases[row].rawValue
            selectedActivityLevel = ActivityLevel.allCases[row]
        } else if pickerView.tag == 2 {
            goalTextField.text = Goals.allCases[row].rawValue
            selectedGoal = Goals.allCases[row]
        }
    }
}
