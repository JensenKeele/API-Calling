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
                        AsyncImage(url: URL(string: country.flags.png)) { image in image //downloads image from the internet while not interfering with the app
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
        guard let url = URL(string: "https://restcountries.com/v3.1/all?fields=name,capital,flags") else { return } //guard let lets an early exit in a function in case a value is nil
        URLSession.shared.dataTask(with: url) { data, response, error in // how to get the picture from the internet
            guard let data = data else { return }
            do {
                let decoded = try JSONDecoder().decode([Country].self, from: data)
                DispatchQueue.main.async {
                    countries = decoded.sorted { $0.name.common < $1.name.common }
                }
            } catch {
                print(error)
            }
        }.resume() //calls to the internet and the other code is to handle the data when it arrives
    }
}

struct CountryDetailView: View {
    let country: Country
    var body: some View {
        VStack(spacing: 20) {
            Text(country.name.common)
                .font(.largeTitle)
                .bold()
            if let capital = country.capital?.first { //checks to see if the data exists and if it does not then it doesnt run the code to prevent crashes
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
