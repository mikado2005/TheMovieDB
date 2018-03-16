//
//  MovieAPIObjects.swift
//  TheMovieDB
//
//  Created by Greg Anderson on 3/15/18.
//  Copyright © 2018 Planet Beagle. All rights reserved.
//

import Foundation

public class MovieInfo: Codable {
    var title: String?
    var posterPath: String?
    var overview: String?
    private enum CodingKeys: String, CodingKey {
        case title
        case posterPath = "poster_path"
        case overview
    }
}

public class MovieList: Codable {
    var page: Int?
    var totalResults: Int?
    var totalPages: Int?
    var results: [MovieInfo]?
    private enum CodingKeys: String, CodingKey {
        case page
        case totalResults = "total_results"
        case totalPages = "total_pages"
        case results
    }
}



