//
//  ContentView.swift
//  NetworkingExample
//
//  Created by Labtanza on 10/29/22.
//        //let url = URL(string: "https://www.hackingwithswift.com/samples/user-24601.json")!

import SwiftUI

struct SongSearchResponse: Codable {
    var results: [Song]
}

struct Song: Codable {
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
    @State private var results = [Song]()
    
    var searchText = "Tayl-or <   Swi{ft "
    var responseService = RequestService()
    
    @State var userName = ""
    
    var body: some View {
        VStack {
            Text(searchText.searchSanitized()).border(.black)
            Text(userName)
            Button("Fetch User") {
                getUser()
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
    
//    func clean(_ input:String) -> String {
//        
//    }
    
    func getUser() {
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
        do {
            let url = try SongFetcherAPI(scheme: "https", host: "itunes.apple.com").searchURL()
            results = try await responseService.fetchValue(ofType: SongSearchResponse.self, from: url).results
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
