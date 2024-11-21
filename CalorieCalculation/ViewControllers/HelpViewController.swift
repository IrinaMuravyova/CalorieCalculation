//
//  HelpViewController.swift
//  CalorieCalculation
//
//  Created by Irina Muravyeva on 20.11.2024.
//

import UIKit

final class HelpViewController: UIViewController {
    @IBOutlet weak var helpTextLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        helpTextLabel.text = NSLocalizedString("help_label", comment: "")
    }
}
