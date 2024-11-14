//
//  greetingViewContoller.swift
//  CalorieCalculation
//
//  Created by Irina Muravyeva on 12.11.2024.
//

import UIKit

class GreetingViewController: UIViewController {
    
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    
    let icons = (1...16).map { "icon\($0)" }
    let itemsPerRow: CGFloat = 4
    let sectionInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) // Отступы
    
    var selectedIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagesCollectionView.dataSource = self
        imagesCollectionView.delegate = self
        nicknameTextField.delegate = self

    }
}

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "greeting" {
//            if let greetingVC = segue.destination as? greetingViewController {
//                // Передача данных во второй ViewController, если нужно
//                greetingVC.someProperty = "Some data"
//            }
//        }
//    }

//MARK: - UICollectionView для ячеек с иконками
extension GreetingViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return icons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCollectionViewCell
        cell.imageView.image = UIImage(named: icons[indexPath.row])
//        if indexPath == selectedIndexPath {
//            cell.backgroundColor = .lightGray // Цвет для выбранной ячейки
//        } else {
//            cell.backgroundColor = collectionView.backgroundColor // Цвет по умолчанию для невыбранных ячеек
//        }
        if indexPath == selectedIndexPath {
            setShadow(for: cell.imageView)
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
    }
    
    func setShadow(for object: Any?) {
        if let imageView = object as? UIImageView {
            imageView.layer.shadowColor = UIColor(.black).cgColor
            imageView.layer.shadowRadius = 5
            imageView.layer.shadowOffset = CGSize(width: 3, height: 3)
            imageView.layer.shadowOpacity = 0.6
            
            imageView.layer.cornerRadius = imageView.frame.width / 2
        }
    }
    
    func deleteShadow(for object: Any?) {
        if let imageView = object as? UIImageView {
            imageView.layer.shadowRadius = 0
            imageView.layer.shadowOffset = CGSize(width: 0, height: 0)
        }
    }
}

extension GreetingViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
