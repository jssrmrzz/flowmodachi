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
        // MARK: - Character Map Setup
        var map: [String: PetCharacter] = [:]

        // Add 16 Stage 0 Eggs with unique paths to Stage 1
        let eggIds = (0..<16).map { i -> String in
            let id = "egg_\(i)"
            map[id] = PetCharacter(
                id: id,
                stage: 0,
                imageName: id,
                nextStageIds: ["form_\(i)_1"]
            )
            return id
        }

        // Add 16 Stage 1 Forms, each mapping to its unique Stage 2
        for i in 0..<16 {
            let id = "form_\(i)_1"
            map[id] = PetCharacter(
                id: id,
                stage: 1,
                imageName: id,
                nextStageIds: ["form_\(i)_2"]
            )
        }

        // Add 16 Stage 2 Forms (lineage-aware, but no evolution to Stage 3 yet)
        for i in 0..<16 {
            let id = "form_\(i)_2"
            map[id] = PetCharacter(
                id: id,
                stage: 2,
                imageName: id,
                nextStageIds: [] // Will later add links to form_\(i)_3a, _3b, etc.
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

    // MARK: - Evolution Logic

    func evolveIfEligible() {
        guard !currentCharacter.nextStageIds.isEmpty else { return }

        if let nextId = currentCharacter.nextStageIds.randomElement(),
           let nextCharacter = characterMap[nextId] {
            currentCharacter = nextCharacter
            UserDefaults.standard.set(nextId, forKey: storageKey)

            #if DEBUG
            if NSImage(named: nextCharacter.imageName) == nil {
                print("⚠️ Missing image asset for evolved character: \(nextCharacter.imageName)")
            }
            #endif
        }
    }

    // MARK: - Debugging / Testing

    func resetToStart() {
        let eggIds = characterMap.values.filter { $0.stage == 0 }.map { $0.id }
        if let randomEggId = eggIds.randomElement(),
           let starter = characterMap[randomEggId] {
            currentCharacter = starter
            UserDefaults.standard.set(starter.id, forKey: storageKey)

            #if DEBUG
            if NSImage(named: starter.imageName) == nil {
                print("⚠️ Missing image asset for starter egg: \(starter.imageName)")
            }
            #endif
        }
    }
}

