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
        // Получаем предыдущий индекс выделенной ячейки, если он существует
        let previousIndexPath = selectedIndexPath
            
        // Обновляем индекс новой выделенной ячейки
        selectedIndexPath = indexPath

        // Собираем массив ячеек для перезагрузки
        var indexPathsToReload = [indexPath]
        if let previousIndexPath = previousIndexPath, previousIndexPath != indexPath {
            indexPathsToReload.append(previousIndexPath)
        }

        // Перезагружаем только текущую и предыдущую ячейки
        collectionView.reloadItems(at: indexPathsToReload)
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
            imageView.layer.shadowColor = UIColor(.black).cgColor
            imageView.layer.shadowRadius = 5
            imageView.layer.shadowOffset = CGSize(width: 3, height: 3)
            imageView.layer.shadowOpacity = 0.6
            
            imageView.layer.cornerRadius = imageView.frame.width / 2
        }
    }
    
    private func deleteShadow(for object: Any?) {
        if let imageView = object as? UIImageView {
            imageView.layer.shadowRadius = 0
            imageView.layer.shadowOffset = CGSize(width: 0, height: 0)
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
}
