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
        
        helpTextLabel.text =
        """
        Для расчета уровня базального метаболизма и определения необходимого калоража используется самая популярная во всем мире формула Харриса-Бенедикта.
        
        Формула была выведена американским физиологом Фрэнсисом Гано Бенедиктом и ботаником Джеймсом Артуром Харрисом еще в начале прошлого века, но до сих пор остается актуальной. Имеет погрешность всего около 5%.
        
        Для расчета калоража при похудении используется дефицит калорий в размере 20% с корректировкой пропорций белков, жиров и углеводов.
        А для набора массы, соответственно, профицит калорий в размере 20% с корректировкой пропорций белков, жиров и углеводов.
        """
    }
}
