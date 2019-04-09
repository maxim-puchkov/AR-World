//
//  ViewController.swift
//  Augmented World: Augmented World
//  com.maximpuchkov.Augmented World.Augmented World.ViewController
//
//  Created by mpuchkov on 2019-04-08. macOS 10.13, Xcode 10.1.
//  Copyright © 2019 Maxim Puchkov. All rights reserved.

import Foundation

class Cache {
    
    var data = [PlaceDetailed]()
    
    func add(_ place: PlaceDetailed) {
        data.append(place)
    }
    
    func search(place: PlaceDetailed) -> PlaceDetailed? {
        for el in data {
            if (el.id == place.id) {
                return el
            }
        }
        return nil
    }
    
    func search(placeId: String) -> PlaceDetailed? {
        for el in data {
            if (el.placeId == placeId) {
                return el
            }
        }
        return nil
    }
    
}
