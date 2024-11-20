//
//  MenuViewController.swift
//  CalorieCalculation
//
//  Created by Irina Muravyeva on 18.11.2024.
//

import UIKit

class MenuViewController: UIViewController {
    @IBOutlet weak var sendEmailButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    let profiles = StorageManager.shared.fetchProfiles()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .red
        tableView.reloadData()
    }
}

//MARK: - UITableView
extension MenuViewController: UITableViewDelegate, UITableViewDataSource, StorageManagerDelegate {
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath)
        let profile = profiles[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = profile.nickname
        content.image = UIImage(named: profile.icon)
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "ПОЛЬЗОВАТЕЛИ"
    }
    
}
