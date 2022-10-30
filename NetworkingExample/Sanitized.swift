////
////  Sanitized.swift
////  NetworkingExample
////
////  Created by Labtanza on 10/29/22.
////
//
//import Foundation
//
//@propertyWrapper struct Sanitized {
//    let oneOrMoreWhiteSpace = /\s+/
//    var wrappedValue: String {
//        didSet { wrappedValue = clean(wrappedValue) }
//    }
//
//    init(wrappedValue: String) {
//        self.wrappedValue = wrappedValue.capitalized
//    }
//    
//
//}


//Excessive. URLQueryItem() sanitizes for you
extension String {
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
