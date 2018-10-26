//
//  VKImage.swift
//  IlyaMapTraining
//
//  Created by Kovalenko Ilia on 26/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import Foundation
import ObjectMapper

class VKImage: Mappable {
    
    var id: Int?
    var photo604: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        photo604 <- map["photo_604"]
    }
}
