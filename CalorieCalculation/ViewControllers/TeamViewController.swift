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
        cell.roleLabel.text = teamMember.role
        cell.fullNameLabel.text = teamMember.fullname
        cell.linkedInLabel.text = teamMember.linkedIn
        cell.gitHubLabel.text = teamMember.gitHub
        cell.telegramLabel.text = teamMember.telegram
        return cell
    }
    
    
}
