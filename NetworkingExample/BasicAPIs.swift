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

//"https://itunes.apple.com/search?term=taylor+swift&entity=song"
struct SongFetcherAPI {
    let scheme:String
    let host:String
        
    struct Endpoint {
        let path: String
        let queryItems: [URLQueryItem]
    }
    
    enum ItemType:String {
        case song
        case artist
        case album
        case any
    }
    
    func songSearchURL(rawString:String) throws -> URL {
        try urlFrom(endpoint: Endpoint.search(cleanText: rawString.searchSanitized(), type: .song))
    }
    
    private func searchURL(rawString:String, resultType:ItemType) throws -> URL {
        try urlFrom(endpoint: Endpoint.search(cleanText: rawString.searchSanitized(), type: resultType))
    }
    
    private func urlFrom(endpoint:Endpoint) throws -> URL {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = endpoint.path
        components.queryItems = endpoint.queryItems
        guard let url = components.url else {
            throw APIError("Invalid url for endpoint")
        }
        print(url)
        return url
    }
}

extension SongFetcherAPI.Endpoint {
    static func search(cleanText:String, type:SongFetcherAPI.ItemType) -> Self {
        return Self(
                    path: "/search",
                    queryItems: [
                        URLQueryItem(name: "term", value: cleanText),
                        URLQueryItem(name: "entity", value: type.rawValue)
                    ]
                )
    }
}

fileprivate extension String {
    func searchSanitized() -> Self {
        let oneOrMoreWhiteSpace = /\s+/
        //let reservedCharacters = /[:\/?#\[\]@!$&'()*+,;=]/
        //let unsafeCharacters = /["<>%{}|\\^`]/
        let invertedSafeAndWhiteSpace = /[^-._~0-9a-zA-Z\s]/
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacing(invertedSafeAndWhiteSpace, with: "")
            //.replacing(reservedCharacters, with: "")
            .replacing(oneOrMoreWhiteSpace, with: "+")
    }
}




