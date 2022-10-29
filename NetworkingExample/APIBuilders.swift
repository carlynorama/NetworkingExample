//
//  URLBuilder.swift
//  NetworkingExample
//
//  Created by Labtanza on 10/29/22.
//

import Foundation

enum APIError: Error, CustomStringConvertible {
    case message(String)
    var description: String {
        switch self {
        case let .message(message): return message
        }
    }
    init(_ message: String) {
        self = .message(message)
    }
}

struct Endpoint {
    let path: String
    let queryItems: [URLQueryItem]
}

//"https://www.hackingwithswift.com/samples/user-24601.json"
struct UserAPI {
    let scheme:String
    let host:String
    let rootPath:String
    
    let idKey = "{id}"
    let fileName = "user-{id}.json"
    
    func fetchUserURL(id:Int) throws -> URL {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = rootPath + fileName.replacingOccurrences(of: idKey, with: "\(id)")
        guard let url = components.url else {
            throw APIError("Invalid url for \(id)")
        }
        return url
    }
}

