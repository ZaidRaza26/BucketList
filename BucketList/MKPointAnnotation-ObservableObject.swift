//
//  MKPointAnnotation-ObservableObject.swift
//  BucketList
//
//  Created by Zaid Raza on 08/12/2020.
//  Copyright © 2020 Zaid Raza. All rights reserved.
//

import MapKit

extension MKPointAnnotation: ObservableObject {
    public var wrappedTitle: String {
        get {
            self.title ?? "Unknown Value"
        }
        set {
            title = newValue
        }
    }
    
    public var wrappedSubtitle: String {
        get {
            self.subtitle ?? "Unknown Value"
        }
        set {
            subtitle = newValue
        }
    }
}
