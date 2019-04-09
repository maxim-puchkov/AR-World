//
//  ViewController.swift
//  Augmented World: Augmented World
//  com.maximpuchkov.Augmented World.Augmented World.ViewController
//
//  Created by mpuchkov on 2019-04-08. macOS 10.13, Xcode 10.1.
//  Copyright © 2019 Maxim Puchkov. All rights reserved.
//

import Foundation


struct GooglePlacesResponse : Codable {
    let status : String
    let token : String?
    let results : [Place]
    enum CodingKeys: String, CodingKey {
        case status = "status"
        case token = "next_page_token"
        case results = "results"
    }
}

struct Place : Codable {
    let id : String
    let placeId : String
    let geometry : Location
    let name : String
    let openingHours : OpenNow?
    let photos : [PhotoInfo]?
    let types : [String]
    let address : String
    let rating : Double?
    var distance : Double?
    enum CodingKeys : String, CodingKey {
        case id = "id"
        case placeId = "place_id"
        case geometry = "geometry"
        case name = "name"
        case openingHours = "opening_hours"
        case photos = "photos"
        case types = "types"
        case address = "vicinity"
        case rating = "rating"
    }
    struct OpenNow : Codable {
        let open : Bool
        enum CodingKeys : String, CodingKey {
            case open = "open_now"
        }
    }
    struct PhotoInfo : Codable {
        let height : Int
        let width : Int
        let photoReference : String
        enum CodingKeys : String, CodingKey {
            case height = "height"
            case width = "width"
            case photoReference = "photo_reference"
        }
    }
}

struct GooglePlacesDetailedResponse : Codable {
    let status : String
    let result : PlaceDetailed
    enum CodingKeys : String, CodingKey {
        case status = "status"
        case result = "result"
    }
}

struct PlaceDetailed : Codable {
    let geometry : Location
    let addressComponents : [AddressComponent]
    let adrAddress : String
    let formattedAddress : String
    let formattedPhoneNumber : String?
    let internationalPhoneNumber : String?
    let name : String
    let id : String
    let placeId : String
    let rating : Double?
    let reviews : [Review]?
    let types : [String]
    let url : String?
    let vicinity : String?
    let website : String?
    enum CodingKeys : String, CodingKey {
        case geometry = "geometry"
        case addressComponents = "address_components"
        case adrAddress = "adr_address"
        case formattedAddress = "formatted_address"
        case formattedPhoneNumber = "formatted_phone_number"
        case internationalPhoneNumber = "international_phone_number"
        case name = "name"
        case id = "id"
        case placeId = "place_id"
        case rating = "rating"
        case reviews = "reviews"
        case types = "types"
        case url = "url"
        case vicinity = "vicinity"
        case website = "website"
    }
    struct AddressComponent : Codable {
        let longName : String
        let shortName : String
        let types : [String]
        enum CodingKeys : String, CodingKey {
            case longName = "long_name"
            case shortName = "short_name"
            case types = "types"
        }
    }
    struct Review : Codable {
        let authorName : String
        let authorUrl : String
        let language : String?
        let profilePhotoUrl : String?
        let rating : Int?
        let relativeTimeDescription : String
        let text : String
        let time : Int
        enum CodingKeys : String, CodingKey {
            case authorName = "author_name"
            case authorUrl = "author_url"
            case language = "language"
            case profilePhotoUrl = "profile_photo_url"
            case rating = "rating"
            case relativeTimeDescription = "relative_time_description"
            case text = "text"
            case time = "time"
        }
    }
}

struct Location : Codable {
    let location : LatLong
    enum CodingKeys: String, CodingKey {
        case location = "location"
    }
    struct LatLong : Codable {
        let latitude : Double
        let longitude : Double
        enum CodingKeys : String, CodingKey {
            case latitude = "lat"
            case longitude = "lng"
        }
    }
}
