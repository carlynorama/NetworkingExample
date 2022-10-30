//
//  ResponseService.swift
//  NetworkingExample
//
//  Created by Labtanza on 10/29/22.
//

import Foundation

enum RequestServiceError:Error, CustomStringConvertible {
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

actor RequestService {
    private let decoder = JSONDecoder()
    private let session = URLSession.shared
    
    func fetchAsString(url:URL, encoding:String.Encoding = .utf8) async throws -> String {
        let (data, _) = try await session.data(from: url)
        guard let string = String(data: data, encoding: encoding) else {
            throw RequestServiceError("Couldn't make a string")
        }
        return string
    }
    
    func fetchValue<SomeDecodable: Decodable>(ofType:SomeDecodable.Type, from url:URL) async throws -> SomeDecodable {
        let (data, response) = try await session.data(from: url)  //TODO: catch the error here
//        print(response)
        guard checkForValidHTTP(response).isValid else {
            throw RequestServiceError("Not valid HTTP")
        }
//        if let string = String(data: data, encoding: .utf8) {
//            print(string)
//        }
        
        let decoded = try decoder.decode(SomeDecodable.self, from: data)
        return decoded
    }
    
    func fetchTransformedValue<SomeDecodable: Decodable, Transformed>(
        ofType: SomeDecodable.Type,
        from url:URL,
        transform: @escaping (SomeDecodable) throws -> Transformed
    ) async throws -> Transformed {
        let (data, response) = try await session.data(from: url)  //TODO: catch the error here
        guard checkForValidHTTP(response).isValid else {
            throw RequestServiceError("Not valid HTTP")
        }
        let decoded = try decoder.decode(SomeDecodable.self, from: data)
        return try transform(decoded)
    }
    
    func checkForValidHTTP(_ response:URLResponse) -> (isValid:Bool, mimeType:String?) {
        guard let httpResponse = response as? HTTPURLResponse,
                    (200...299).contains(httpResponse.statusCode) else {
                    self.handleServerError(response)
                    return (false, nil)
        }

        return (true, httpResponse.mimeType)
    }
    
    func handleServerError(_ response:URLResponse) {
        print(response)
    }
}
