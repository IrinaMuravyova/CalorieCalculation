//
//  Team.swift
//  CalorieCalculation
//
//  Created by Irina Muravyeva on 19.11.2024.
//

import Foundation

struct TeamMember {
    let photo: String
    let role: String
    let name: String
    let surname: String
    let linkedIn: String?
    let gitHub: String?
    let telegram: String?
    
    var fullname: String {
        name + " " + surname
    }
    
    static func getTeam() -> [TeamMember] {
        [TeamMember(
            photo:"IOSDev_IM",
            role: "IOS Разработчик",
            name: "Ирина",
            surname: "Муравьева",
            linkedIn: "https://www.linkedin.com/in/irina-muravyeva-9307982b1/",
            gitHub: "https://github.com/IrinaMuravyova",
            telegram: "https://t.me/murashek_do_murashek"
        )]
    }
}
