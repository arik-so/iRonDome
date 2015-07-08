//
//  Siren.swift
//  iRonDome
//
//  Created by Arik Sosman on 7/8/15.
//  Copyright (c) 2015 Arik. All rights reserved.
//

import Foundation
import CoreData

@objc class Siren: NSManagedObject {

    @NSManaged var alertID: Int64
    @NSManaged var timestamp: NSTimeInterval
    @NSManaged var areas: NSSet

}
