//
//  greetingViewContoller.swift
//  CalorieCalculation
//
//  Created by Irina Muravyeva on 12.11.2024.
//

import UIKit

protocol GreetingViewControllerDelegate: AnyObject {
    func didUpdateProfile(_ profile: Profile)
}

class GreetingViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    @IBOutlet weak var continueButton: UIButton!
    
    weak var delegate: GreetingViewControllerDelegate?
    
    let icons = (1...16).map { "icon\($0)" }
    let itemsPerRow: CGFloat = 4
    let sectionInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) // Отступы
    
    var selectedIndexPath: IndexPath?
    var icon: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagesCollectionView.dataSource = self
        imagesCollectionView.delegate = self
        nicknameTextField.delegate = self
        
        continueButton.isEnabled = false
    }
    
    @IBAction func continueButtonTapped(_ sender: UIButton) {
        guard let nickname = nicknameTextField.text,
              let icon = icon,
              !nickname.isEmpty else { return }
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
    
    
        // Закрытие модального экрана
        dismiss(animated: true, completion: nil)
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
        textField.resignFirstResponder()
        checkContinueButtonEnable()
        
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
    
    private func checkContinueButtonEnable(){
        guard let nickname =  nicknameTextField.text else { return }
        
        if selectedIndexPath != nil && !nickname.isEmpty
            {
                continueButton.isEnabled = true
            } else {
                continueButton.isEnabled = false
            }
    }
}
