//
//  ContentView.swift
//  API Calling
//
//  Created by Jensen Keele on 3/11/26.
//

import SwiftUI

struct ContentView: View {
    @State private var countries: [Country] = []
    @State private var searchText = ""
    @State private var showAlert = false
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
            .alert(isPresented: $showAlert, content: {
                Alert(title: Text("Loading Error"), message: Text("There was a problem loading countries"))
            })
            .navigationTitle("Countries")
            .task {
                await loadData()
            }
        }
    }
    
    func loadData() async {
        if let url = URL(string: "https://restcountries.com/v3.1/all?fields=name,capital,flags") {
            if let (data, _) = try? await URLSession.shared.data(from: url) {
                if let decodedResponse = try? JSONDecoder().decode([Country].self, from: data) {
                    countries = decodedResponse
                    return
                }
            }
        }
         showAlert = true
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
