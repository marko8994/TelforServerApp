//
//  File.swift
//  
//
//  Created by Marko Mladenovic on 27/09/2020.
//

import Foundation
import Vapor
import Fluent
import FluentPostgresDriver

final class Room: Model, Content {
    
    static let schema = "rooms"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String
    
    @Field(key: "map_path")
    var mapPath: String
    
    @Children(for: \.$room)
    var papers: [Paper]
    
    @Children(for: \.$room)
    var sessions: [Session]
    
    init() { }

    init(id: UUID? = nil, name: String, mapPath: String) {
        self.id = id
        self.name = name
        self.mapPath = mapPath
    }
}
