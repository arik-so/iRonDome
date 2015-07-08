//
//  Area.swift
//  iRonDome
//
//  Created by Arik Sosman on 7/8/15.
//  Copyright (c) 2015 Arik. All rights reserved.
//

import Foundation
import CoreData

@objc class Area: NSManagedObject {

    @NSManaged var areaID: String
    @NSManaged var toponymShort: String
    @NSManaged var toponymLong: String
    @NSManaged var centerLatitude: NSDecimalNumber
    @NSManaged var centerLongitude: NSDecimalNumber
    @NSManaged var northEdgeLatitude: NSDecimalNumber
    @NSManaged var southEdgeLatitude: NSDecimalNumber
    @NSManaged var westEdgeLongitude: NSDecimalNumber
    @NSManaged var eastEdgeLongitude: NSDecimalNumber
    @NSManaged var sirens: NSSet

}
