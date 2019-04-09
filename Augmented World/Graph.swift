//
//  ViewController.swift
//  Augmented World: Augmented World
//  com.maximpuchkov.Augmented World.Augmented World.ViewController
//
//  Created by mpuchkov on 2019-04-08. macOS 10.13, Xcode 10.1.
//  Copyright © 2019 Maxim Puchkov. All rights reserved.


import Foundation
import UIKit

class Graph: NSObject {
    
    let kGraphSize: Int = 5
    
    let bar = UIImage(named: "bar.png")!
    var data: [Int]
    var ratios: [Double]
    
    init(place: PlaceDetailed) {
        self.data = [Int](repeating: 0, count: kGraphSize)
        self.ratios = [Double](repeating: 0, count: kGraphSize)
        if (place.reviews == nil) {
            return
        }
        var max = 0
        for review in place.reviews! {
            let index = review.rating! - 1
            self.data[index] += 1
            if (self.data[index] > max) {
                max = self.data[index]
            }
        }
        for i in 0 ..< data.count {
            self.ratios[i] = Double(data[i]) / Double(max)
        }
        print("GRAPH")
        print(self.data)
        print(self.ratios)
    }
    
}
