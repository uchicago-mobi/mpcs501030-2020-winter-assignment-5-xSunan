//
//  DataManager.swift
//  Where in the World
//
//  Created by sunan xiang on 2020/2/11.
//  Copyright © 2020 sunan xiang. All rights reserved.
//

import Foundation

public class DataManager {
    /* structs used to decode Data.plist in xml format*/
    struct Location: Codable {
        var name: String
        var description: String
        var lat: Double
        var long: Double
        var type: Int
    }

    struct AllData: Codable {
        var places: [Location]
        var region: [Double]
    }
    
    /* useful information*/
    var allLocations = [String: Location]()
    var initialRegion = [Double]()
    let defaults = UserDefaults.standard


    public static let sharedInstance = DataManager()

    fileprivate init(){
        defaults.set([String](), forKey: "faveList")
    }
    
    func loadAnnotationFromPlist() {
        let path = Bundle.main.path(forResource: "Data", ofType: "plist")
        let xml = FileManager.default.contents(atPath: path!)
        let locations = try! PropertyListDecoder().decode(AllData.self, from: xml!)
        for place in locations.places {
            let key = place.name
            DataManager.sharedInstance.allLocations[key] = place
        }
        DataManager.sharedInstance.initialRegion = locations.region
    }
    
    func saveFavorites(location: String) {
        /* store the new favorites to the list in UserDefault*/
        var faveList = defaults.object(forKey: "faveList") as! [String]
        faveList.append(location)
        defaults.set(faveList, forKey: "faveList")
        
    }
    func deleteFavorite(location: String) {
        /* delete the new favorites to the list in UserDefault*/
        var faveList = defaults.object(forKey: "faveList") as! [String]
        if let index = faveList.firstIndex(of: location) {
            faveList.remove(at: index)
            defaults.set(faveList, forKey: "faveList")
        }
    }
}
