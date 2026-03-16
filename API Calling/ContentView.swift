//
//  ContentView.swift
//  API Calling
//
//  Created by Jensen Keele on 3/11/26.
//

import SwiftUI

struct ContentView: View {
    
    @State private var breeds: [DogBreed] = []
    
    var body: some View {
        NavigationStack {
            List(breeds) { breed in
                NavigationLink(destination: BreedDetailView(breed: breed)) {
                    Text(breed.name)
                }
            }
            .navigationTitle("Dog Breeds")
            .task {
                await loadBreeds()
            }
        }
    }
    
    func loadBreeds() async {
        do {
            let url = URL(string: "https://dog.ceo/api/breeds/list/all")!
            let (data, _) = try await URLSession.shared.data(from: url)
            
            let decoded = try JSONDecoder().decode(BreedListResponse.self, from: data)
            
            breeds = decoded.message.keys
                .map { DogBreed(name: $0.capitalized) }
                .sorted { $0.name < $1.name }
            
        } catch {
            print(error)
        }
    }
}

#Preview {
    ContentView()
}

struct BreedDetailView: View {
    
    let breed: DogBreed
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            
            Text(breed.name)
                .font(.largeTitle)
                .bold()
            
            if let facts = DogFacts.facts[breed.name] {
                ForEach(facts, id: \.self) { fact in
                    Text("• \(fact)")
                }
            } else {
                Text("Facts for this breed are not available.")
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle(breed.name)
    }
}

struct DogBreed: Identifiable {
    let id = UUID()
    let name: String
}

struct BreedListResponse: Codable {
    let message: [String: [String]]
    let status: String
}

struct DogFacts {
    
    static let facts: [String: [String]] = [
        
        "Labrador": [
            "Originally from Newfoundland, Canada.",
            "One of the most popular family dogs.",
            "Known for friendliness and intelligence."
        ],
        
        "Poodle": [
            "Originally bred in Germany.",
            "Highly intelligent and easy to train.",
            "Comes in standard, miniature, and toy sizes."
        ],
        
        "Beagle": [
            "Originally bred for hunting rabbits.",
            "Known for a strong sense of smell.",
            "Very social and energetic dogs."
        ],
        
        "Bulldog": [
            "Originated in England.",
            "Known for their wrinkled face.",
            "Typically calm and friendly companions."
        ],
        
        "Husky": [
            "Bred in Siberia as sled dogs.",
            "Very energetic and athletic.",
            "Known for their thick coat and blue eyes."
        ]
        
    ]
}
