//
//  MenuViewController.swift
//  CalorieCalculation
//
//  Created by Irina Muravyeva on 18.11.2024.
//

import UIKit
import MessageUI

class MenuViewController: UIViewController, GreetingViewControllerDelegate {
    func didUpdateProfile(nickname: String, icon: String) {
        //TODO: kk
    }
    
    @IBOutlet weak var tableView: UITableView!
    let profiles = StorageManager.shared.fetchProfiles()
    var data = ["Item 1", "Item 2", "Item 3", "Item 4"] //  для тестирования
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
    }
    
    @IBAction func sendEmailButton(_ sender: UIButton) {
        // Проверьте, доступна ли функция отправки писем
//        if MFMailComposeViewController.canSendMail() {
//            let mailComposeVC = MFMailComposeViewController()
//            mailComposeVC.mailComposeDelegate = self
//
//            // Настройте письмо
//            mailComposeVC.setToRecipients(["developer@example.com"]) // Замените на адрес разработчика
//            mailComposeVC.setSubject("Обратная связь о приложении")
//            mailComposeVC.setMessageBody("Здравствуйте! Хотелось бы сообщить следующее:", isHTML: false)
//
//            // Покажите почтовый интерфейс
//            present(mailComposeVC, animated: true, completion: nil)
//        } else {
//            // Покажите сообщение об ошибке
//            let alert = UIAlertController(
//                title: "Ошибка",
//                message: "На устройстве не настроен почтовый клиент.",
//                preferredStyle: .alert
//            )
//            alert.addAction(UIAlertAction(title: "ОК", style: .default))
//            present(alert, animated: true)
//            }

//    // MARK: - MFMailComposeViewControllerDelegate
//    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
//        controller.dismiss(animated: true)
//
//        // Обработка результата
//        switch result {
//        case .sent:
//            print("Письмо отправлено")
//        case .saved:
//            print("Письмо сохранено")
//        case .cancelled:
//            print("Письмо отменено")
//        case .failed:
//            print("Ошибка отправки письма")
//        @unknown default:
//            break
//        }
//    }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeProfileSegue" { // Убедитесь, что идентификатор совпадает
            if let changeProfileVC = segue.destination as? GreetingViewController {
//                changeProfileVC.textForTitleLabel = "Редактировать"
//                guard let indexPath = sender as? Int else { return }
                changeProfileVC.delegate = self
            }
        }
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
        return StorageManager.shared.fetchProfiles().count
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
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { (_, _, completionHandler) in
//            guard let self = self else { return }
            StorageManager.shared.deleteProfile(at: indexPath.row) // Удаляем элемент из массива
//            self.data.remove(at: indexPath.row)
            // Обновляем интерфейс таблицы
            tableView.performBatchUpdates {
                tableView.deleteRows(at: [indexPath], with: .automatic) // Удаляем строку из таблицы
            }
            completionHandler(true) // Завершаем действие
        }

        // Кнопка редактирования
        let editAction = UIContextualAction(style: .normal, title: "Редактировать") { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            performSegue(withIdentifier: "changeProfileSegue", sender: indexPath)
//            self.showEditAlert(at: indexPath) // Открываем окно редактирования
            completionHandler(true)
        }

        editAction.backgroundColor = .blue // Настраиваем цвет кнопки редактирования
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction]) // Возвращаем обе кнопки
    }

    // Окно редактирования
    private func showEditAlert(at indexPath: IndexPath) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        if let greetingVC = storyboard.instantiateViewController(withIdentifier: "greetingViewController") as? GreetingViewController {
//            greetingVC.titleLabel?.text = "Редактировать"
//        }
//        
//        performSegue(withIdentifier: "greetingViewController", sender: indexPath)
//        let alert = UIAlertController(title: "Редактировать", message: "Измените текст", preferredStyle: .alert)
//        alert.addTextField { textField in
//            textField.text = self.data[indexPath.row]
//        }

//        let saveAction = UIAlertAction(title: "Сохранить", style: .default) { [weak self] _ in
//            guard let self = self else { return }
//            if let newText = alert.textFields?.first?.text, !newText.isEmpty {
//                self.data[indexPath.row] = newText
//                self.tableView.reloadRows(at: [indexPath], with: .automatic) // Обновляем строку
//            }
//        }
//
//        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
//        alert.addAction(saveAction)
//        alert.addAction(cancelAction)
//        present(alert, animated: true, completion: nil)
    }
    
}
