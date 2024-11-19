//
//  TeamViewCell.swift
//  CalorieCalculation
//
//  Created by Irina Muravyeva on 19.11.2024.
//

import UIKit

class TeamViewCell: UITableViewCell {
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var roleLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var linkedInLabel: UILabel!
    @IBOutlet weak var gitHubLabel: UILabel!
    @IBOutlet weak var telegramLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//MARK: - Methods
extension TeamViewCell {
    func setupCell () {
        photoImageView.layer.cornerRadius = photoImageView.frame.width / 2
        roleLabel.backgroundColor = .gray
        roleLabel.textColor = .white
        roleLabel.font = .boldSystemFont(ofSize: 18)
        
    }
}
