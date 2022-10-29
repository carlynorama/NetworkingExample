//
//  ContentView.swift
//  NetworkingExample
//
//  Created by Labtanza on 10/29/22.
//

import SwiftUI

struct User:Decodable {
    var id:UUID
    var name:String
    
    static let `default` = User(id: UUID(), name: "Anonymouse")
}

struct ContentView: View {
    var responseService = ResponseService()
    
    @State var userName = ""
    
    var body: some View {
        Text(userName)
        Button("Fetch Data") {
            updateView()
        }
    }
    
    func updateView() {
        let url = URL(string: "https://www.hackingwithswift.com/samples/user-24601.json")!
        Task {
            userName = try await responseService.fetchValue(ofType: User.self, from: url).name
        }
            
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
