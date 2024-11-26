//
//  MenuViewController.swift
//  CalorieCalculation
//
//  Created by Irina Muravyeva on 18.11.2024.
//

import UIKit
import MessageUI

class MenuViewController: UIViewController, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emailToDeveloper: UIButton!
    @IBOutlet weak var aboutUs: UIButton!
    
    let profiles = StorageManager.shared.fetchProfiles()
    var data = ["Item 1", "Item 2", "Item 3", "Item 4"] //  для тестирования
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
        
        emailToDeveloper.setTitle(NSLocalizedString("email_to_developer_title", comment: ""), for: .normal)
        aboutUs.setTitle(NSLocalizedString("about_us_title", comment: ""), for: .normal)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeProfileSegue" {
            if let profileVC = segue.destination as? GreetingViewController {
                profileVC.delegate = self
                guard let index = sender as? IndexPath else { return }
                profileVC.changingProfile = StorageManager.shared.fetchProfiles()[index.row]
            }
        }
    }
    
    @IBAction func sendEmailButton(_ sender: UIButton) {
        // Проверьте, доступна ли функция отправки писем
        if MFMailComposeViewController.canSendMail() {
            let mailComposeVC = MFMailComposeViewController()
            mailComposeVC.mailComposeDelegate = self

            // Настройте письмо
            mailComposeVC.setToRecipients(["miomir@yandex.ru"]) // адрес разработчика
            mailComposeVC.setSubject(NSLocalizedString("mail_title", comment: ""))
            mailComposeVC.setMessageBody(NSLocalizedString("mail_message", comment: ""), isHTML: false)

            // Покажите почтовый интерфейс
            present(mailComposeVC, animated: true, completion: nil)
        } else {
            let titleError = NSLocalizedString("error_title_alert", comment: "")
            // Покажите сообщение об ошибке
            let alert = UIAlertController(
                title: titleError,
                message: NSLocalizedString("mail_error", comment: ""),
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "ОК", style: .default))
            present(alert, animated: true)
            }

    // MARK: - MFMailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)

        // Обработка результата
        switch result {
        case .sent:
            print("Письмо отправлено")
        case .saved:
            print("Письмо сохранено")
        case .cancelled:
            print("Письмо отменено")
        case .failed:
            print("Ошибка отправки письма")
        @unknown default:
            break
        }
    }
    }
}

extension MenuViewController: GreetingViewControllerDelegate {
    func didUpdateProfile(_ profile: Profile) {
        if let navigationController = self.navigationController,
           let  mainVC = navigationController.viewControllers.first(where: { $0 is ViewController }) as? ViewController {
                StorageManager.shared.add(newProfile: profile)
                StorageManager.shared.set(activeProfile: profile)
                mainVC.didUpdateProfile(profile)
            }
    }
}

//MARK: - UITableView
extension MenuViewController: UITableViewDelegate, UITableViewDataSource, StorageManagerDelegate {
    func showAlert(message: String) {
        let titleError = NSLocalizedString("error_title_alert", comment: "")
        let alert = UIAlertController(title: titleError, message: message, preferredStyle: .alert)
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
        NSLocalizedString("section_title", comment: "")
    }
    
    // MARK: - Custom Footer View
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = .clear

        let footerLabel = UILabel()
        footerLabel.numberOfLines = 0 // Позволяет неограниченное количество строк
        footerLabel.text = NSLocalizedString("footer_text", comment: "")
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
        let deleteTitle = NSLocalizedString("delete_title", comment: "")
        let deleteAction = UIContextualAction(style: .destructive, title: deleteTitle) { (_, _, completionHandler) in
            StorageManager.shared.deleteProfile(at: indexPath.row) // Удаляем элемент из массива
            
        // Обновляем таблицу после удаления
            tableView.performBatchUpdates({
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }, completion: { _ in
                // Если массив пуст, открываем GreetingViewController
                if StorageManager.shared.fetchProfiles().isEmpty {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let greetingVC = storyboard.instantiateViewController(withIdentifier: "greetingViewController") as? GreetingViewController {
                        greetingVC.modalPresentationStyle = .fullScreen
                        greetingVC.delegate = self
                        self.present(greetingVC, animated: true, completion: nil)
                    }
                }
                
            })

            completionHandler(true) // Завершаем действие
        }

        // Кнопка редактирования
        let editTitle = NSLocalizedString("edit_title_menu", comment: "")
        let editAction = UIContextualAction(style: .normal, title: editTitle) { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            performSegue(withIdentifier: "changeProfileSegue", sender: indexPath)
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
