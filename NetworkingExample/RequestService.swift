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
    
    @MainActor
    func fetchValue<SomeDecodable: Decodable>(ofType:SomeDecodable.Type, from url:URL) async throws -> SomeDecodable {
        let (data, response) = try await session.data(from: url)
        guard await checkForValidHTTP(response).isValid else {
            throw RequestServiceError("Not valid HTTP")
        }
        let decoded = try decoder.decode(SomeDecodable.self, from: data)
        return decoded
    }
    
    func fetchTransformedValue<SomeDecodable: Decodable, Transformed>(
        ofType: SomeDecodable.Type,
        from url:URL,
        transform: @escaping (SomeDecodable) throws -> Transformed
    ) async throws -> Transformed {
        let (data, _) = try await session.data(from: url)
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
