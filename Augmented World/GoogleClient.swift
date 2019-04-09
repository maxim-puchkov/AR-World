//
//  ViewController.swift
//  Augmented World: Augmented World
//  com.maximpuchkov.Augmented World.Augmented World.ViewController
//
//  Created by mpuchkov on 2019-04-08. macOS 10.13, Xcode 10.1.
//  Copyright © 2019 Maxim Puchkov. All rights reserved.

import Foundation
import CoreLocation


protocol GoogleClientRequest {
    
    var API_KEY : String { get set }
    
    func getGooglePlacesData(_ url: URL, using completionHandler: @escaping (GooglePlacesResponse) -> ())
    
    func getGooglePlacesDetailedData(_ url: URL, using completionHandler: @escaping (GooglePlacesDetailedResponse) -> ())
    
    func dataURL(location: CLLocation, radius: Int) -> URL
    
    func dataURL(token: String) -> URL
    
    func detailedDataURL(id: String) -> URL
    
}

class GoogleClient: GoogleClientRequest {
    
    //URL Session
    let session = URLSession(configuration: .default)
    
    let BASE_URL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
    let BASE_URL_DETAILED = "https://maps.googleapis.com/maps/api/place/details/json?placeid="
    let LOCATION = "location="
    let KEYWORD = "type="
    let RADIUS = "radius="
    let RANKBY = "rankby="
    let KEY = "key="
    let TOKEN = "pagetoken="
    
    //var API_KEY: String = "AIzaSyD_0-DgZtLAA_HhtlFCL8JhaJaR2_5q3ec"
    var API_KEY = "AIzaSyBjik4x7nYOJhVVqlMKmnB1WdVce81tj-g"
    
    init() {
        let path = Bundle.main.path(forResource: "Info", ofType: "plist")
        let info = NSDictionary(contentsOfFile: path!)
        
        //        if let key = info!["Google Places API Key Debug"] as? String {
        //            self.API_KEY = key
        //        } else {
        //            self.API_KEY = ""
        //        }
    }
    
    // Async call to make a request to google for JSON
    func getGooglePlacesData(_ url: URL, using completionHandler: @escaping (GooglePlacesResponse) -> ()) {
        let task = session.dataTask(with: url) { (responseData, _, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            do {
                let response = try JSONDecoder().decode(GooglePlacesResponse.self, from: responseData!)
                completionHandler(response)
            } catch let e {
                print(e)
            }
        }
        task.resume()
    }
    
    func getGooglePlacesDetailedData(_ url: URL, using completionHandler: @escaping (GooglePlacesDetailedResponse) -> ()) {
        let task = session.dataTask(with: url) { (responseData, _, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            do {
                let response = try JSONDecoder().decode(GooglePlacesDetailedResponse.self, from: responseData!)
                completionHandler(response)
            } catch let e {
                print(e)
            }
        }
        task.resume()
    }
    
    // create the URL to request a JSON from Google
    func dataURL(location: CLLocation, radius: Int) -> URL {
        var path = BASE_URL
        path += "?\(LOCATION)\(location.coordinate.latitude),\(location.coordinate.longitude)"
        path += "&\(RADIUS)\(radius)"
        path += "&\(KEY)\(API_KEY)"
        print(path)
        return URL(string: path)!
    }
    
    func dataURL(token: String) -> URL {
        var path = BASE_URL
        path += "?\(TOKEN)\(token)"
        path += "&\(KEY)\(API_KEY)"
        print(path)
        return URL(string: path)!
    }
    
    func detailedDataURL(id: String) -> URL {
        var path = "\(BASE_URL_DETAILED)\(id)"
        path += "&\(KEY)\(API_KEY)"
        print(path)
        return URL(string: path)!
    }
    
}
