//
//  ContentView.swift
//  API Calling
//
//  Created by Jensen Keele on 3/11/26.
//

import SwiftUI

struct ContentView: View {
    @State private var countries: [Country] = []
    var body: some View {
        NavigationStack {
            List(countries) { country in
                NavigationLink(destination: CountryDetailView(country: country)) {
                    HStack {
                        AsyncImage(url: URL(string: country.flags.png)) { image in
                            image
                                .resizable()
                                .frame(width: 40, height: 25)
                                .cornerRadius(4)
                        } placeholder: {
                            ProgressView()
                        }
                        Text(country.name.common)
                    }
                }
            }
            .navigationTitle("Countries")
            .onAppear {
                loadData()
            }
        }
    }
    
    func loadData() {
        guard let url = URL(string: "https://restcountries.com/v3.1/all?fields=name,capital,flags") else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            do {
                let decoded = try JSONDecoder().decode([Country].self, from: data)
                DispatchQueue.main.async {
                    countries = decoded.sorted { $0.name.common < $1.name.common }
                }
            } catch {
                print(error)
            }
        }.resume()
    }
}

struct CountryDetailView: View {
    let country: Country
    var body: some View {
        VStack(spacing: 20) {
            Text(country.name.common)
                .font(.largeTitle)
                .bold()
            if let capital = country.capital?.first {
                Text("Capital: \(capital)")
                    .font(.title2)
            } else {
                Text("Capital: Unknown")
            }
            AsyncImage(url: URL(string: country.flags.png)) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
            } placeholder: {
                ProgressView()
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

struct Country: Codable, Identifiable {
    let name: Name
    let capital: [String]?
    let flags: Flag
    var id: String { name.common }
}

struct Name: Codable {
    let common: String
}

struct Flag: Codable {
    let png: String
}
