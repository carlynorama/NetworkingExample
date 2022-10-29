//
//  ResponseService.swift
//  NetworkingExample
//
//  Created by Labtanza on 10/29/22.
//

import Foundation

actor ResponseService {
    private let decoder = JSONDecoder()
    
    @MainActor
    func fetchValue<SomeDecodable: Decodable>(ofType:SomeDecodable.Type, from url:URL) async throws -> SomeDecodable {
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try decoder.decode(SomeDecodable.self, from: data)
        return decoded
    }
    
    func fetchTransformedValue<SomeDecodable: Decodable, Transformed>(
        ofType: SomeDecodable.Type,
        from url:URL,
        transform: @escaping (SomeDecodable) throws -> Transformed
    ) async throws -> Transformed {
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try decoder.decode(SomeDecodable.self, from: data)
        return try transform(decoded)
    }
}
