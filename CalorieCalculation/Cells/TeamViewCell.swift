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
    @IBOutlet weak var linkedInTextView: UITextView!
    @IBOutlet weak var gitHubLinkTextView: UITextView!
    @IBOutlet weak var telegramTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setupCell()
    }
}

//MARK: - Methods
extension TeamViewCell {
    func setupCell () {
        //обновляю все слои, чтоб изначально корректно округлялись углы
        contentView.layoutIfNeeded()
        photoImageView.layoutIfNeeded()
    
        photoImageView.layer.cornerRadius = photoImageView.frame.height / 2
        
        roleLabel.font = .boldSystemFont(ofSize: 18)
        roleLabel.layer.borderWidth  = 1.5
        roleLabel.layer.cornerRadius = 5
        roleLabel.textColor = .darkGray
        roleLabel.layer.borderColor = UIColor.systemGray.cgColor
    }
}
