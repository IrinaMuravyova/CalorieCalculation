//
//  ViewController.swift
//  CalorieCalculation
//
//  Created by Irina Muravyeva on 12.11.2024.
//

import UIKit

class ViewController: UIViewController {

    var profiles: [Profile]!
    var activeProfile: Profile! // activeUser
    let deficitCalorie = 0.2 // 20%
    let overageCalorie = 0.2 // 20%
    
    // profile's parameters for calculate B-H formula
    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var activityLevelTextView: UITextView!
    @IBOutlet weak var goalTextField: UITextField!
    
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var proteinLabel: UILabel!
    @IBOutlet weak var fatLabel: UILabel!
    @IBOutlet weak var carbLabel: UILabel!
    
    @IBOutlet weak var titleForParametersLabel: UILabel!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var parametersView: UIView!
    @IBOutlet weak var resultsView: UIView!
    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var questionButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var buttonsView: UIView!
    
    // For localize
    @IBOutlet weak var sexLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var lifeStyleLabel: UILabel!
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var maleLabel: UILabel!
    @IBOutlet weak var femaleLabel: UILabel!
    @IBOutlet weak var resultTitleLabel: UILabel!
    @IBOutlet weak var dailyNormLabel: UILabel!
    @IBOutlet weak var kcalLabel: UILabel!
    @IBOutlet weak var proteinTitleLabel: UILabel!
    @IBOutlet weak var fatTitleLabel: UILabel!
    @IBOutlet weak var carbsTitleLabel: UILabel!
    @IBOutlet weak var editBarButtonTitle: UIBarButtonItem!
    
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
    
    // для выезжающего view для смены профиля
    private let choosingProfileView: UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.clipsToBounds = true
            view.alpha = 0 // Начальное состояние скрыто
            return view
        }()
    private var menuViewHeightConstraint: NSLayoutConstraint!
    private var isChooseProfileMenuVisible = false // Флаг состояния меню
    
    private var menuViewController: MenuViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupColor()
        
//        if let localizedValue = Bundle.main.localizedString(forKey: "weight_loss", value: nil, table: nil) as? String {
//            print("Localized Value: \(localizedValue)")
//        }
        // For localize
        sexLabel.text = NSLocalizedString("sex_title_label", comment: "")
        ageLabel.text = NSLocalizedString("age_title_label", comment: "")
        heightLabel.text = NSLocalizedString("height_title_label", comment: "")
        weightLabel.text = NSLocalizedString("weight_title_label", comment: "")
        lifeStyleLabel.text = NSLocalizedString("activity_title_label", comment: "")
        goalLabel.text = NSLocalizedString("goal_title_label", comment: "")
        maleLabel.text = NSLocalizedString("male_title_label", comment: "")
        femaleLabel.text = NSLocalizedString("female_title_label", comment: "")
        resultTitleLabel.text = NSLocalizedString("result_title_label", comment: "")
        kcalLabel.text = NSLocalizedString("kcal_title_label", comment: "")
        proteinTitleLabel.text = NSLocalizedString("protein_title_label", comment: "")
        fatTitleLabel.text = NSLocalizedString("fat_title_label", comment: "")
        carbsTitleLabel.text = NSLocalizedString("carbs_title_label", comment: "")
        
        activityLevelTextView.text = NSLocalizedString("choose_value", comment: "")
        goalTextField.text = NSLocalizedString("choose_value", comment: "")
        
        profiles = StorageManager.shared.fetchProfiles()
        activeProfile = StorageManager.shared.fetchActiveProfile()
          
        configuring(button: profileButton, withImage: UIImage(named: activeProfile.icon))
        configuring(button: settingsButton, withImage: UIImage(systemName: "gear"))
        configuring(button: questionButton, withImage: UIImage(systemName: "questionmark.circle"))
        
        if activeProfile.age == nil { //TODO: change verify
            titleForParametersLabel.text = NSLocalizedString("title_for_parameters_label", comment: "")
            
            editButton.style = .done
            editButton.title = "OK"
        
            resultsView.isHidden = true
        } else {
            fillFields(for: activeProfile)
        }
        
        maleButton.addTarget(self, action: #selector(sexDidChoose(_:)), for: .touchUpInside)
        femaleButton.addTarget(self, action: #selector(sexDidChoose(_:)), for: .touchUpInside)
        
        setupPickerView(activityLevelPickerView, tag: 1)
        setupPickerView(goalPickerView, tag: 2)
        activityLevelTextView.inputView = activityLevelPickerView
        goalTextField.inputView = goalPickerView
        
        activityLevelTextView.delegate = self
        goalTextField.delegate = self
        
        // Добавляем распознаватель жестов для скрытия клавиатуры по нажатию на экран
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPicker))
        view.addGestureRecognizer(tapGesture)
        let tapGestureForMenu = UITapGestureRecognizer(target: self, action: #selector(hideMenu))
        dimmingView.addGestureRecognizer(tapGestureForMenu)
        
        addToolbarToTextField(ageTextField)
        addToolbarToTextField(heightTextField)
        addToolbarToTextField(weightTextField)
        
        // Метод для добавления панели инструментов на текстовые поля
        func addToolbarToTextField(_ textField: UITextField) {
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            
            let doneButton = UIBarButtonItem(title: "OK", style: .done, target: self, action: #selector(doneButtonTapped))
            toolbar.setItems([doneButton], animated: true)
            
            textField.inputAccessoryView = toolbar
            textField.delegate = self  // Устанавливаем делегат для textField, если нужно
        }
        
        sideMenuConfigure()
        
        // Добавляем свайп-жест
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(hideMenu))
        swipeGesture.direction = .left
        self.view.addGestureRecognizer(swipeGesture)
        
        // Извлекаю код языка и устанавливаю язык интерфейса
        let userPreferredLanguage = Locale.preferredLanguages.first?.prefix(2) ?? "en"
        Bundle.setLanguage(String(userPreferredLanguage))
        
        // Настройте параметры UITextView
        activityLevelTextView.isScrollEnabled = false
        activityLevelTextView.textContainer.lineBreakMode = .byWordWrapping
        activityLevelTextView.textContainerInset = .init(top: 0, left: 7, bottom: 0, right: 7)
        activityLevelTextView.textContainer.lineFragmentPadding = 0
         
        // Добавляем рамку
        activityLevelTextView.layer.borderWidth = 1
        activityLevelTextView.layer.cornerRadius = 5
        activityLevelTextView.layer.borderColor = UIColor.systemGray5.cgColor
        
        profileButton.addTarget(self, action: #selector(toggleChoosingProfileMenu), for: .touchUpInside)
        setupChoosingProfileView()
        setupMenuViewController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
        profiles = StorageManager.shared.fetchProfiles()
        activeProfile = StorageManager.shared.fetchActiveProfile()
        }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        profiles = StorageManager.shared.fetchProfiles()
        
        if profiles == nil || profiles.isEmpty || activeProfile == nil {
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
                    sender.title = NSLocalizedString("edit_title", comment: "")
                    disableEditingMode()
                }
            }
    }
    
    @IBAction func settingsButtonTapped(_ sender: UIButton) {
        
        isMenuOpen.toggle()
        editButton.isEnabled = false

        menuViewController?.receivedProfile = activeProfile

        UIView.animate(withDuration: 0.3) {
            self.menuContainerView.frame.origin.x = self.isMenuOpen ? 0 : -self.menuWidth
            self.dimmingView.alpha = self.isMenuOpen ? 1 : 0
            self.view.layoutIfNeeded()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "greetingSegue",
            let greetingVC = segue.destination as? GreetingViewController {
                greetingVC.delegate = self
            if let senderTag = sender as? Int {
                    greetingVC.senderTag = senderTag    
//                } else {
//                    greetingVC.senderTag = -1 // иначе создаем новый
                }
        }
    }
    
}

// MARK: - UITextViewDelegate, UITextFieldDelegate
extension ViewController: UITextViewDelegate, UITextFieldDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView == activityLevelTextView {
            // Устанавливаю текст в момент активации UIPickerView
            if let firstActivityLevel = ActivityLevel.allCases.first {
                activityLevelTextView.text = firstActivityLevel.localized
                selectedActivityLevel = firstActivityLevel
            }
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == goalTextField {
            // Устанавливаю текст в момент активации UIPickerView
            if let firstGoal = Goals.allCases.first {
                goalTextField.text = firstGoal.localized
                selectedGoal = firstGoal
            }
        }
        return true
    }
}

//MARK: - Setup methods
extension ViewController {
    private func setupMenuViewController() {

        if menuViewController == nil {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                guard let menuVC = storyboard.instantiateViewController(withIdentifier: "menuViewController") as? MenuViewController else {
                    print("MenuViewController не найден!")
                    return
                }
                
        menuViewController = menuVC // Сохраняем экземпляр
                
        // Добавляем MenuViewController как дочерний
        addChild(menuVC)
        menuVC.view.frame = menuContainerView.bounds
        menuContainerView.addSubview(menuVC.view)
        menuVC.didMove(toParent: self)
        }
    }
        
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
            femaleButton.setImage(UIImage(systemName: "circle"), for: .normal)
        } else {
            femaleButton.setImage(UIImage(systemName: "circle.circle.fill"), for: .normal)
            maleButton.setImage(UIImage(systemName: "circle"), for: .normal)
        }
        guard
            let age = profile.age,
            let height = profile.height,
            let weight = profile.weight,
            let activityLevel = profile.activityLevel?.localized,
            let goal = profile.goal?.localized
        else { return }
        
        ageTextField.text = age.formatted()
        heightTextField.text = height.formatted()
        weightTextField.text = weight.formatted()
        activityLevelTextView.text = activityLevel

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
        view.endEditing(true)
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
    
    func checkFilling() -> Bool {

        if selectedSex == nil {
            let message = NSLocalizedString("sex_alert", comment: "")
            showAlert(message: message)
            return false
        }
    
        guard let age = ageTextField.text else {
            showAlert(message: "age_alert")
            return false
        }
        guard let age = Int(age) else {
            showAlert(message: "age_alert")
            return false
        }
        if age < 14 || age > 80 {
            showAlert(message: "age_alert")
            return false
        }

        guard let height = heightTextField.text else {
            showAlert(message: "height_alert")
            return false
        }
        guard let height = Int(height) else {
            showAlert(message: "height_alert")
            return false
        }
        if height < 140 || height > 200 {
            showAlert(message: "height_alert")
            return false
        }
        
        guard let weight = weightTextField.text else {
            showAlert(message: "weight_alert")
            return false
        }
        guard let weight = Int(weight) else {
            showAlert(message: "weight_alert")
            return false
        }
        if weight < 50 || weight > 150 {
            showAlert(message: "weight_alert")
            return false
        }
        
        if selectedActivityLevel == nil {
            showAlert(message: "activity_alert")
            return false
        }
        if selectedGoal == nil {
            showAlert(message: "goal_alert")
            return false
        }
        
        if age >= 14 && age < 18 {
            let title = NSLocalizedString("age_attention_title_alert", comment: "")
            let message = NSLocalizedString("age_attention_text_alert", comment: "")
            let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
        return true
    }
    
    func enableEditingMode() {
        settingsFieldsAvailableToggle()
        parametersView.alpha = 1
        resultsView.alpha = 0.6
    }
    
    func disableEditingMode() {
        settingsFieldsAvailableToggle()
        parametersView.alpha = 0.6
        resultsView.alpha = 1
        
        calculateResult()
        
        StorageManager.shared.save(changedProfile: activeProfile)
        StorageManager.shared.set(activeProfile: activeProfile)

        showResults(for: activeProfile)
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
        
        activeProfile.age = age
        activeProfile.sex = sex
        activeProfile.height = height
        activeProfile.weight = weight
        activeProfile.activityLevel = activityLevel
        activeProfile.goal = goal
        activeProfile.caloriesBMT = calculateBMR(weight: weight, height: height, age: age, sex: sex)
        guard let bmt = activeProfile.caloriesBMT  else { return }
        let tdee = calculateTDEE(bmr: bmt, activityLevel: activityLevel.value)
        activeProfile.caloriesTDEEForGoal = calculateTDEEForGoal(tdee: tdee, goal: goal)

        self.selectedSex = selectedSex
        selectedActivityLevel = activeProfile.activityLevel
        selectedGoal = activeProfile.goal
    }
    
    func sideMenuConfigure() {
        
        // Подключаем ViewController по идентификатору
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let navigationController = storyboard.instantiateViewController(withIdentifier: "menuNavigationController") as? UINavigationController {
            if let  menuVC = navigationController.topViewController as? MenuViewController {
                menuViewController = menuVC
                
                // Настраиваем контейнер меню
                menuContainerView.frame = CGRect(x: -menuWidth, y: 0, width: menuWidth, height: view.frame.height)
                menuContainerView.backgroundColor = .white
                view.addSubview(menuContainerView)
                
                // Добавляем меню как дочерний ViewController
                addChild(menuViewController!)
                menuViewController!.view.frame = menuContainerView.bounds
                menuContainerView.addSubview(menuViewController!.view)
                menuViewController!.didMove(toParent: self)
                
                // Настройка затемняющего фона
                dimmingView.frame = view.bounds
                dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                dimmingView.alpha = 0 // По умолчанию невидимый
                view.insertSubview(dimmingView, belowSubview: menuContainerView)
            }
        }
    }
    
    private func setupChoosingProfileView() {
        view.addSubview(choosingProfileView)
        
        // Устанавливаем ограничения для меню
        NSLayoutConstraint.activate([
            choosingProfileView.widthAnchor.constraint(equalTo: profileButton.widthAnchor),
            choosingProfileView.centerXAnchor.constraint(equalTo: profileButton.centerXAnchor),
            choosingProfileView.bottomAnchor.constraint(equalTo: profileButton.topAnchor, constant: -10)
        ])
        
        // Высота меню (изначально 0)
        menuViewHeightConstraint = choosingProfileView.heightAnchor.constraint(equalToConstant: 0)
        menuViewHeightConstraint.isActive = true
        
        // Добавляем круглые кнопки в меню
//        addButtonsToMenu()
        updateChooseProfileMenu()
    }
    
    private func addButtonsToMenu() {
        let buttonSize: CGFloat = 50
        
        // Создаем ScrollView
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        choosingProfileView.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: choosingProfileView.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: choosingProfileView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: choosingProfileView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: choosingProfileView.trailingAnchor)
        ])

        // Создаем StackView для вертикального размещения кнопок
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor) // Чтобы кнопки были выровнены по центру
        ])
        
        // Добавляем кнопку "plus" в StackView
        let addProfileButton = UIButton()
        addProfileButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addProfileButton.backgroundColor = .lightGray
        addProfileButton.tintColor = .white
        addProfileButton.layer.cornerRadius = buttonSize / 2
        addProfileButton.translatesAutoresizingMaskIntoConstraints = false
        addProfileButton.tag = -1 // Для идентификации кнопок
        addProfileButton.addTarget(self, action: #selector(addProfileButtonTapped(_:)), for: .touchUpInside)
        stackView.addArrangedSubview(addProfileButton)

        NSLayoutConstraint.activate([
            addProfileButton.widthAnchor.constraint(equalToConstant: buttonSize),
            addProfileButton.heightAnchor.constraint(equalToConstant: buttonSize)
        ])
        
        // Добавляем остальные кнопки в StackView
        for (index, profileData) in profiles.enumerated() {
            if profileData.nickname == activeProfile.nickname { continue }
            let button = UIButton()
            button.setImage(UIImage(named: profileData.icon), for: .normal)
            button.layer.cornerRadius = buttonSize / 2
            button.translatesAutoresizingMaskIntoConstraints = false
            button.tag = index // Для идентификации кнопок
            button.addTarget(self, action: #selector(ChooseProfileButtonTapped(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)

            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: buttonSize),
                button.heightAnchor.constraint(equalToConstant: buttonSize)
            ])
        }
    }
        
    @objc private func toggleChoosingProfileMenu() {
        isChooseProfileMenuVisible.toggle()
        menuViewHeightConstraint.constant = isChooseProfileMenuVisible ? view.frame.height / 2 : 0 // Высота меню
        UIView.animate(withDuration: 0.3, animations: { [self] in
            choosingProfileView.alpha = isChooseProfileMenuVisible ? 1 : 0
            dimmingView.alpha = isChooseProfileMenuVisible ? 1 : 0
            editButton.isEnabled = isChooseProfileMenuVisible ? false : true
            view.layoutIfNeeded()
        })
        view.bringSubviewToFront(choosingProfileView)
    }
        
    @objc private func ChooseProfileButtonTapped(_ sender: UIButton) {

        activeProfile = profiles[sender.tag]
        StorageManager.shared.set(activeProfile: activeProfile)

        // Обновляю иконку у кнопки профиля
        configuring(button: profileButton, withImage: UIImage(named: activeProfile.icon))
//        setupChoosingProfileView()
        toggleChoosingProfileMenu()
        
        // Обновляю главный экран
        if activeProfile.age == nil { //TODO: change verify
            titleForParametersLabel.text = NSLocalizedString("title_for_parameters_label", comment: "")
            
            editButton.style = .done
            editButton.title = "OK"
            
            enableEditingMode()
            
            maleButton.setImage(UIImage(named: "circle"), for: .normal)
            femaleButton.setImage(UIImage(named: "circle"), for: .normal)
            ageTextField.text = nil
            heightTextField.text = nil
            weightTextField.text = nil
            activityLevelTextView.text = NSLocalizedString("choose_value", comment: "")
            goalTextField.text = NSLocalizedString("choose_value", comment: "")
        
            resultsView.isHidden = true
        } else {
            resultsView.isHidden = false
            fillFields(for: activeProfile)
            editButton.style = .plain
            editButton.title = NSLocalizedString("edit_title", comment: "")
            disableEditingMode()
        }
    }
    
    @objc private func addProfileButtonTapped(_ sender: UIButton) {
        toggleChoosingProfileMenu() // скрываю меню перед переходом
        performSegue(withIdentifier: "greetingSegue", sender: sender.tag)
    }
    
    func setupColor() {
        view.backgroundColor = UIColor(hex: "#576F72", alpha: 1)
        parametersView.backgroundColor = UIColor(hex: "#7D9D9C", alpha: 1)
        resultsView.backgroundColor = UIColor(hex: "#F8DAA8", alpha: 1)
        buttonsStackView.backgroundColor = UIColor(hex: "#576F72", alpha: 1)
        buttonsView.backgroundColor = UIColor(hex: "#576F72", alpha: 1)
        
        maleButton.tintColor = UIColor(hex: "#D69955", alpha: 1)
        femaleButton.tintColor = UIColor(hex: "#D69955", alpha: 1)
        
        settingsButton.setImage(UIImage(named: "gear")?.withRenderingMode(.alwaysTemplate), for: .normal)
        settingsButton.tintColor = UIColor(hex: "#D69955", alpha: 1)
        settingsButton.layer.shadowColor = UIColor(hex: "#F8DAA8", alpha: 1).cgColor //UIColor(.black).cgColor
        settingsButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        settingsButton.layer.shadowRadius = 4
        settingsButton.layer.shadowOpacity = 0.4
        settingsButton.imageView?.backgroundColor = UIColor(hex: "#E4DCCF", alpha: 1)

        questionButton.imageView?.backgroundColor = UIColor(hex: "#E4DCCF", alpha: 1)
        questionButton.layer.shadowColor = UIColor(hex: "#F8DAA8", alpha: 1).cgColor //UIColor(.black).cgColor
        questionButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        questionButton.layer.shadowRadius = 4
        questionButton.layer.shadowOpacity = 0.4
        
        // Установим скругление после настройки фреймов
        DispatchQueue.main.async {
            self.settingsButton.imageView?.layer.cornerRadius = (self.settingsButton.imageView?.frame.height ?? 0) / 2
            self.settingsButton.imageView?.layer.masksToBounds = true
            
            self.questionButton.imageView?.layer.cornerRadius = (self.questionButton.imageView?.frame.height ?? 0) / 2
            self.questionButton.imageView?.layer.masksToBounds = true
        }
        
        let titleForParametersTextColorUnactive = UIColor(hex: "#EEEEEE", alpha: 1)
        let titleForParametersTextColorActive = UIColor(hex: "#D69955", alpha: 1)
        let titleForParametersTextColor = editButton.style == .plain ? titleForParametersTextColorUnactive : titleForParametersTextColorActive
        titleForParametersLabel.textColor = editButton.style == .plain ? titleForParametersTextColorUnactive : titleForParametersTextColorActive
        resultTitleLabel.textColor = UIColor(hex: "#3F5B62", alpha: 1)
        
        let parametersTextColorUnactive = UIColor(hex: "#3F5B62", alpha: 1)
        let parametersTextColorActive = UIColor(hex: "#EEEEEE", alpha: 1)
        let parametersTextColor = editButton.style == .plain ? parametersTextColorUnactive : parametersTextColorActive
        sexLabel.textColor = parametersTextColor
        maleLabel.textColor = parametersTextColor
        femaleLabel.textColor = parametersTextColor
        ageLabel.textColor = parametersTextColor
        heightLabel.textColor = parametersTextColor
        weightLabel.textColor = parametersTextColor
        lifeStyleLabel.textColor = parametersTextColor
        goalLabel.textColor = parametersTextColor
        ageTextField.textColor = UIColor(hex: "#3F5B62", alpha: 1)
        weightTextField.textColor = UIColor(hex: "#3F5B62", alpha: 1)
        heightTextField.textColor = UIColor(hex: "#3F5B62", alpha: 1)
        activityLevelTextView.textColor = UIColor(hex: "#3F5B62", alpha: 1)
        goalTextField.textColor = UIColor(hex: "#3F5B62", alpha: 1)

        let resultsTextColor = UIColor(hex: "#3F5B62", alpha: 1)
        kcalLabel.textColor = resultsTextColor
        caloriesLabel.textColor = resultsTextColor
        proteinLabel.textColor = resultsTextColor
        proteinTitleLabel.textColor = resultsTextColor
        fatTitleLabel.textColor = resultsTextColor
        fatLabel.textColor = resultsTextColor
        carbsTitleLabel.textColor = resultsTextColor
        carbLabel.textColor = resultsTextColor
        
        
        
        profileButton.layer.shadowColor = UIColor(hex: "#F8DAA8", alpha: 1).cgColor
        profileButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        profileButton.layer.shadowRadius = 2
        profileButton.layer.shadowOpacity = 0.8
        
        parametersView.layer.cornerRadius = 10
        resultsView.layer.cornerRadius = 10
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
        
        if activeProfile.goal == .weightLoss {
            proteinRate = 1.8
            fatRate = 0.8
        } else if activeProfile.goal == .weightGain {
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
        resultsView.isHidden = false
        editButton.isHidden = false
        
        caloriesLabel.text = profile.caloriesTDEEForGoal?.formatted()
//        guard let weight = profile.weight, let tdee = profile.caloriesTDEEForGoal else { return }
        fillNutritions(for: profile)
    }
    
    func settingsFieldsAvailableToggle() {
        titleForParametersLabel.text = NSLocalizedString("parameters_title", comment: "")
        
        let enabled = editButton.style == .done ? true : false
        maleButton.isEnabled = enabled
        femaleButton.isEnabled = enabled
        ageTextField.isEnabled = enabled
        weightTextField.isEnabled = enabled
        heightTextField.isEnabled = enabled
        activityLevelTextView.isUserInteractionEnabled = enabled
        if activityLevelTextView.isUserInteractionEnabled {
                // Активное состояние
            activityLevelTextView.backgroundColor = UIColor.white
            activityLevelTextView.layer.borderColor = UIColor.systemGray5.cgColor
            } else {
                // Неактивное состояние
                activityLevelTextView.layer.borderColor = UIColor.systemGray5.cgColor
//                activityLevelTextView.backgroundColor = UIColor.systemFill // не тот цвет
            }
        goalTextField.isEnabled = enabled
        parametersView.alpha = 0.6
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
            return ActivityLevel.allCases[row].localized
        } else if pickerView.tag == 2 {
            return Goals.allCases[row].localized    
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 {
            activityLevelTextView.text = ActivityLevel.allCases[row].localized
            activityLevelTextView.textAlignment = .left
            selectedActivityLevel = ActivityLevel.allCases[row]
        } else if pickerView.tag == 2 {
            goalTextField.text = Goals.allCases[row].localized
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
        if isMenuOpen {
            settingsButtonTapped(settingsButton)
            editButton.isEnabled = true
            profiles = StorageManager.shared.fetchProfiles()
        }
        if isChooseProfileMenuVisible {
            toggleChoosingProfileMenu()
        }
    }
}

//MARK: - GreetingViewControllerDelegate
extension ViewController: GreetingViewControllerDelegate {

        func didUpdateProfile(_ profile: Profile) {

        hideMenu()
        
        // Обновляю иконку у кнопки профиля
        configuring(button: profileButton, withImage: UIImage(named: profile.icon))
        
        // Обновляю таблицу в side menu
        sideMenuConfigure()
        
        toggleChoosingProfileMenu()
        
        profiles = StorageManager.shared.fetchProfiles()
        self.activeProfile = profile
        view.reloadInputViews()
        choosingProfileView.reloadInputViews()
    }
}

extension ViewController: StorageManagerDelegate {
    // Функция для показа предупреждения
    func showAlert(message: String) {
        let title = NSLocalizedString("error_title_alert", comment: "")
        let message = NSLocalizedString(message, comment: "")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func hideChoosingProfileMenu() {
        toggleChoosingProfileMenu()
    }
}

// MARK: - Set interface language
extension Bundle {
    private static var bundle: Bundle?

    static func setLanguage(_ language: String) {
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj") else { return }
        bundle = Bundle(path: path)
    }

    static func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        return bundle?.localizedString(forKey: key, value: value, table: tableName) ?? key
    }
}

extension ViewController: MenuViewControllerDelegate {
    func updateChooseProfileMenu() {
        profiles = StorageManager.shared.fetchProfiles()
        
        // Удаляем все текущие кнопки из ChoosingProfileView
        choosingProfileView.subviews.forEach { $0.removeFromSuperview() }
        
        // Заново добавляем кнопки на основе обновленных данных
        addButtonsToMenu()
    }
}

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

class NavigationViewController: UINavigationController {
    override func viewDidLoad() {
        let appearance = UINavigationBar.appearance()
        appearance.tintColor = UIColor(hex: "#D69955", alpha: 1) // Устанавливаем цвет текста кнопки "Back"
    }
}
