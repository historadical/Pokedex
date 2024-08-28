    //
    //  Pokemon.swift
    //  Pokedex
    //
    //  Created by Nic on 8/27/24.
    //

import Foundation

struct Pokemon: Decodable {
    
    let name: String
    let sprite: String
    var description: String = "No description available."
    let speciesURL: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case sprites
        case species
        
        enum SpritesKeys: String, CodingKey {
            case frontDefault = "front_default"
        }
        
        enum SpeciesKeys: String, CodingKey {
            case url
        }
    }
    
    struct Species: Decodable {
        let url: String
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let spritesContainer = try container.nestedContainer(keyedBy: CodingKeys.SpritesKeys.self, forKey: .sprites)
        
        name = try container.decode(String.self, forKey: .name)
        sprite = (try? spritesContainer.decode(String.self, forKey: .frontDefault)) ?? "No sprite available"
        
        let species = try? container.decode(Species.self, forKey: .species)
        speciesURL = species?.url
    }
}

struct PokemonSpecies: Codable {
    
    let flavorTextEntries: [FlavorTextEntry]
    
    enum CodingKeys: String, CodingKey {
        case flavorTextEntries = "flavor_text_entries"
    }
}

struct FlavorTextEntry: Codable {
    
    let flavorText: String
    let language: Language
    
    enum CodingKeys: String, CodingKey {
        case flavorText = "flavor_text"
        case language
    }
}

struct Language: Codable {
    
    let name: String
}
