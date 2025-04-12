import Foundation
import SwiftUI

// MARK: - Character Model

struct PetCharacter: Identifiable, Codable {
    let id: String              // Unique ID (e.g., "egg_0", "form_3_1")
    let stage: Int              // 0 = egg, 1 = stage 1, 2 = stage 2, 3 = final
    let imageName: String       // Asset name
    let nextStageIds: [String]  // Possible next evolutions
}

// MARK: - Pet Manager

class PetManager: ObservableObject {
    @Published var currentCharacter: PetCharacter

    private let storageKey = "currentCharacterID"
    private let characterMap: [String: PetCharacter]

    init() {
        // Initialize full character map
        var map: [String: PetCharacter] = [:]

        // Add 16 stage-0 eggs
        let eggIds = (0..<16).map { i -> String in
            let id = "egg_\(i)"
            map[id] = PetCharacter(
                id: id,
                stage: 0,
                imageName: id,
                nextStageIds: ["form_\(i)_1"] // Each egg has its unique stage 1 form
            )
            return id
        }

        // Add 16 stage-1 forms
        for i in 0..<16 {
            let id = "form_\(i)_1"
            map[id] = PetCharacter(
                id: id,
                stage: 1,
                imageName: id,
                nextStageIds: [] // You can define next evolutions later
            )
        }

        self.characterMap = map

        // Load saved character or assign a random egg
        if let savedId = UserDefaults.standard.string(forKey: storageKey),
           let character = characterMap[savedId] {
            self.currentCharacter = character
        } else {
            let randomEggId = eggIds.randomElement()!
            let starter = characterMap[randomEggId]!
            self.currentCharacter = starter
            UserDefaults.standard.set(starter.id, forKey: storageKey)
        }
    }

    // MARK: - Evolution

    func evolveIfEligible() {
        guard !currentCharacter.nextStageIds.isEmpty else { return }
        if let nextId = currentCharacter.nextStageIds.randomElement(),
           let nextCharacter = characterMap[nextId] {
            currentCharacter = nextCharacter
            UserDefaults.standard.set(nextId, forKey: storageKey)
        }
    }

    // MARK: - Debugging / Testing

    func resetToStart() {
        let eggIds = characterMap.values.filter { $0.stage == 0 }.map { $0.id }
        if let randomEggId = eggIds.randomElement(),
           let starter = characterMap[randomEggId] {
            currentCharacter = starter
            UserDefaults.standard.set(starter.id, forKey: storageKey)
        }
    }
}
