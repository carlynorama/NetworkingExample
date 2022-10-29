//
//  ContentView.swift
//  NetworkingExample
//
//  Created by Labtanza on 10/29/22.
//        //let url = URL(string: "https://www.hackingwithswift.com/samples/user-24601.json")!

import SwiftUI

struct Response: Codable {
    var results: [Result]
}

struct Result: Codable {
    var trackId: Int
    var trackName: String
    var collectionName: String
}

struct User:Decodable {
    var id:UUID
    var name:String
    
    static let `default` = User(id: UUID(), name: "Anonymouse")
}

struct ContentView: View {
    @State private var results = [Result]()
    var responseService = ResponseService()
    
    @State var userName = ""
    
    var body: some View {
        VStack {
            Text(userName)
            Button("Fetch User") {
                updateView()
            }
            List(results, id: \.trackId) { item in
                        VStack(alignment: .leading) {
                            Text(item.trackName)
                                .font(.headline)
                            Text(item.collectionName)
                        }
                    }
        }.task {
            await loadData()
        }
    }
    
    func updateView() {
        
        do {
            let url = try UserAPI(
                     scheme: "https",
                     host: "www.hackingwithswift.com",
                     rootPath: "/samples/").fetchUserURL(id: 24601)
             //TODO: Manage this task better
             Task {
                 userName = try await responseService.fetchValue(ofType: User.self, from: url).name
             }
            
        } catch {
            print("url did not build")
        }

    }
    
    func loadData() async {
        guard let url = URL(string: "https://itunes.apple.com/search?term=taylor+swift&entity=song") else {
            print("Invalid URL")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let decodedResponse = try? JSONDecoder().decode(Response.self, from: data) {
                results = decodedResponse.results
            }
        } catch {
            print("Invalid data")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
