    //
    //  ContentView 2.swift
    //  Pokedex
    //
    //  Created by Nic on 8/27/24.
    //

import SwiftUI

struct ContentView: View {
    
    @StateObject private var viewModel = PokemonViewModel()
    @State private var searchText: String = ""
    @State private var showError: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                    // Search Text Field
                HStack {
                    TextField("Search for a Pokemon by name or ID...", text: $searchText, onCommit: {
                        Task {
                            await viewModel.searchPokemon(name: searchText)
                            showError = viewModel.showError
                        }
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disableAutocorrection(true)
                    .accessibilityLabel("Pokemon Search Field")
                    .accessibilityHint("Enter a Pokemon name or ID to search for details.")
                    
                        // Clear Button
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .accessibilityLabel("Clear text")
                                .accessibilityHint("Clears the search field")
                        }
                        .accessibilityIdentifier("ClearButton")
                    }
                }
                .padding()
                
                    // "Did you mean..." suggestion
                    // `Int(searchText)` exists to ensure that a user searching by ID won't be shown this
                if let suggestedName = viewModel.suggestedName, suggestedName.lowercased() != searchText.lowercased(), Int(searchText) == nil {
                    Text("Did you mean \(suggestedName.capitalized)?")
                        .foregroundColor(.blue)
                        .padding()
                }
                
                    // Loading indicator
                if viewModel.isLoading {
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            .scaleEffect(2)
                            .padding()
                        
                        Text("Loading...")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Loading Indicator")
                    .accessibilityHint("Fetching Pokemon details from the network")
                    
                        // Pokemon details
                } else if let pokemon = viewModel.pokemon {
                    VStack {
                        Text(pokemon.name.capitalized)
                            .font(.largeTitle)
                            .padding()
                            .accessibilityLabel("\(pokemon.name.capitalized) Name")
                            .accessibilityHint("Displays the name of the Pokemon")
                        
                        if let spriteURL = URL(string: pokemon.sprite) {
                            AsyncImage(url: spriteURL)
                                .frame(width: 100, height: 100)
                                .padding()
                                .accessibilityLabel("\(pokemon.name.capitalized) Image")
                                .accessibilityHint("Displays the sprite image of the Pokemon")
                        }
                        
                        Text(pokemon.description)
                            .padding()
                            .accessibilityLabel("Pokemon Description")
                            .accessibilityHint("Displays the description of the Pokemon")
                    }
                    
                        // Error message
                } else if showError {
                    Text("No Pokemon found. Please try again.")
                        .foregroundColor(.red)
                        .padding()
                        .accessibilityLabel("Error Message")
                        .accessibilityHint("Displays an error message when no Pokemon is found")
                }
                
                Spacer()
            }
            .navigationTitle("Pokedex")
            .accessibilityAddTraits(.isHeader)
            .alert(isPresented: $showError) {
                Alert(
                    title: Text("Error"),
                    message: Text("No Pokemon found. Please check your spelling or try another search."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        ContentView()
    }
}
