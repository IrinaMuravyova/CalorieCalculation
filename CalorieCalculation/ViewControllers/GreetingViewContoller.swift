//
//  greetingViewContoller.swift
//  CalorieCalculation
//
//  Created by Irina Muravyeva on 12.11.2024.
//

import UIKit

class GreetingViewController: UIViewController {
    
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    
    let icons = (1...16).map { "icon\($0)" }

    let itemsPerRow: CGFloat = 4
    let sectionInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) // Отступы
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagesCollectionView.dataSource = self
        imagesCollectionView.delegate = self

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
//        cell.imageView.contentMode = .scaleAspectFill
//        cell.imageView.clipsToBounds = true
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
        print("You selected sell \(indexPath.item)")
    }
}
