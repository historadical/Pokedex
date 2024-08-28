    //
    //  NetworkController.swift
    //  Pokedex
    //
    //  Created by Nic on 8/27/24.
    //

import Foundation

enum NetworkError: Error {
    
    case invalidURL
    case invalidResponse
    case decodingError
}

class NetworkController {
    
    static let shared = NetworkController()
    private let session = URLSession.shared
    
    func fetchAllPokemonNames() async -> Result<[String], NetworkError> {
        guard let url = URL(string: "\(Constants.baseURL)/pokemon?limit=10000") else {
            return .failure(.invalidURL)
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return .failure(.invalidResponse)
            }
            
            let result = try JSONDecoder().decode(PokemonListResult.self, from: data)
            return .success(result.results.map { $0.name })
        } catch {
            return .failure(.decodingError)
        }
    }
    
    func fetchPokemon(name: String) async -> Result<Pokemon, NetworkError> {
        guard let pokemonURL = URL(string: "\(Constants.baseURL)/pokemon/\(name)") else {
            return .failure(.invalidURL)
        }
        
        do {
            let (pokemonData, response) = try await session.data(from: pokemonURL)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return .failure(.invalidResponse)
            }
            
            var pokemon = try JSONDecoder().decode(Pokemon.self, from: pokemonData)
            
            if let speciesURLString = pokemon.speciesURL, let speciesURL = URL(string: speciesURLString) {
                do {
                    let (speciesData, speciesResponse) = try await session.data(from: speciesURL)
                    
                    guard let speciesHttpResponse = speciesResponse as? HTTPURLResponse, speciesHttpResponse.statusCode == 200 else {
                        return .success(pokemon) // Return Pokemon without species data
                    }
                    
                    let speciesInfo = try JSONDecoder().decode(PokemonSpecies.self, from: speciesData)
                    
                    if let englishFlavorText = speciesInfo.flavorTextEntries.first(where: { $0.language.name == "en" })?.flavorText {
                        pokemon.description = englishFlavorText.replacingOccurrences(of: "\n", with: " ")
                    }
                    
                } catch {
                    print("Failed to fetch species data: \(error)")
                    return .success(pokemon)
                }
            } else {
                print("No species URL available")
            }
            
            return .success(pokemon)
        } catch {
            return .failure(.decodingError)
        }
    }
}

struct PokemonListResult: Codable {
    
    let results: [PokemonListEntry]
}

struct PokemonListEntry: Codable {
    
    let name: String
}
