//
//  TeamViewController.swift
//  CalorieCalculation
//
//  Created by Irina Muravyeva on 19.11.2024.
//

import UIKit

class TeamViewController: UIViewController {
    @IBOutlet weak var teamTableView: UITableView!
    var team: [TeamMember]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        teamTableView.dataSource = self
        teamTableView.delegate = self
        
        team = TeamMember.getTeam()
    }
}

// MARK: - UITableView
extension TeamViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        team.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "teamCell", for: indexPath) as? TeamViewCell else { return UITableViewCell() }
        
        let teamMember = team[indexPath.row]
        cell.photoImageView.image = UIImage(named: teamMember.photo) ?? UIImage(systemName: "person")
        cell.roleLabel.text = " " + teamMember.role
        cell.fullNameLabel.text = " " + teamMember.fullname
        
        var attributedString = setupLinks(on: cell.linkedInTextView, withLink: teamMember.linkedIn!, andTitle: "LinkedIn", defaultLink: "https://github.com")
        cell.linkedInTextView.attributedText = attributedString
        cell.linkedInTextView.delegate = self
        
        attributedString = setupLinks(on: cell.gitHubLinkTextView, withLink: teamMember.gitHub!, andTitle: "GitHub", defaultLink: "https://www.linkedin.com")
        cell.gitHubLinkTextView.attributedText = attributedString
        cell.gitHubLinkTextView.delegate = self
        
        attributedString = setupLinks(on: cell.telegramTextView, withLink: teamMember.telegram!, andTitle: "Telegram", defaultLink: "https://t.me")
        cell.telegramTextView.attributedText = attributedString
        cell.telegramTextView.delegate = self
        
        return cell
    }

}

// MARK: - Link for TextViews
extension TeamViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        UIApplication.shared.open(URL)
        return false
    }
    
    func setupLinks(on textView: UITextView, withLink link: String, andTitle title: String, defaultLink: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: title)
        let url = link

        if let url = URL(string: link) {
            attributedString.addAttribute(.link, value: url.absoluteString, range: NSRange(location: 0, length: attributedString.length))
        } else {
            attributedString.addAttribute(.link, value: defaultLink, range: NSRange(location: 0, length: attributedString.length))
        }
        
        return attributedString
    }
}
