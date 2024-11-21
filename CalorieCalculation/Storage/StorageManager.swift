//
//  StorageManager.swift
//  CalorieCalculation
//
//  Created by Irina Muravyeva on 12.11.2024.
//

import Foundation

protocol StorageManagerDelegate {
    func showAlert(message: String)
}

class StorageManager {
    
    static let shared = StorageManager()
    
    private var defaults = UserDefaults.standard
    private let profilesKey = "profiles"
    private let activeProfileKey = "activeProfile"
    var delegate: StorageManagerDelegate?
    
    private init() {}
    
    func fetchProfiles() -> [Profile] {
        guard let data = defaults.data(forKey: profilesKey) else { return [] }
        let decoder = JSONDecoder()
        guard let profiles = try? decoder.decode([Profile].self, from: data) else { return [] }
        return profiles
    }
    
    func fetchActiveProfile() -> Profile {
        let newProfile = Profile( //TODO: Как то иначе обработать ошибку
            nickname: "User",
            icon: "icon1",
            age: nil,
            sex: nil,
            height: nil,
            weight: nil,
            activityLevel: nil,
            goal: nil,
            caloriesBMT: nil,
            caloriesTDEEForGoal: nil
        )
        guard let data = defaults.data(forKey: activeProfileKey) else { return newProfile }
        let decoder = JSONDecoder()
        guard let profile = try? decoder.decode(Profile.self, from: data) else { return newProfile }
        return profile
    }
    
    func add(newProfile: Profile) {
        var profiles = fetchProfiles()
        if !nickmaneIsUnique(nickname: newProfile.nickname) { return }
        profiles.append(newProfile)
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(profiles) else { return }
        defaults.set(data, forKey: profilesKey)
    }
    
    func save(changedProfile: Profile) {
        var profiles = fetchProfiles()
        
        let index = profiles.firstIndex {$0.nickname == changedProfile.nickname}
        guard let index = index else { return }
        profiles[index] = changedProfile
      
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(profiles) else { return }
        defaults.set(data, forKey: profilesKey)
    }
    
    func changeProfile(atIndex: Int, withNickname: String, andIcon: String) {
        var profiles = fetchProfiles()

        profiles[atIndex].nickname = withNickname
        profiles[atIndex].icon = andIcon

        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(profiles) else { return }
        defaults.set(data, forKey: profilesKey)
    }
    
    func saveIndexOf(activeProfile: Profile) {
        let profiles = fetchProfiles()
        
        let index = profiles.firstIndex {$0.nickname == activeProfile.nickname}
        guard let index = index else { return }
        
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(index) else { return }
        defaults.set(data, forKey: activeProfileKey)
    }
    
    func deleteProfile(at index: Int){
        var profiles = fetchProfiles()
        profiles.remove(at: index)
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(profiles) else { return }
        defaults.set(data, forKey: profilesKey)
    }
    
    func set(activeProfile: Profile) {
        let profiles = fetchProfiles()
        let profile = profiles.first{$0.nickname == activeProfile.nickname}

        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(profile) else { return }
        defaults.set(data, forKey: activeProfileKey)
    }
    
    func deleteActiveProfile() {
//        let profiles = fetchProfiles()
//        let profile = profiles.first{$0.nickname == activeProfile.nickname}
//
//        let encoder = JSONEncoder()
//        guard let data = try? encoder.encode(profile) else { return }
        defaults.set(nil, forKey: activeProfileKey)
    }
    
    func nickmaneIsUnique(nickname : String) -> Bool {
        // Проверяем, существует ли уже профиль с таким nickname
        if StorageManager.shared.fetchProfiles().contains(where: { $0.nickname == nickname }) {
            delegate?.showAlert(message: "Этот пользователь уже существует.") // Error: Nickname already exists
            return false // Возвращаем, что сохранение не удалось
        } else {
            return true
        }
    }
}
