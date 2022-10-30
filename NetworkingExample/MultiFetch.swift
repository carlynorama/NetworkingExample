//
//  MultiFetch.swift
//  NetworkingExample
//
//  Created by Labtanza on 10/30/22.
//  https://www.hackingwithswift.com/quick-start/concurrency/how-to-handle-different-result-types-in-a-task-group

import Foundation


// A struct we can decode from JSON, storing one message from a contact.
struct MFMessage: Decodable {
    let id: Int
    let from: String
    let message: String
}

// A user, containing their name, favorites list, and messages array.
struct MFUser {
    let username: String
    let favorites: Set<Int>?
    let messages: [MFMessage]?
}

// A single enum we'll be using for our tasks, each containing a different associated value.
enum MFFetchResult {
    case username(String)
    case favorites(Set<Int>)
    case messages([MFMessage])
}

struct MultiFetch {
    let requestService = RequestService()
    func loadUser() async -> MFUser {
        let user = await withThrowingTaskGroup(of: MFFetchResult.self) { group -> MFUser in
            group.addTask {
                let url = URL(string: "https://hws.dev/username.json")!
                let result = try await requestService.fetchAsString(url: url)
                print(result)
                return .username(result)
            }
            group.addTask {
                let url = URL(string: "https://hws.dev/user-favorites.json")!
                let result = try await requestService.fetchValue(ofType: Set<Int>.self, from: url)
                print(result)
                return .favorites(result)
            }
            group.addTask {
                let url = URL(string: "https://hws.dev/user-messages.json")!
                let result = try await requestService.fetchValue(ofType: [MFMessage].self, from: url)
                print(result)
                return .messages(result)
            }
            
            var username = "Anonymous"
            var favorites = Set<Int>()
            var messages = [MFMessage]()
            
            // Now we read out each value, figure out
            // which case it represents, and copy its
            // associated value into the right variable.
            do {
                for try await value in group {
                    switch value {
                    case .username(let value):
                        username = value
                    case .favorites(let value):
                        favorites = value
                    case .messages(let value):
                        messages = value
                    }
                }
            } catch {
                // If any of the fetches went wrong, we might
                // at least have partial data we can send back.
                print("Fetch at least partially failed; sending back what we have so far. \(error.localizedDescription)")
            }

            // Send back our user, either filled with
            // default values or using the data we
            // fetched from the server.
            return MFUser(username: username, favorites: favorites, messages: messages)
        }
        return user
    }
}
