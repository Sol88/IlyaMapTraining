//
//  VKImageSize.swift
//  IlyaMapTraining
//
//  Created by Kovalenko Ilia on 26/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import Foundation
import ObjectMapper

class VKImageSize: Mappable {
    
    var type: String!
    var url: String!
    var width: Int!
    var height: Int!
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        type <- map["type"]
        url <- map["url"]
        width <- map["width"]
        height <- map["height"]
    }
}
