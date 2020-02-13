//
//  PlaceMarkerView.swift
//  Where in the World
//
//  Created by sunan xiang on 2020/2/11.
//  Copyright © 2020 sunan xiang. All rights reserved.
//

import Foundation
import MapKit

class PlaceMarkerView: MKMarkerAnnotationView {
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

        canShowCallout = true
        rightCalloutAccessoryView = UIButton(type: .infoLight)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override var annotation: MKAnnotation? {
        willSet {
            displayPriority = .defaultLow
            glyphImage = UIImage(named: "mappin.png")
        }
    }
}
