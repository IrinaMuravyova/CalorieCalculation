//
//  MenuViewController.swift
//  CalorieCalculation
//
//  Created by Irina Muravyeva on 18.11.2024.
//

import UIKit
import MessageUI

protocol MenuViewControllerDelegate: AnyObject {
    func updateChooseProfileMenu()
}

class MenuViewController: UIViewController, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emailToDeveloperButton: UIButton!
    @IBOutlet weak var aboutUsButton: UIButton!
    
    var profiles = StorageManager.shared.fetchProfiles()
    
    var receivedProfile: Profile!
//    var data = ["Item 1", "Item 2", "Item 3", "Item 4"] //  для тестирования
    weak var delegate: MenuViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(hex: "#576F72", alpha: 1)
        emailToDeveloperButton.backgroundColor = UIColor(hex: "#F8DAA8", alpha: 1)
        emailToDeveloperButton.tintColor = UIColor(hex: "#3F5B62", alpha: 1)
        emailToDeveloperButton.layer.cornerRadius = 10
        aboutUsButton.backgroundColor = UIColor(hex: "#F8DAA8", alpha: 1)
        aboutUsButton.tintColor = UIColor(hex: "#3F5B62", alpha: 1)
        aboutUsButton.layer.cornerRadius = 10
        tableView.backgroundColor = UIColor(hex: "#7D9D9C", alpha: 1)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        emailToDeveloperButton.setTitle(NSLocalizedString("email_to_developer_title", comment: ""), for: .normal)
        aboutUsButton.setTitle(NSLocalizedString("about_us_title", comment: ""), for: .normal)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
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
    func hideChoosingProfileMenu() {
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
        profiles = StorageManager.shared.fetchProfiles()
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath)
        let profile = profiles[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = profile.nickname
        content.textProperties.color = UIColor(hex: "#EEEEEE", alpha: 1)
        if let image = UIImage(named: profile.icon) {
            content.image = image
            content.imageProperties.maximumSize = CGSize(width: 30, height: 30)
        }
        cell.contentConfiguration = content
        cell.backgroundColor = UIColor(hex: "#8CA9AA", alpha: 1)

        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        NSLocalizedString("section_title", comment: "")
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = UIColor(hex: "#3F5B62", alpha: 1)
        }
    }
    
    // MARK: - Custom Footer View
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = .clear

        let footerLabel = UILabel()
        footerLabel.numberOfLines = 0 // Позволяет неограниченное количество строк
        footerLabel.text = NSLocalizedString("footer_text", comment: "")
        footerLabel.font = UIFont.systemFont(ofSize: 14)
        footerLabel.textColor = UIColor(hex: "#F0EBE3", alpha: 1)
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
        var deleteAction = UIContextualAction()

        deleteAction = UIContextualAction(style: .normal, title: deleteTitle) { [self](_, _, completionHandler) in
            
            deleteAction.backgroundColor = UIColor(hex: "#D69955", alpha: 1)
            
            if profiles[indexPath.row].nickname == receivedProfile.nickname {
                
                let title = NSLocalizedString("delete_attention_title_alert", comment: "")
                let message = NSLocalizedString("delete_attention_text_alert", comment: "")
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {_ in
                    tableView.setEditing(false, animated: true)
                }))
                present(alert, animated: true, completion: nil)
                
                completionHandler(true) // Завершаем действие
            }
            
            
            // Показать алерт для подтверждения
            let title = NSLocalizedString("sure_to_delete_title", comment: "")
            let message = NSLocalizedString("sure_to_delete_message", comment: "")
            let titleCancel = NSLocalizedString("cancel", comment: "")
            let titleDelete = NSLocalizedString("delete", comment: "")
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            // Кнопка отмены
            alert.addAction(UIAlertAction(title: titleCancel, style: .cancel, handler: { _ in
                // Отменяем редактирование строки
                tableView.setEditing(false, animated: true)
            }))
            alert.addAction(UIAlertAction(title: titleDelete, style: .destructive, handler: { _ in
                
                StorageManager.shared.deleteProfile(at: indexPath.row) // Удаляем элемент из массива
                StorageManager.shared.deleteActiveProfile()
                
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
                
                if let navigationController = self.navigationController,
                   let  mainVC = navigationController.viewControllers.first(where: { $0 is ViewController }) as? ViewController {
                    mainVC.updateChooseProfileMenu()
                    }
                
            }))
            present(alert, animated: true, completion: nil)
            
            
            
            completionHandler(true) // Завершаем действие
        }
        
        // Кнопка редактирования
        let editTitle = NSLocalizedString("edit_title_menu", comment: "")
        let editAction = UIContextualAction(style: .normal, title: editTitle) { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            performSegue(withIdentifier: "changeProfileSegue", sender: indexPath)
            completionHandler(true)
        }
        
        editAction.backgroundColor = UIColor(hex: "#F8DAA8", alpha: 1)// Настраиваем цвет кнопки редактирования
        
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
