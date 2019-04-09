//
//  ViewController.swift
//  Augmented World: Augmented World
//  com.maximpuchkov.Augmented World.Augmented World.ViewController
//
//  Created by mpuchkov on 2019-04-08. macOS 10.13, Xcode 10.1.
//  Copyright © 2019 Maxim Puchkov. All rights reserved.
//

import Foundation


import UIKit
import SceneKit
import ARKit
import CoreLocation


class ViewController: UIViewController, ARSCNViewDelegate, CLLocationManagerDelegate {
    
    // MARK: - Interface Builder Outlets
    
    //@IBOutlet var sceneView: ARSCNView!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var debugLabel: UILabel!
    
    @IBOutlet weak var addressBoundBox: UIView!
    @IBOutlet weak var phoneBoundBox: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var websiteBoundBox: UIView!
    @IBOutlet weak var websiteLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var ratingDescriptionLabel: UILabel!
    
    @IBOutlet var ratingStarViews: [UIView]!
    
    
    
    
    // MARK: - Constants
    let kDegreeOfLatitude: Double = 111000
    let kDegreeOfLongtitude: Double = 110567
    let kSearchRadius: Int = 500
    let kRequestLimit: Int = 20
    let kMinimumGraphLength: CGFloat = 0.025
    let kPlaceServiceNotSupported: String = "Not Available"
    let kPlaceNotRated: String = "NR"
    
    
    
    
    
    // MARK: - Properties
    
    let googleClient: GoogleClientRequest = GoogleClient()
    let locationManager = CLLocationManager()
    
    var sceneView: ARSCNView!
    var lastKnownLocation = CLLocation(latitude: 0, longitude: 0)
    var closestLocations = [Place]()
    var selectedPlace: PlaceDetailed?
    var cache = Cache()
    var anchorNames = [UUID : String]()
    
    var blocked = false
    var counter = 0
    var loaded = false
    var done = false
    
    
    
    
    
    // MARK: - View set up
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create scene view and add it to the back
        let sceneViewFrame = CGRect(x: 0, y: 0,
                                    width: self.mainView.bounds.size.width,
                                    height: self.mainView.bounds.size.height)
        self.sceneView = ARSCNView(frame: sceneViewFrame)
        self.mainView.addSubview(self.sceneView)
        self.mainView.sendSubview(toBack: self.sceneView)
        
        
        // Set the view's delegate
        self.sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        self.sceneView.showsStatistics = false
        
        // Location manager configuration
        self.configueLocationManager()
        
        // Add gesture recognizer
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(gesture:)))
        self.sceneView.addGestureRecognizer(tap)
        
        
        // Create a new scene
        // let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        // self.sceneView.scene = scene
        
        /*
         // Add a small cube -0.2 meters in front
         let cubeNode = SCNNode(geometry: SCNBox(width: 15, height: 15, length: 15, chamferRadius: 5))
         cubeNode.position = SCNVector3(36, 0, -150) // SceneKit/AR coordinates are in meters
         sceneView.scene.rootNode.addChildNode(cubeNode)
         
         let c = SCNNode(geometry: SCNBox(width: 25, height: 25, length: 25, chamferRadius: 10))
         c.position = SCNVector3(543, 0, -190) // SceneKit/AR coordinates are in meters
         sceneView.scene.rootNode.addChildNode(c)
         */
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravityAndHeading
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    
    
    
    
    // MARK: - ARSCNViewDelegate
    
    
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        let name = self.anchorNames[anchor.identifier]
        
        print("\(name)")
        
        let node = SCNNode(geometry: SCNBox(width: 15, height: 15, length: 0, chamferRadius: 0))
        node.position = SCNVector3(anchor.transform.columns.3.x, anchor.transform.columns.3.y, anchor.transform.columns.3.z) // SceneKit/AR coordinates are in meters
        sceneView.scene.rootNode.addChildNode(node)
        node.name = name
        
        node.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "selector.png")
        
        /*
         node.geometry?.firstMaterial?.diffuse.contents = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
         
         if (anchor.name! == "Mega Astana") {
         node.geometry?.firstMaterial?.diffuse.contents = UIColor(red: 0, green: 1, blue: 0, alpha: 1)
         }
         
         if (anchor.name! == "Посольство Саудовская Аравия") {
         node.geometry?.firstMaterial?.diffuse.contents = UIColor(red: 0, green: 0, blue: 1, alpha: 1)
         }
         */
        
        /*
         if (anchor.name! == "Посольство Саудовская Аравия") {
         let place = self.getNodeDescription(anchor.name!)!
         let url = self.googleClient.detailedDataURL(id: place.placeId)
         self.fetchDetailedGoogleData(url)
         }
         */
        
        return node
    }
    
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: - Locations & Anchors
    
    // Configure
    func configueLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    
    
    // Request closest locations
    func fetchGoogleData(_ url: URL) {
        print("WAIT: Fetching...")
        
        googleClient.getGooglePlacesData(url) { (response) in
            print("Counter: \(self.counter)")
            
            if (self.counter > self.kRequestLimit) {
                return
            }
            self.counter += 1
            
            self.closestLocations.append(contentsOf: response.results)
            
            if (response.results.count == 0) {
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            }
            
            if let token = response.token {
                let tokenURL = self.googleClient.dataURL(token: token)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                    self.fetchGoogleData(tokenURL)
                })
            } else {
                self.done = true
                self.printAll(self.closestLocations)
                self.placeAnchors(self.closestLocations)
            }
        }
    }
    
    
    /// Detailed results for one place
    func fetchDetailedGoogleData(place: Place) {
        
        if let selected = self.cache.search(placeId: place.placeId) {
            print("Found in the cache")
            self.selectedPlace = selected
            self.display(place: self.selectedPlace!)
            return
        }
        
        let url = self.googleClient.detailedDataURL(id: place.placeId)
        
        googleClient.getGooglePlacesDetailedData(url) { (response) in
            print("Counter: \(self.counter)")
            
            if (self.counter > 20) {
                return
            }
            self.counter += 1
            
            self.selectedPlace = response.result
            self.cache.add(self.selectedPlace!)
            
            self.display(place: self.selectedPlace!)
            print(response)
        }
        
    }
    
    
    /// Disatance from coordinates to a place
    func distance(from: CLLocation, to place: Place) -> Double {
        let loc = CLLocation(latitude: place.geometry.location.latitude, longitude: place.geometry.location.longitude)
        let dis = from.distance(from: loc)
        return dis
    }
    
    
    /// Distance from current coordinates to a place
    func distance(to place: Place) -> Double {
        let loc = CLLocation(latitude: place.geometry.location.latitude, longitude: place.geometry.location.longitude)
        let dis = self.lastKnownLocation.distance(from: loc)
        return dis
    }
    
    
    /// Distance from current coordinates to a detailed place
    func distance(to place: PlaceDetailed) -> Double {
        let loc = CLLocation(latitude: place.geometry.location.latitude, longitude: place.geometry.location.longitude)
        let dis = self.lastKnownLocation.distance(from: loc)
        return dis
    }
    
    
    
    
    // Print all results
    func printAll(_ places: [Place]) {
        var i = 1
        for place in places {
            print("\(i). \(place.name) (\(place.geometry.location.latitude), \(place.geometry.location.longitude)) at \(place.address)")
            
            let dis = distance(from: self.lastKnownLocation, to: place)
            
            let dz = self.northSouthDistance(to: place)
            let dx = self.westEastDistance(to: place)
            
            print("\t\(dis) meters away")
            print("\tDX = \(dx), DZ = \(dz)")
            i += 1
        }
    }
    
    func placeAnchors(_ places: [Place]) {
        var count = 1
        for place in places {
            
            if (distance(from: self.lastKnownLocation, to: place) > Double(kSearchRadius)) {
                continue
            }
            
            
            print("> Calculating Anchor #\(count) displacement (\(place.name))...")
            
            let latitude = place.geometry.location.latitude
            let longitude = place.geometry.location.longitude
            let location = CLLocation(latitude: latitude, longitude: longitude)
            let x = self.westEastDistance(self.lastKnownLocation, location)
            let z = self.northSouthDistance(self.lastKnownLocation, location)
            
            self.placeAnchor(place.name, x, 0, z)
            
            count += 1
        }
        
    }
    
    
    /// Place AR anchor given displacement in X, Y, Z systems
    func placeAnchor(_ name: String, _ dx: Double, _ dy: Double, _ dz: Double) {
        let size = 1000
        let radius = 0
        var translation = matrix_identity_float4x4
        translation.columns.3.x = Float(dx)
        translation.columns.3.y = Float(dy)
        translation.columns.3.z = Float(dz)
        //let anchor = ARAnchor(name: name, transform: translation)
        let anchor = ARAnchor(transform: translation)
        self.anchorNames[anchor.identifier] = name
        print("> Anchor placed: {\n\t{dx: \(dx), dy: \(dy), dz: \(dz)},\n\tsize: \(size),\n\trad: \(radius)\n}")
        print(translation)
        sceneView.session.add(anchor: anchor)
    }
    
    func northSouthDistance(_ loc1: CLLocation, _ loc2: CLLocation) -> Double {
        let lat1 = loc1.coordinate.latitude
        let lat2 = loc2.coordinate.latitude
        let dLat = lat1 - lat2
        return dLat * kDegreeOfLatitude
    }
    
    func northSouthDistance(to place: Place) -> Double {
        let latitude = place.geometry.location.latitude
        let longitude = place.geometry.location.longitude
        let location = CLLocation(latitude: latitude, longitude: longitude)
        return self.northSouthDistance(self.lastKnownLocation, location)
    }
    
    func westEastDistance(_ loc1: CLLocation, _ loc2: CLLocation) -> Double {
        let lat1 = loc1.coordinate.latitude
        let lon1 = loc1.coordinate.longitude
        let lat2 = loc2.coordinate.latitude
        let lon2 = loc2.coordinate.longitude
        let avgLat = (lat1 + lat2) / 2
        let dLon = lon2 - lon1
        let degree = cos(degToRad(avgLat)) * kDegreeOfLongtitude
        return dLon * degree
    }
    
    func westEastDistance(to place: Place) -> Double {
        let latitude = place.geometry.location.latitude
        let longitude = place.geometry.location.longitude
        let location = CLLocation(latitude: latitude, longitude: longitude)
        return self.westEastDistance(self.lastKnownLocation, location)
    }
    
    func determineBearing(from loc1: CLLocation, to loc2: CLLocation) -> Double {
        let lat1 = degToRad(loc1.coordinate.latitude)
        let lon1 = degToRad(loc1.coordinate.longitude)
        let lat2 = degToRad(loc2.coordinate.latitude)
        let lon2 = degToRad(loc2.coordinate.longitude)
        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        return atan2(y, x)
    }
    
    
    
    
    
    
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == .authorizedWhenInUse) {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (locations.first != nil) {
            self.lastKnownLocation = locations.first!
            if (self.selectedPlace != nil) {
                self.updateDistance()
            }
            if (!self.loaded) {
                self.loadLocations()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Core Location Error: \(error.localizedDescription)")
    }
    
    func loadLocations() {
        let radius = kSearchRadius
        let url = self.googleClient.dataURL(location: self.lastKnownLocation, radius: radius)
        self.fetchGoogleData(url)
        self.loaded = true
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    @objc
    func handleTap(gesture: UITapGestureRecognizer){
        if gesture.state == .ended {
            let location: CGPoint = gesture.location(in: sceneView)
            let hits = self.sceneView.hitTest(location, options: nil)
            if !hits.isEmpty {
                let tappedNode = hits.first?.node
                tappedNode!.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "selector_active.png")
                //
                print("\n")
                print(tappedNode!.name!)
                print(tappedNode!.position)
                //
                let place = self.getNodeDescription(tappedNode!.name!)!
                self.fetchDetailedGoogleData(place: place)
            }
        }
    }
    
    
    
    
    
    // MARK: - Conversions
    
    func radToDeg(_ rad: Double) -> Double {
        return rad * (180 / .pi)
    }
    
    func degToRad(_ deg: Double) -> Double {
        return deg * (.pi / 180)
    }
    
    func metersToFeet(_ meters: Double) -> Double {
        return meters / 0.3048
    }
    
    func roundToTens(x : Double) -> Int {
        return 10 * Int(round(x / 10.0))
    }
    
    func roundUp(n: Int, m: Int) -> Int {
        return n >= 0 ? ((n + m - 1) / m) * m : (n / m) * m;
    }
    
    
    
    
    
    // MARK: - Display
    
    func getNodeDescription(_ name: String) -> Place? {
        for place in self.closestLocations {
            if (place.name == name) {
                return place
            }
        }
        return nil
    }
    
    func getAddressComponent(place: PlaceDetailed, component name: String) -> String? {
        for component in place.addressComponents {
            if (component.types[0] == name) {
                return component.shortName
            }
        }
        return nil
    }
    
    func addressWithComponents(place: PlaceDetailed, components: [String], separators: [String]) -> String {
        var address: String = ""
        var counter = 0
        for component in components {
            let componentText = self.getAddressComponent(place: place, component: component)
            if (componentText != nil) {
                address += (separators[counter] + componentText!)
            }
            counter += 1
        }
        return address
    }
    
    func dispayAddress(place: PlaceDetailed) -> String {
        let index = place.formattedAddress.range(of: ",", options: .backwards)?.lowerBound
        if (index == nil) {
            return place.formattedAddress
        }
        return String(place.formattedAddress.prefix(upTo: index!))
    }
    
    
    func display(place: PlaceDetailed) {
        
        // Asynchronous thread
        DispatchQueue.main.async {
            
            // Name
            self.titleLabel.text = place.name
            
            
            // Phone
            if (place.formattedPhoneNumber != nil) {
                self.phoneLabel.text = place.formattedPhoneNumber
                let tapCall = UITapGestureRecognizer(target: self, action: #selector(self.makeCall(sender:)))
                self.phoneBoundBox.addGestureRecognizer(tapCall)
            } else {
                self.phoneLabel.text = self.kPlaceServiceNotSupported
            }
            
            
            // Website
            if (place.website != nil) {
                self.websiteLabel.text = place.website
                let tapWeb = UITapGestureRecognizer(target: self, action: #selector(self.openWeb(sender:)))
                self.websiteBoundBox.addGestureRecognizer(tapWeb)
            } else {
                self.websiteLabel.text = self.kPlaceServiceNotSupported
            }
            
            
            // Address
            let address = self.dispayAddress(place: place)
            self.addressLabel.text = address
            
            
            // Place rating
            if (place.rating != nil) {
                self.ratingLabel.text = "\(place.rating!)"
                let reviewsDescription = place.reviews!.count == 1 ? "review" : "reviews"
                self.ratingDescriptionLabel.text = "\(place.reviews!.count) \(reviewsDescription)"
            } else {
                self.ratingLabel.text = "NR"
                self.ratingDescriptionLabel.text = "0 reviews"
            }
            
            
            // Rating graph
            let graph = Graph(place: place)
            self.fillGraph(graph: graph)
            
            
            // Distance (feet)
            let distance = self.distance(to: place)
            let distanceInFeet = self.metersToFeet(distance)
            self.distanceLabel.text = "\(self.roundUp(n: Int(distanceInFeet), m: 5))"
            
        }
    }
    
    func updateDistance() {
        let distance = self.distance(to: self.selectedPlace!)
        let distanceInFeet = self.metersToFeet(distance)
        self.distanceLabel.text = "\(self.roundUp(n: Int(distanceInFeet), m: 5))"
    }
    
    
    
    
    
    
    
    
    // MARK: - Rating Graph
    
    func clearGraph() {
        for ratingStarView in self.ratingStarViews {
            for subview in ratingStarView.subviews {
                subview.removeFromSuperview()
            }
        }
    }
    
    func fillGraph(graph: Graph) {
        self.clearGraph()
        let origin = CGPoint(x: 0, y: 0)
        for i in 0 ..< self.ratingStarViews.count {
            let barImageView = UIImageView(image: graph.bar)
            let multiplier = graph.ratios[i] == 0 ?
                self.kMinimumGraphLength : CGFloat(graph.ratios[i])
            let width = self.ratingStarViews[i].frame.width * multiplier
            let height = self.ratingStarViews[i].frame.height
            let size = CGSize(width: width, height: height)
            barImageView.frame = CGRect(origin: origin, size: size)
            self.ratingStarViews[i].addSubview(barImageView)
        }
    }
    
    
    
    
    
    
    
    // MARK: - Customization & User help
    
    @objc
    func makeCall(sender: UITapGestureRecognizer) {
        var url = self.phoneLabel.text!
        url = url.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
        url = url.replacingOccurrences(of: "-", with: "", options: .literal, range: nil)
        url = url.replacingOccurrences(of: "(", with: "", options: .literal, range: nil)
        url = url.replacingOccurrences(of: ")", with: "", options: .literal, range: nil)
        url = "tel://\(url)"
        
        print("Making a call to the selected place... \(url)")
        
        DispatchQueue.main.async {
            if #available(iOS 10, *) {
                UIApplication.shared.open(URL(string: url)!)
            } else {
                UIApplication.shared.openURL(URL(string: url)!)
            }
        }
    }
    
    
    
    @objc
    func openWeb(sender: UITapGestureRecognizer) {
        print("Opening website for the selected place...")
        UIApplication.shared.openURL(NSURL(string: self.websiteLabel.text!)! as URL)
    }
    
    
    
    @objc
    func openMap(sender: UITapGestureRecognizer) {
        print("Opening map for the selected place...")
        UIApplication.shared.openURL(NSURL(string: self.websiteLabel.text!)! as URL)
    }
    
    
    
}
