//
//  NetworkAPI.swift
//  TheMovieDB
//
//  Created by Greg Anderson on 3/15/18.
//  Copyright © 2018 Planet Beagle. All rights reserved.

import UIKit

enum NetworkAPIEndpoint:String {
    case topRated = "/movie/top_rated"
    case nowPlaying = "/movie/now_playing"
    case popular = "/movie/popular"
    case upcoming = "/movie/upcoming"
}

class NetworkAPI {
    static var apiKey:String? = "98cbf0f2b453fbd3e9472ffdf3ed8916"
    static let apiBaseURL = "https://api.themoviedb.org"
    static let apiVersion = "3"
    static var apiURL: String { return "\(apiBaseURL)/\(apiVersion)" }
    // TODO: Use the "configuration" API endpoint to get the latest base url and
    // supported widths for poster images.  I'm just hardcoding it here now.
    static let graphicsBaseURL = "https://image.tmdb.org/t/p/w92"
    
    // Set the Movie DB's API key
    public static func setAuthenticationParameters (apiKey: String) {
        self.apiKey = apiKey
    }
    
    // Grab the current list of movies of the chosen type; return a MovieList object.
    public static func getMoviesFromAPI (listType: NetworkAPIEndpoint,
                                         completion: @escaping (MovieList?, HTTPURLResponse?, NSError?) -> Void) {
        jsonRequest(function: listType) {
            (responseJSON, httpResponse, APIerror) in

            var error = APIerror

            // Got json?
            guard let json = responseJSON, !json.isEmpty else {
                let message = "Request returned no data"
                print ("NetworkAPI: \(message)")
                error = NSError(domain: message, code: -3, userInfo: nil)
                completion(nil, httpResponse, error)
                return
            }
            
            // Was out HTTP status ok?
            if let response = httpResponse,
                (response.statusCode < 200 || response.statusCode > 299) {
                // Bad response from the API server
                let message = "Request returned HTTP Status Code \(response.statusCode)"
                print ("NetworkAPI: \(message)")
                error = NSError(domain: message, code: -4, userInfo: nil)
            }
            
            // Convert our JSON into model objects
            
            var movies: MovieList?
            do {
                movies = try MovieList.decode(data: json.data(using: String.Encoding.utf8)!)
            }
            catch DecodingError.dataCorrupted(let context) {
                error = reportDecodingError(
                    message: "DecodingError.dataCorrupted: \(context.debugDescription)",
                    context: context)
                completion(nil, httpResponse, error)
                return
            }
            catch DecodingError.keyNotFound(let key, let context) {
                error = reportDecodingError(
                    message: "DecodingError.keyNotFound: \(key.stringValue) was not found, \(context.debugDescription)",
                    context: context)
                completion(nil, httpResponse, error)
                return
            }
            catch DecodingError.typeMismatch( _, let context) {
                error = reportDecodingError(
                    message: "DecodingError.typeMismatch: \(context.debugDescription)",
                    context: context)
                completion(nil, httpResponse, error)
                return
            }
            catch DecodingError.valueNotFound(let type, let context) {
                error = reportDecodingError(
                    message: "DecodingError.valueNotFound: No value was found for \(type), \(context.debugDescription)",
                    context: context)
                completion(nil, httpResponse, error)
                return
            }
            catch {
                let error = reportDecodingError(
                        message: "DecodingError: I know not this error",
                        context: nil)
                completion(nil, httpResponse, error)
                return
            }

            // No errors in decoding the JSON; return our movie list object
            completion(movies, httpResponse, error)
            return
        }
    }
    
    // Print some info into the log to debug the json decoding problem; return an NSError
    static func reportDecodingError (message:String, context: DecodingError.Context?) -> NSError {
        print ("NetworkAPI: \(message)")
        context?.printCodingPath()
        return NSError(domain: message, code: -5, userInfo: nil)
    }
    
    // Make a GET API request to the chosen endpoint, returning json response.
    static func jsonRequest(function: NetworkAPIEndpoint,
                            completion: @escaping (String?, HTTPURLResponse?, NSError?) -> Void) {
        
        guard let apiKey = NetworkAPI.apiKey else {
                completion (nil, nil,
                            NSError(domain: "NetworkAPI", code: -1, userInfo: nil))
                return
        }

        var urlString = NetworkAPI.apiURL + function.rawValue
        urlString += "?api_key=\(apiKey)&language=en-US&page=1"
        print ("API Request to \(urlString):")
        
        guard let url = URL(string: urlString) else {
            completion (nil, nil,
                        NSError(domain: "NetworkAPI", code: -2, userInfo: nil))
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"

        let session = URLSession(configuration: URLSessionConfiguration.ephemeral,
                                 delegate: nil,
                                 delegateQueue: OperationQueue.main)

        let task = session.dataTask(with: urlRequest) {
            (data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            if let jsonData = data {
                print ("Received JSON:")
                print (prettyPrintJSON(with: jsonData))
            }
            else {
                print ("Received no JSON in response")
            }
            
            // Request callback function:
            let e = error as NSError?, r = response as? HTTPURLResponse
            if let d = data, let json = String(data: d, encoding: .utf8) {
                completion(json, r, e)
                return
            }
            else {
                completion(nil, r, e)
                return
            }
        }
        task.resume()
    }
    
    // Fetch one poster image from the API and return it as a UIImage
    public static func getPosterImageFromAPI (posterPath: String,
                                              completion: @escaping (UIImage?, HTTPURLResponse?, NSError?) -> Void) {
        
        let urlString = NetworkAPI.graphicsBaseURL + posterPath
        print ("HTTP GET Request to \(urlString):")
        guard let url = URL(string: urlString) else {
            completion (nil, nil,
                        NSError(domain: "NetworkAPI", code: -2, userInfo: nil))
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        
        let session = URLSession(configuration: URLSessionConfiguration.ephemeral,
                                 delegate: nil,
                                 delegateQueue: OperationQueue.main)
        
        let task = session.dataTask(with: urlRequest) {
            (data: Data?, response: URLResponse?, error: Error?) -> Void in
            let e = error as NSError?, r = response as? HTTPURLResponse
            if let jpegData = data {
                completion(UIImage(data: jpegData), r, e)
                return
            }
            else {
                completion(nil, r, e)
                return
            }
        }
        task.resume()
    }

}

// Nicely formatted JSON for printing in logs
public func prettyPrintJSON(with data: Data) -> String {
    do {
        let json = try JSONSerialization.jsonObject(with: data)
        let data = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        return string! as String
    }
    catch {
        return ""
    }
}

