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
    @Published var canRebirth = false

    private let storageKey = "currentCharacterID"
    private(set) var characterMap: [String: PetCharacter]

    init() {
        var map: [String: PetCharacter] = [:]
        var eggIds: [String] = []

        // Dynamically build characters based on existing eggs
        var index = 0
        while true {
            let eggId = "egg_\(index)"
            let form1Id = formId(index, stage: 1)

            // Check if asset exists (optional but recommended for safety)
            guard NSImage(named: eggId) != nil else { break }

            // Stage 0
            map[eggId] = PetCharacter(
                id: eggId,
                stage: 0,
                imageName: eggId,
                nextStageIds: [form1Id]
            )
            eggIds.append(eggId)

            // Stage 1
            let form2Id = formId(index, stage: 2)
            map[form1Id] = PetCharacter(
                id: form1Id,
                stage: 1,
                imageName: form1Id,
                nextStageIds: [form2Id]
            )

            // Stage 2
            let form3Id = formId(index, stage: 3)
            map[form2Id] = PetCharacter(
                id: form2Id,
                stage: 2,
                imageName: form2Id,
                nextStageIds: [form3Id]
            )

            // Stage 3
            map[form3Id] = PetCharacter(
                id: form3Id,
                stage: 3,
                imageName: form3Id,
                nextStageIds: []
            )

            index += 1
        }

        self.characterMap = map

        // Load current or assign new egg
        if let savedId = UserDefaults.standard.string(forKey: storageKey),
           let character = characterMap[savedId] {
            self.currentCharacter = character
        } else {
            let starterId = eggIds.randomElement()!
            self.currentCharacter = map[starterId]!
            UserDefaults.standard.set(starterId, forKey: storageKey)
        }
    }

    // MARK: - Evolution Logic

    func evolveIfEligible() {
        guard !currentCharacter.nextStageIds.isEmpty else {
            canRebirth = true // 🐣 evolution complete
            return
        }

        if let nextId = currentCharacter.nextStageIds.randomElement(),
           let nextCharacter = characterMap[nextId] {
            currentCharacter = nextCharacter
            UserDefaults.standard.set(nextId, forKey: storageKey)
            
            if nextCharacter.nextStageIds.isEmpty {
                canRebirth = true // Reached final stage
            }

            #if DEBUG
            if NSImage(named: nextCharacter.imageName) == nil {
                print("⚠️ Missing image asset for evolved character: \(nextCharacter.imageName)")
            }
            #endif
        }
    }


    // MARK: - Debug Reset

    func resetToStart() {
        let eggIds = characterMap.values.filter { $0.stage == 0 }.map { $0.id }
        if let randomEggId = eggIds.randomElement(),
           let starter = characterMap[randomEggId] {
            currentCharacter = starter
            UserDefaults.standard.set(starter.id, forKey: storageKey)
            canRebirth = false

            #if DEBUG
            if NSImage(named: starter.imageName) == nil {
                print("⚠️ Missing image asset for starter egg: \(starter.imageName)")
            }
            #endif
        }
    }

    // MARK: - Final Form Check

    var isFinalStage: Bool {
        currentCharacter.nextStageIds.isEmpty
    }
}

// MARK: - Global Utility

private func formId(_ i: Int, stage: Int) -> String {
    return "form_\(i)_\(stage)"
}

