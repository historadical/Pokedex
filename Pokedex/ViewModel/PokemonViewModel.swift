    //
    //  PokemonViewModel.swift
    //  Pokedex
    //
    //  Created by Nic on 8/27/24.
    //

import Foundation
import Combine

class PokemonViewModel: ObservableObject {
    
    @Published var pokemon: Pokemon?
    @Published var isLoading = false
    @Published var showError = false
    @Published var allPokemonNames: [String] = []
    @Published var suggestedName: String? = nil
    
    init() {
        Task {
            await loadAllPokemonNames()
        }
    }
    
    private func loadAllPokemonNames() async {
        let result = await NetworkController.shared.fetchAllPokemonNames()
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            switch result {
                case .success(let names):
                    self.allPokemonNames = names
                case .failure(let error):
                    print("Failed to fetch all Pokemon names: \(error)")
            }
        }
    }
    
    func searchPokemon(name: String) async {
        guard !name.isEmpty else {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.showError = true
            }
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.isLoading = true
            self.showError = false
        }
        
        if let pokedexNumber = Int(name) {
            await performSearch(with: String(pokedexNumber))
            return
        }
        
        if let cachedPokemon = CacheManager.shared.getPokemon(for: name) {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.pokemon = cachedPokemon
                self.isLoading = false
                self.suggestedName = nil
            }
            return
        }
        
        let searchName = allPokemonNames.contains(name.lowercased()) ? name : (closestPokemonName(to: name, from: allPokemonNames) ?? name)
        
        if searchName.lowercased() != name.lowercased() {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.suggestedName = searchName
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.suggestedName = nil
            }
        }
        
        await performSearch(with: searchName.lowercased())
    }
    
    private func performSearch(with searchTerm: String) async {
        let result = await NetworkController.shared.fetchPokemon(name: searchTerm)
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            switch result {
                case .success(let pokemon):
                    CacheManager.shared.cachePokemon(pokemon, for: searchTerm)
                    self.pokemon = pokemon
                case .failure:
                    self.showError = true
            }
            self.isLoading = false
        }
    }
    
    private func closestPokemonName(to input: String, from pokemonList: [String]) -> String? {
        guard !pokemonList.isEmpty else { return nil }
        
        var closestName: String? = nil
        var closestDistance = Int.max
        
        for name in pokemonList {
            let distance = levenshtein(input.lowercased(), name.lowercased())
            if distance < closestDistance {
                closestDistance = distance
                closestName = name
            }
        }
        return closestName
    }
}
