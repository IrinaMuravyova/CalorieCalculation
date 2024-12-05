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
        backgroundColor = UIColor(hex: "#7D9D9C", alpha: 1)
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
        
        contentView.layer.cornerRadius = 10
        contentView.layer.backgroundColor = UIColor(hex: "#E4DCCF", alpha: 1).cgColor
        
        // Добавление отступов для выделения границ ячейки
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10))
        
        contentView.layer.masksToBounds = false // Включаем отображение тени
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.4
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 4
        
        gitHubLinkTextView.backgroundColor = UIColor(hex: "#E4DCCF", alpha: 1)
        linkedInTextView.backgroundColor = UIColor(hex: "#E4DCCF", alpha: 1)
        telegramTextView.backgroundColor = UIColor(hex: "#E4DCCF", alpha: 1)
        
        photoImageView.layoutIfNeeded()
        photoImageView.layer.cornerRadius = photoImageView.frame.height / 2
        
        roleLabel.font = .boldSystemFont(ofSize: 18)
        roleLabel.layer.borderWidth  = 1.5
        roleLabel.layer.cornerRadius = 10
        roleLabel.textColor = UIColor(hex: "#3F5B62", alpha: 1)
        roleLabel.layer.borderColor = UIColor(hex: "#3F5B62", alpha: 1).cgColor
        
        fullNameLabel.textColor = UIColor(hex: "#3F5B62", alpha: 1)
    }
    
    
}
