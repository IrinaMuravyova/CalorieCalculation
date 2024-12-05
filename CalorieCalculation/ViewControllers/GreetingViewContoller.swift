//
//  greetingViewContoller.swift
//  CalorieCalculation
//
//  Created by Irina Muravyeva on 12.11.2024.
//

import UIKit

protocol GreetingViewControllerDelegate: AnyObject {
    func didUpdateProfile(_ profile: Profile)
    func hideChoosingProfileMenu()
}

class GreetingViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var inputNameTitleLabel: UILabel!
    @IBOutlet weak var chooseImageTitleLabel: UILabel!
    
    weak var delegate: GreetingViewControllerDelegate?
    
    let icons = (1...16).map { "icon\($0)" }
    let itemsPerRow: CGFloat = 4
    let sectionInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) // Отступы
    
    var selectedIndexPath: IndexPath?
    var icon: String?
    var changingProfile: Profile?
    var changingStarted = false
    
    var senderTag: Int? // для скрытия/отображения кнопки отмена
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupColor()
        
        imagesCollectionView.dataSource = self
        imagesCollectionView.delegate = self
        nicknameTextField.delegate = self
        
        continueButton.isEnabled = false
        cancelButton.isHidden = senderTag == -1 ? false : true
        cancelButton.isEnabled = senderTag == -1 ? true : false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cancelButtonTapped))
        cancelButton.addGestureRecognizer(tapGesture)
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // если окно вызвано для изменения профиля, то заполняю nickname
        if changingProfile != nil {
            nicknameTextField.text = changingProfile?.nickname
            imagesCollectionView.reloadData()
        }
    }
    
    @IBAction func continueButtonTapped(_ sender: UIButton) {
        guard let nickname = nicknameTextField.text,
              let icon = icon,
              !nickname.isEmpty else { return }
        
        if changingStarted {
            guard let index = StorageManager.shared.fetchProfiles().firstIndex(where: {$0.nickname == changingProfile?.nickname}) else { return }
        
            StorageManager.shared.changeProfile(atIndex: index, withNickname: nickname, andIcon: icon)
            
            changingProfile = nil
            changingStarted = false

            // Передача данных через делегат
            let changedProfile = StorageManager.shared.fetchProfiles()[index]
            delegate?.didUpdateProfile(changedProfile)
            
            // возвращаюсь на ввод подробностей
            if let navigationController = self.view.window?.rootViewController as? UINavigationController {
                self.dismiss(animated: false) {
                    navigationController.popToRootViewController(animated: false)
                }
            }
            
        } else {
            // добавляю нового пользователя
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
            
            // Передача данных через делегат
            delegate?.didUpdateProfile(newProfile)
            delegate?.hideChoosingProfileMenu()
            
            // Закрытие модального экрана
            dismiss(animated: true, completion: nil)
        }
    }
}

//MARK: - UICollectionView для ячеек с иконками
extension GreetingViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return icons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCollectionViewCell
        cell.imageView.image = UIImage(named: icons[indexPath.row])
        
        // Если окно вызвано для изменения профиля, то выделяю текущую иконку профиля
        if changingProfile != nil && icons[indexPath.item]   ==  changingProfile?.icon && !changingStarted {
            selectedIndexPath = indexPath
            changingStarted = true
        }
        
        if indexPath == selectedIndexPath  {
            setShadow(for: cell.imageView)
            icon = icons[indexPath.item]
        } else {
            deleteShadow(for: cell.imageView)
        }
        cell.imageView.frame = cell.contentView.frame.inset(by: UIEdgeInsets(top: 5, left: 5, bottom: 20, right: 10))
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout

        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
            let availableWidth = collectionView.frame.width - paddingSpace
            let widthPerItem = availableWidth / itemsPerRow
            return CGSize(width: widthPerItem, height: widthPerItem)
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            return sectionInsets
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return sectionInsets.left
        }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if let previousIndexPath = selectedIndexPath {
                let previousCell = collectionView.cellForItem(at: previousIndexPath) as? ImageCollectionViewCell
                deleteShadow(for: previousCell?.imageView)
        }

        let currentCell = collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell
        setShadow(for: currentCell?.imageView)

        selectedIndexPath = indexPath
        checkContinueButtonEnable()
    }
}

extension GreetingViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        checkContinueButtonEnable()
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    // Получаем текущий текст в поле с учетом изменения
    if let currentText = textField.text {
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
        checkContinueButtonEnable(updatedText)
    }
    return true
}
}

//MARK: - Private methods
extension GreetingViewController {
    private func setShadow(for object: Any?) {
        if let imageView = object as? UIImageView {
            imageView.layer.masksToBounds = false
            imageView.layer.shadowColor = UIColor(hex: "#3F5B62", alpha: 1).cgColor
            imageView.layer.shadowOpacity = 1
            imageView.layer.shadowOffset = CGSize(width: 0, height: 2)
            imageView.layer.shadowRadius = 4
        
            imageView.layer.cornerRadius = imageView.frame.width / 2
        }
    }
    
    private func deleteShadow(for object: Any?) {
        if let imageView = object as? UIImageView {
            imageView.layer.masksToBounds = false
            imageView.layer.shadowColor = UIColor(hex: "#3F5B62", alpha: 1).cgColor
            imageView.layer.shadowOpacity = 0.4
            imageView.layer.shadowOffset = CGSize(width: 0, height: 2)
            imageView.layer.shadowRadius = 2
        }
    }
    
    @objc private func checkContinueButtonEnable(_ updatedText: String? = nil){
        // Если текст был передан, проверяю его состояние, иначе использую текущее значение в textField
        let text = updatedText ?? nicknameTextField.text
        
        // Проверяю, что текст не пустой и выбран индекс
        if let nickname = text, selectedIndexPath != nil && !nickname.isEmpty {
            continueButton.isEnabled = true
        } else {
            continueButton.isEnabled = false
        }
    }
    
    @objc func cancelButtonTapped() {
        dismiss(animated: true)
        UIView.animate(withDuration: 0.35) {
            self.delegate?.hideChoosingProfileMenu()
        }
    }
    
    private func setupColor() {
        view.backgroundColor = UIColor(hex: "#8CA9AA", alpha: 1)
        
        inputNameTitleLabel.layer.cornerRadius = 10
        inputNameTitleLabel.layer.shadowColor = UIColor(hex: "#576F72", alpha: 1).cgColor
        inputNameTitleLabel.layer.shadowOpacity = 0.4
        inputNameTitleLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
        inputNameTitleLabel.layer.shadowRadius = 4
        
        
        chooseImageTitleLabel.layer.cornerRadius = 10
        chooseImageTitleLabel.layer.shadowColor = UIColor(hex: "#576F72", alpha: 1).cgColor
        chooseImageTitleLabel.layer.shadowOpacity = 0.4
        chooseImageTitleLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
        chooseImageTitleLabel.layer.shadowRadius = 4
        
        cancelButton.tintColor = UIColor(hex: "#D69955", alpha: 1)
        cancelButton.layer.cornerRadius = 10
        cancelButton.layer.shadowColor = UIColor(hex: "#576F72", alpha: 1).cgColor
        cancelButton.layer.shadowOpacity = 0.4
        cancelButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        cancelButton.layer.shadowRadius = 4
        
        inputNameTitleLabel.textColor = UIColor(hex: "#3F5B62", alpha: 1)
        titleLabel.textColor = UIColor(hex: "#D69955", alpha: 1)
        titleLabel.shadowColor = UIColor(hex: "#3F5B62", alpha: 1)
        titleLabel.layer.shadowOpacity = 0.4
        titleLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
        titleLabel.layer.shadowRadius = 4
        chooseImageTitleLabel.textColor = UIColor(hex: "#3F5B62", alpha: 1)
        
        nicknameTextField.textColor = UIColor(hex: "#3F5B62", alpha: 1)
        nicknameTextField.backgroundColor = UIColor(hex: "#E4DCCF", alpha: 1)
        nicknameTextField.tintColor = UIColor(hex: "#D69955", alpha: 1)
        nicknameTextField.layer.cornerRadius = 10
        nicknameTextField.layer.shadowColor = UIColor(hex: "#576F72", alpha: 1).cgColor
        nicknameTextField.layer.shadowOpacity = 0.4
        nicknameTextField.layer.shadowOffset = CGSize(width: 0, height: 2)
        nicknameTextField.layer.shadowRadius = 4
        
        imagesCollectionView.backgroundColor = UIColor(hex: "#8CA9AA", alpha: 1)
        
        continueButton.tintColor = continueButton.isEnabled ?
        UIColor(hex: "#D69955", alpha: 1) : UIColor(hex: "#DCDCDC", alpha: 1)
        continueButton.titleLabel?.textColor = continueButton.isEnabled ?
        UIColor(hex: "#3F5B62", alpha: 1) : UIColor(hex: "#576F72", alpha: 1)
        continueButton.layer.cornerRadius = 10
        continueButton.layer.shadowColor = UIColor(hex: "#576F72", alpha: 1).cgColor
        continueButton.layer.shadowOpacity = 0.4
        continueButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        continueButton.layer.shadowRadius = 4
    }
}
