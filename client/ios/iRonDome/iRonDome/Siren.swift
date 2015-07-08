//
//  Siren.swift
//  iRonDome
//
//  Created by Arik Sosman on 7/8/15.
//  Copyright (c) 2015 Arik. All rights reserved.
//

import Foundation
import CoreData

class Siren: NSManagedObject {

    @NSManaged var alertID: NSNumber
    @NSManaged var timestamp: NSDate
    @NSManaged var areas: NSSet

}
