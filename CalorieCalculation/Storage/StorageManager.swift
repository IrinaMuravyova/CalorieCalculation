//
//  StorageManager.swift
//  CalorieCalculation
//
//  Created by Irina Muravyeva on 12.11.2024.
//

import Foundation

class StorageManager {
    
    static let shared = StorageManager()
    
    private var defaults = UserDefaults.standard
    private let profilesKey = "profiles"
    private let activeProfileKey = "activeProfile"
    
    private init() {}
    
    func fetchProfiles() -> [Profile] {
        guard let data = defaults.data(forKey: profilesKey) else { return [] }
        let decoder = JSONDecoder()
        guard let profiles = try? decoder.decode([Profile].self, from: data) else { return [] }
        return profiles
    }
    
    func add(newProfile: Profile) {
        var profiles = fetchProfiles()
        profiles.append(newProfile)
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(profiles) else { return }
        defaults.set(data, forKey: profilesKey)
    }
    
    func save(changedProfile: Profile) {
        var profiles = fetchProfiles()
        
        let index = profiles.firstIndex {$0.person == changedProfile.person}
        guard let index = index else { return }
        profiles.remove(at: index)
        profiles.append(changedProfile)
        
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(profiles) else { return }
        defaults.set(data, forKey: profilesKey)
    }
    
    func deleteProfile(at index: Int){
        var profiles = fetchProfiles()
        profiles.remove(at: index)
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(profiles) else { return }
        defaults.set(data, forKey: profilesKey)
    }
    
    func saveIndexOf(activeProfile: Profile) {
        let profiles = fetchProfiles()
        
        let index = profiles.firstIndex {$0.person == activeProfile.person}
        guard let index = index else { return }
        
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(index) else { return }
        defaults.set(data, forKey: activeProfileKey)
    }
}
