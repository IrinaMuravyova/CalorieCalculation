//
//  ViewController.swift
//  CalorieCalculation
//
//  Created by Irina Muravyeva on 12.11.2024.
//

import UIKit

class ViewController: UIViewController {

    var profiles: [Profile]!
    var profile: Profile! // activeUser
    let deficitCalorie = 0.2 // 20%
    let overageCalorie = 0.2 // 20%
    
    // profile's parameters for calculate B-H formula
    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var activityLevelTextField: UITextField!
    @IBOutlet weak var goalTextField: UITextField!
    
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var proteinLabel: UILabel!
    @IBOutlet weak var fatLabel: UILabel!
    @IBOutlet weak var carbLabel: UILabel!
    
    @IBOutlet weak var titleForParametersLabel: UILabel!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var resultStackView: UIStackView!
    @IBOutlet weak var settingsStackView: UIStackView!
    @IBOutlet weak var questionButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var profileButton: UIButton!
    
    var activeTextField: UITextField?
    var activityLevelPickerView = UIPickerView()
    var goalPickerView = UIPickerView()
    var selectedActivityLevel: ActivityLevel?
    var selectedGoal: Goals?
    var selectedSex: UIButton?
    

    private var isMenuOpen = false // Флаг для отображения меню
    private let menuWidth: CGFloat = 300 // Ширина бокового меню
    private let menuContainerView = UIView() // Контейнер для меню
    private let dimmingView = UIView() // Затемняющий фон для интерактивности

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        StorageManager.shared.deleteProfile(at: 0) // для тестирования
        profiles = StorageManager.shared.fetchProfiles()
        profile = StorageManager.shared.fetchActiveProfile()
//        print(profiles!)
//        print(profile!)
        
        configuring(button: profileButton, withImage: UIImage(named: profile.icon) )
        configuring(button: settingsButton, withImage: UIImage(systemName: "gear"))
        configuring(button: questionButton, withImage: UIImage(systemName: "questionmark.circle"))
        
        if profile.age == nil { //TODO: change verify
            titleForParametersLabel.text = "Добавим подробностей:"
//            editButton.isHidden = true
            editButton.style = .done
            editButton.title = "OK"
        
            resultStackView.isHidden = true
        } else {
            fillFields(for: profile)
        }
        
        maleButton.addTarget(self, action: #selector(sexDidChoose(_:)), for: .touchUpInside)
        femaleButton.addTarget(self, action: #selector(sexDidChoose(_:)), for: .touchUpInside)
        
        setupPickerView(activityLevelPickerView, tag: 1)
        setupPickerView(goalPickerView, tag: 2)
        activityLevelTextField.inputView = activityLevelPickerView
        goalTextField.inputView = goalPickerView
        
        // Добавляем распознаватель жестов для скрытия клавиатуры по нажатию на экран
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPicker))
        view.addGestureRecognizer(tapGesture)
        let tapGestureForMenu = UITapGestureRecognizer(target: self, action: #selector(hideMenu))
        dimmingView.addGestureRecognizer(tapGestureForMenu)
        
        // Создаем распознаватель долгого нажатия
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.5 // Время, после которого считается длительное нажатие (в секундах)
        
        // Добавляем распознаватель к кнопке
        profileButton.addGestureRecognizer(longPressGesture)
        
        // Добавляем кнопку "OK" на панели инструментов
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "OK", style: .done, target: self, action: #selector(doneButtonTapped))
        toolbar.setItems([doneButton], animated: true)
        
        ageTextField.inputAccessoryView = toolbar
        heightTextField.inputAccessoryView = toolbar
        weightTextField.inputAccessoryView = toolbar
        
        sideMenuConfigure()
        
        // Добавляем свайп-жест
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(hideMenu))
        swipeGesture.direction = .left
        self.view.addGestureRecognizer(swipeGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        profiles = StorageManager.shared.fetchProfiles()
        
        if profiles == nil || profiles.isEmpty || profile == nil {
            performSegue(withIdentifier: "greetingSegue", sender: self)
        }
    }
    
    @IBAction func editBarButtonTapped(_ sender: UIBarButtonItem) {
        if sender.style == .plain {
            // Переход в режим редактирования
            sender.style = .done
            sender.title = "ОК" //Done
            enableEditingMode()
            } else {
                if checkFilling() {
                    // Завершение редактирования
                    sender.style = .plain
                    sender.title = "Правка" //Edit
                    disableEditingMode()
                }
            }
    }
    
    @IBAction func settingsButtonTapped(_ sender: UIButton) {
        
        isMenuOpen.toggle()
        editButton.isEnabled = false
        UIView.animate(withDuration: 0.3) {
            self.menuContainerView.frame.origin.x = self.isMenuOpen ? 0 : -self.menuWidth
            self.dimmingView.alpha = self.isMenuOpen ? 1 : 0
            self.view.layoutIfNeeded()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "greetingSegue" { // Убедитесь, что идентификатор совпадает
            if let greetingVC = segue.destination as? GreetingViewController {
                greetingVC.delegate = self
            }
        }
    }
}

//MARK: - Setup methods
extension ViewController {
    func configuring(button: UIButton, withImage: UIImage!) {
        let resizedImage = resizeImage(image: withImage, targetSize: CGSize(width: 50, height: 50))
            
        // Настраиваем конфигурацию
        var configuration = UIButton.Configuration.plain()
        configuration.image = resizedImage
        configuration.imagePlacement = .leading
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(scale: .large)

        // Применяем конфигурацию
        button.configuration = configuration
        let withImage = withImage
        
        func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
            let renderer = UIGraphicsImageRenderer(size: targetSize)
            return renderer.image { _ in
                image.draw(in: CGRect(origin: .zero, size: targetSize))
            }
        }
        
        if let originalImage = withImage {
            let resizedImage = resizeImage(image: originalImage, targetSize: CGSize(width: 50, height: 50))
            configuration.image = resizedImage
        }
    }
    
    func fillFields(for profile: Profile) {
        fillSettings(for: profile)
        fillNutritions(for: profile)
        
        settingsFieldsAvailableToggle()
        
        selectedSex = profile.sex == .female ? femaleButton : maleButton
        selectedActivityLevel = profile.activityLevel
        selectedGoal = profile.goal
    }
    
    func fillSettings(for profile: Profile) {
        
        if profile.sex == .male {
            maleButton.setImage(UIImage(systemName: "circle.circle.fill"), for: .normal)
        } else {
            femaleButton.setImage(UIImage(systemName: "circle.circle.fill"), for: .normal)
        }
        guard
            let age = profile.age,
            let height = profile.height,
            let weight = profile.weight,
            let activityLevel = profile.activityLevel?.rawValue,
            let goal = profile.goal?.rawValue
        else { return }
        
        ageTextField.text = age.formatted()
        heightTextField.text = height.formatted()
        weightTextField.text = weight.formatted()
        activityLevelTextField.text = activityLevel
        goalTextField.text = goal
        
    }
    
    func fillNutritions(for profile: Profile){
        
        guard
            let sex = profile.sex,
            let age = profile.age,
            let height = profile.height,
            let weight = profile.weight,
            let activityLevel = profile.activityLevel?.value,
            let goal = profile.goal
        else { return }
        
        let bmt = calculateBMR(weight: weight, height: height, age: age, sex: sex)
        let caloriesTDEE = calculateTDEE(bmr: bmt, activityLevel: activityLevel)
        let caloriesTDEEForGoal = calculateTDEEForGoal(tdee: caloriesTDEE, goal: goal)
        let nutritional = calculateNutritionalNeeds(weight: weight, calorieNeedsForGoal: caloriesTDEEForGoal)
        
        caloriesLabel.text = String(format: "%.0f", caloriesTDEEForGoal)
        proteinLabel.text = String(format: "%.0f", nutritional.protein)
        fatLabel.text = String(format: "%.0f", nutritional.fat)
        carbLabel.text = String(format: "%.0f", nutritional.carbs)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    @objc func doneButtonTapped() {
        // Скрываем клавиатуру
        activeTextField?.resignFirstResponder()
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
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        // Проверяем состояние распознавателя
        if gesture.state == .began {
            print("Long press began")
            // Добавить код, который выполняется при начале длительного нажатия
        }
    }
    
    func checkFilling() -> Bool {
//        let defaultButtonImage = UIImage(systemName: "circle")
//        if maleButton.imageView?.image == defaultButtonImage && femaleBuvtton.imageView?.image == defaultButtonImage
        if selectedSex == nil {
            showAlert(message: "Нужно указать пол: женский или мужской")
            return false
        }
        
        guard let age = ageTextField.text else {
            showAlert(message: "Нужно указать свой возраст в годах")
            return false
        }
        if Int(age) == nil {
            showAlert(message: "Возраст указан некорректно. Укажи количество лет.")
            return false
        }
        
        guard let height = heightTextField.text else {
            showAlert(message: "Нужно указать свой рост в сантиметрах")
            return false
        }
        if Int(height) == nil {
            showAlert(message: "Рост указан некорректно. Укажи свой рост в сантиметрах.")
            return false
        }
        
        
        guard let weight = weightTextField.text else {
            showAlert(message: "Нужно указать свой вес в килограммах")
            return false
        }
        if Int(weight) == nil {
            showAlert(message: "Вес указан некорректно. Укажи свой вес в сантиметрах.")
            return false
        }
        
        if selectedActivityLevel == nil {
            showAlert(message: "Нужно указать уровень активности")
            return false
        }
        if selectedGoal == nil {
            showAlert(message: "Нужно указать свою цель")
            return false
        }
        return true
    }
    
    func enableEditingMode() {
        settingsFieldsAvailableToggle()
        settingsStackView.alpha = 1
        resultStackView.alpha = 0.6
    }
    
    func disableEditingMode() {
        settingsFieldsAvailableToggle()
        settingsStackView.alpha = 0.6
        resultStackView.alpha = 1
        
        calculateResult()
        
        StorageManager.shared.save(changedProfile: profile)
        StorageManager.shared.set(activeProfile: profile)

        showResults(for: profile)
    }
    
    func calculateResult() {
        guard let age = ageTextField.text,
            let height = heightTextField.text,
            let weight = weightTextField.text,
            let activityLevel = selectedActivityLevel ,
            let goal = selectedGoal else { return }
        guard let age = Int(age),
            let height = Double(height),
            let weight = Double(weight) else { return }
        guard let selectedSex = selectedSex else { return }
        
        let sex: Sex = selectedSex == maleButton ? .male : .female
        
        profile.age = age
        profile.sex = sex
        profile.height = height
        profile.weight = weight
        profile.activityLevel = activityLevel
        profile.goal = goal
        profile.caloriesBMT = calculateBMR(weight: weight, height: height, age: age, sex: sex)
        guard let bmt = profile.caloriesBMT  else { return }
        let tdee = calculateTDEE(bmr: bmt, activityLevel: activityLevel.value)
        profile.caloriesTDEEForGoal = calculateTDEEForGoal(tdee: tdee, goal: goal)

        self.selectedSex = selectedSex
        selectedActivityLevel = profile.activityLevel
        selectedGoal = profile.goal
    }
    
    func sideMenuConfigure() {
        
        // Подключаем ViewController по идентификатору
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let navigationController = storyboard.instantiateViewController(withIdentifier: "menuNavigationController") as? UINavigationController {
            if let  menuViewController = navigationController.topViewController as? MenuViewController {
                // Настраиваем контейнер меню
                menuContainerView.frame = CGRect(x: -menuWidth, y: 0, width: menuWidth, height: view.frame.height)
                menuContainerView.backgroundColor = .white
                view.addSubview(menuContainerView)
                
                // Добавляем меню как дочерний ViewController
                addChild(menuViewController)
                menuViewController.view.frame = menuContainerView.bounds
                menuContainerView.addSubview(menuViewController.view)
                menuViewController.didMove(toParent: self)
                
                // Настройка затемняющего фона
                dimmingView.frame = view.bounds
                dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                dimmingView.alpha = 0 // По умолчанию невидимый
                view.insertSubview(dimmingView, belowSubview: menuContainerView)
                
            }
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
 
        var proteinRate = 1.5
        var fatRate = 1.0
        
        if profile.goal == .weightLoss {
            proteinRate = 1.8
            fatRate = 0.8
        } else if profile.goal == .weightGain {
            proteinRate = 1.2
            fatRate = 1
        }
        // Распределение макронутриентов:
        let proteinCalories = weight * proteinRate * 4.0 // 2 г белка на кг массы тела, 1 г белка = 4 ккал
        let fatCalories = weight * fatRate * 9.0   // 1 г жира на кг массы тела, 1 г жира = 9 ккал
        
        // Углеводы — оставшиеся калории
        let carbsCalories = calorieNeedsForGoal - proteinCalories - fatCalories
        
        // Преобразуем углеводы в граммы
        let carbsGrams = carbsCalories / 4.0 // 1 г углеводов = 4 ккал
        
        return (protein: proteinCalories / 4.0, fat: fatCalories / 9.0, carbs: carbsGrams)
    }
    
    func showResults(for profile: Profile) {
        resultStackView.isHidden = false
        editButton.isHidden = false
        
        caloriesLabel.text = profile.caloriesTDEEForGoal?.formatted()
        guard let weight = profile.weight, let tdee = profile.caloriesTDEEForGoal else { return }
        let nutritions = calculateNutritionalNeeds(weight: weight, calorieNeedsForGoal: tdee)
        fillNutritions(for: profile)
    }
    
    func settingsFieldsAvailableToggle() {
        titleForParametersLabel.text = "Мои параметры: "
        maleButton.isEnabled.toggle()
        femaleButton.isEnabled.toggle()
        ageTextField.isEnabled.toggle()
        weightTextField.isEnabled.toggle()
        heightTextField.isEnabled.toggle()
        activityLevelTextField.isEnabled.toggle()
        goalTextField.isEnabled.toggle()
        
        settingsStackView.alpha = 0.6
    }
}

// MARK: - UIPickerViewDataSource,UIPickerViewDelegate
extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
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
            activityLevelTextField.text = ActivityLevel.allCases[row].rawValue
            selectedActivityLevel = ActivityLevel.allCases[row]
        } else if pickerView.tag == 2 {
            goalTextField.text = Goals.allCases[row].rawValue
            selectedGoal = Goals.allCases[row]
        }
    }
    
    @objc func dismissPicker() {
        view.endEditing(true) // Скрывает клавиатуру и PickerView
    }
    
    func setupPickerView(_ pickerView: UIPickerView, tag: Int) {
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.tag = tag
    }
    
    @objc func hideMenu() {
        guard isMenuOpen else { return }
        settingsButtonTapped(settingsButton)
        editButton.isEnabled = true
    }
}

//MARK: - GreetingViewControllerDelegate
extension ViewController: GreetingViewControllerDelegate {
    func didUpdateProfile(nickname: String, icon: String) {
        let newProfile = Profile(
            nickname: nickname,
            icon: icon,
            age: nil,
            sex: nil,
            height: nil,
            weight: nil,
            activityLevel: nil,
            goal: nil,
            caloriesBMT: nil,
            caloriesTDEEForGoal: nil
        )
        StorageManager.shared.add(newProfile: newProfile)
        StorageManager.shared.set(activeProfile: newProfile)
    }
}

extension ViewController: StorageManagerDelegate {
    // Функция для показа предупреждения
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
