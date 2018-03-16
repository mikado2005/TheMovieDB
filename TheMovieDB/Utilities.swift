//
//  Utilities.swift
//  TheMovieDB
//
//  Created by Greg Anderson on 3/15/18.
//  Copyright © 2018 Planet Beagle. All rights reserved.
//

import Foundation

// Decodable Convenience Extension.
extension Decodable {
    static func decode(data: Data) throws -> Self {
        let decoder = JSONDecoder()
        // decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(Self.self, from: data)
    }
}

extension DecodingError.Context {
    func printCodingPath() {
        let cp = self.codingPath
        print("DecodingError.Context: codingPath:")
        for i in 0..<cp.count {
            print("  [\(i)] = \(cp[i])")
        }
    }
}
