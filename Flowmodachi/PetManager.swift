import Foundation
import SwiftUI

// MARK: - Global Helper Functions

private func assetExists(_ imageName: String) -> Bool {
    return NSImage(named: imageName) != nil
}

private func createFallbackCharacter(stage: Int) -> PetCharacter {
    let fallbackId = "fallback_stage_\(stage)"
    let systemImage = stage == 0 ? "questionmark.circle" : "exclamationmark.triangle"
    return PetCharacter(
        id: fallbackId,
        stage: stage,
        imageName: systemImage,
        nextStageIds: stage < 3 ? ["fallback_stage_\(stage + 1)"] : [],
        isPlaceholder: true
    )
}

// MARK: - Character Model

struct PetCharacter: Identifiable, Codable {
    let id: String              // Unique ID (e.g., "egg_0", "form_3_1")
    let stage: Int              // 0 = egg, 1 = stage 1, 2 = stage 2, 3 = final
    let imageName: String       // Asset name
    let nextStageIds: [String]  // Possible next evolutions
    let isPlaceholder: Bool     // True if this is a fallback character
    
    init(id: String, stage: Int, imageName: String, nextStageIds: [String], isPlaceholder: Bool = false) {
        self.id = id
        self.stage = stage
        self.imageName = imageName
        self.nextStageIds = nextStageIds
        self.isPlaceholder = isPlaceholder
    }
}

// MARK: - Pet Manager

class PetManager: ObservableObject {
    @Published var currentCharacter: PetCharacter
    @Published var canRebirth = false

    private let storageKey = "currentCharacterID"
    private(set) var characterMap: [String: PetCharacter]
    private let fallbackCharacters: [PetCharacter]

    init() {
        var map: [String: PetCharacter] = [:]
        var eggIds: [String] = []
        var fallbacks: [PetCharacter] = []

        // Create fallback characters for each stage
        for stage in 0...3 {
            let fallback = createFallbackCharacter(stage: stage)
            fallbacks.append(fallback)
            map[fallback.id] = fallback
        }
        self.fallbackCharacters = fallbacks

        // Dynamically build characters based on existing eggs
        var index = 0
        var hasValidAssets = false
        
        while index < 100 { // Safety limit to prevent infinite loops
            let eggId = "egg_\(index)"
            let form1Id = formId(index, stage: 1)
            let form2Id = formId(index, stage: 2)
            let form3Id = formId(index, stage: 3)

            // Check if egg asset exists
            guard assetExists(eggId) else { 
                if index == 0 {
                    print("⚠️ No egg_0 asset found. Using fallback character system.")
                }
                break 
            }
            
            hasValidAssets = true

            // Validate all stage assets exist, use fallbacks if not
            let stage1Valid = assetExists(form1Id)
            let stage2Valid = assetExists(form2Id)
            let stage3Valid = assetExists(form3Id)

            // Stage 0 (Egg)
            map[eggId] = PetCharacter(
                id: eggId,
                stage: 0,
                imageName: eggId,
                nextStageIds: stage1Valid ? [form1Id] : [fallbacks[1].id]
            )
            eggIds.append(eggId)

            // Stage 1
            if stage1Valid {
                map[form1Id] = PetCharacter(
                    id: form1Id,
                    stage: 1,
                    imageName: form1Id,
                    nextStageIds: stage2Valid ? [form2Id] : [fallbacks[2].id]
                )
            }

            // Stage 2
            if stage2Valid {
                map[form2Id] = PetCharacter(
                    id: form2Id,
                    stage: 2,
                    imageName: form2Id,
                    nextStageIds: stage3Valid ? [form3Id] : [fallbacks[3].id]
                )
            }

            // Stage 3
            if stage3Valid {
                map[form3Id] = PetCharacter(
                    id: form3Id,
                    stage: 3,
                    imageName: form3Id,
                    nextStageIds: []
                )
            }

            index += 1
        }

        self.characterMap = map

        // Load current character or assign fallback
        var currentChar: PetCharacter
        
        if let savedId = UserDefaults.standard.string(forKey: storageKey),
           let character = characterMap[savedId] {
            // Validate saved character still has valid asset
            if !character.isPlaceholder && !assetExists(character.imageName) {
                print("⚠️ Saved character asset missing: \(character.imageName). Using fallback.")
                currentChar = fallbacks[character.stage]
            } else {
                currentChar = character
            }
        } else if hasValidAssets && !eggIds.isEmpty {
            let starterId = eggIds.randomElement()!
            currentChar = map[starterId]!
            UserDefaults.standard.set(starterId, forKey: storageKey)
        } else {
            // No valid assets found, use fallback egg
            print("⚠️ No valid character assets found. Using fallback system.")
            currentChar = fallbacks[0]
            UserDefaults.standard.set(currentChar.id, forKey: storageKey)
        }
        
        self.currentCharacter = currentChar
    }

    // MARK: - Evolution Logic

    func evolveIfEligible() {
        guard !currentCharacter.nextStageIds.isEmpty else {
            canRebirth = true // 🐣 evolution complete
            return
        }

        if let nextId = currentCharacter.nextStageIds.randomElement(),
           let nextCharacter = characterMap[nextId] {
            
            // Validate asset exists before evolving
            var characterToUse = nextCharacter
            if !nextCharacter.isPlaceholder && !assetExists(nextCharacter.imageName) {
                print("⚠️ Missing image asset for evolved character: \(nextCharacter.imageName). Using fallback.")
                characterToUse = fallbackCharacters[min(nextCharacter.stage, fallbackCharacters.count - 1)]
            }
            
            currentCharacter = characterToUse
            UserDefaults.standard.set(characterToUse.id, forKey: storageKey)
            
            if characterToUse.nextStageIds.isEmpty {
                canRebirth = true // Reached final stage
            }
        } else {
            // Fallback to stage-appropriate fallback character
            let nextStage = min(currentCharacter.stage + 1, 3)
            let fallbackChar = fallbackCharacters[nextStage]
            print("⚠️ Evolution failed. Using fallback character for stage \(nextStage).")
            
            currentCharacter = fallbackChar
            UserDefaults.standard.set(fallbackChar.id, forKey: storageKey)
            
            if fallbackChar.nextStageIds.isEmpty {
                canRebirth = true
            }
        }
    }


    // MARK: - Debug Reset

    func resetToStart() {
        let validEggIds = characterMap.values
            .filter { $0.stage == 0 && !$0.isPlaceholder }
            .map { $0.id }
        
        var newCharacter: PetCharacter
        
        if let randomEggId = validEggIds.randomElement(),
           let starter = characterMap[randomEggId],
           assetExists(starter.imageName) {
            newCharacter = starter
        } else {
            // No valid eggs available, use fallback
            print("⚠️ No valid egg assets found during reset. Using fallback.")
            newCharacter = fallbackCharacters[0]
        }
        
        currentCharacter = newCharacter
        UserDefaults.standard.set(newCharacter.id, forKey: storageKey)
        canRebirth = false
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

