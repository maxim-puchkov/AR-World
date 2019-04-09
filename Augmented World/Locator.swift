//
//  ViewController.swift
//  Augmented World: Augmented World
//  com.maximpuchkov.Augmented World.Augmented World.ViewController
//
//  Created by mpuchkov on 2019-04-08. macOS 10.13, Xcode 10.1.
//  Copyright © 2019 Maxim Puchkov. All rights reserved.

import Foundation
import CoreLocation
import MapKit


protocol LocatorDelegate {
    func locatorSearchResult(_: [MKMapItem])
}

class Locator {
    
    let HTTP_OK = 200
    
    let BASE_URL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
    let LOCATION = "location="
    let RADIUS = "radius="
    let KEY = "key="
    let API_KEY: String
    
    var delegate: LocatorDelegate? = nil
    
    var lastQueryTimestamp = Date()
    var lastQueryLocation: CLLocation!
    
    init() {
        let path = Bundle.main.path(forResource: "Info", ofType: "plist")
        let info = NSDictionary(contentsOfFile: path!)
        if let key = info!["Google Places API Key"] as? String {
            self.API_KEY = key
        } else {
            self.API_KEY = ""
        }
    }
    
    func canQuery() -> Bool {
        let interval = Date().timeIntervalSince(lastQueryTimestamp)
        print("Interval: \(interval)")
        return interval > 60
    }
    
    func needsUpdate(_ location: CLLocation) -> Bool {
        let distance = location.distance(from: lastQueryLocation)
        print("Distance: \(distance)")
        return distance > 100
    }
    
    func generatePath(_ location: CLLocation, within radius: Int) -> String {
        var path = BASE_URL
        path += "?\(LOCATION)\(location.coordinate.latitude),\(location.coordinate.longitude)"
        path += "&\(RADIUS)\(radius)"
        path += "&\(KEY)\(API_KEY)"
        return path
    }
    
    func generateURL(_ location: CLLocation, within radius: Int) -> URL {
        let path = generatePath(location, within: radius)
        return URL(string: path)!
    }
    
    func search(nearby location: CLLocation, within radius: Int, callback: @escaping (_ items: [MKMapItem]?, _ errorDescription: String?) -> Void) {
        print("Performing search...")
        
        let url = generateURL(location, within: radius)
        let session = URLSession()
        
        session.dataTask(with: url) { (data: Data!, response: URLResponse!, error: Error!) in
            print("Error: \(String(describing: error))")
            if (error != nil) {
                
                callback(nil, error.localizedDescription)
            }
            if let status = response as? HTTPURLResponse {
                print("Code: \(status.statusCode)")
                if (status.statusCode != self.HTTP_OK) {
                    let e = "HTTP Status code: \(status.statusCode)"
                    callback(nil, e)
                }
            }
            OperationQueue.main.addOperation {
                callback(Locator.parseFromData(data), nil)
            }
        }
        
        
        
        print("Quering \(url)")
        
        /*
         if ((canQuery() && needsUpdate(location)) || totalQueries == 0) {
         lastQueryTimestamp = Date()
         lastQueryLocation = location
         totalQueries += 1
         print("Query #\(totalQueries) executed")
         }
         */
    }
    
    func searchWithDelegate(_ location: CLLocation, within radius: Int) {
        print("Delegate will perform next search...")
        search(nearby: location, within: radius, callback: { (items, errorDescription) in
            if self.delegate != nil {
                OperationQueue.main.addOperation({
                    self.delegate?.locatorSearchResult(items!)
                })
            }
        })
    }
    
    class func parseFromData(_ data: Data) -> [MKMapItem] {
        
        print("Called")
        
        var items = [MKMapItem]()
        
        //JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
        
        let json = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
        
        var results = json["results"] as? Array<NSDictionary>
        print("results = \(results!.count)")
        
        return items
    }
    
}

