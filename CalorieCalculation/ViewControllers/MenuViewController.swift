//
//  MenuViewController.swift
//  CalorieCalculation
//
//  Created by Irina Muravyeva on 18.11.2024.
//

import UIKit

class MenuViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    let profiles = StorageManager.shared.fetchProfiles()
    var data = ["Item 1", "Item 2", "Item 3", "Item 4"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
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
        if let image = UIImage(named: profile.icon) {
            content.image = image
            content.imageProperties.maximumSize = CGSize(width: 30, height: 30)
        }
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "ПОЛЬЗОВАТЕЛИ"
    }
    
    // MARK: - Custom Footer View
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = .clear

        let footerLabel = UILabel()
        footerLabel.numberOfLines = 0 // Позволяет неограниченное количество строк
        footerLabel.text = "Свайп влево для удаления или изменения профиля."
        footerLabel.font = UIFont.systemFont(ofSize: 14)
        footerLabel.textColor = .gray
        footerLabel.textAlignment = .left

        footerLabel.translatesAutoresizingMaskIntoConstraints = false
        footerView.addSubview(footerLabel)

        // Настройка ограничений для footerLabel
        NSLayoutConstraint.activate([
            footerLabel.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 16),
            footerLabel.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -16),
            footerLabel.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 8),
            footerLabel.bottomAnchor.constraint(equalTo: footerView.bottomAnchor, constant: -8)
        ])

        return footerView
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

    //MARK: - Users Manager
extension MenuViewController {
    // Добавление кнопок удаления и редактирования
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Кнопка удаления
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            self.data.remove(at: indexPath.row) // Удаляем элемент из массива
            tableView.deleteRows(at: [indexPath], with: .automatic) // Удаляем строку из таблицы
            completionHandler(true) // Завершаем действие
        }

        // Кнопка редактирования
        let editAction = UIContextualAction(style: .normal, title: "Редактировать") { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            self.showEditAlert(at: indexPath) // Открываем окно редактирования
            completionHandler(true)
        }

        editAction.backgroundColor = .blue // Настраиваем цвет кнопки редактирования
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction]) // Возвращаем обе кнопки
    }

    // Окно редактирования
    private func showEditAlert(at indexPath: IndexPath) {
        let alert = UIAlertController(title: "Редактировать", message: "Измените текст", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = self.data[indexPath.row]
        }

        let saveAction = UIAlertAction(title: "Сохранить", style: .default) { [weak self] _ in
            guard let self = self else { return }
            if let newText = alert.textFields?.first?.text, !newText.isEmpty {
                self.data[indexPath.row] = newText
                self.tableView.reloadRows(at: [indexPath], with: .automatic) // Обновляем строку
            }
        }

        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
}
