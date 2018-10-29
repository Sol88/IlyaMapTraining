//
//  VKPhotoResponse.swift
//  IlyaMapTraining
//
//  Created by Kovalenko Ilia on 26/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import Foundation
import ObjectMapper

class VKPhotoResponse: Mappable {
    
    var count: Int?
    var items: [VKImage]?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        count <- map["count"]
        items <- map["items"]
    }
    
    
}
