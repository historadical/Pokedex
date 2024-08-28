    //
    //  CacheManager.swift
    //  Pokedex
    //
    //  Created by Nic on 8/27/24.
    //

import Foundation

class CacheManager {
    
    static let shared = CacheManager()
    private var cache: [String: Pokemon] = [:]
    
    private init() {}
    
    func cachePokemon(_ pokemon: Pokemon, for name: String) {
        cache[name] = pokemon
    }
    
    func getPokemon(for name: String) -> Pokemon? {
        return cache[name]
    }
}
