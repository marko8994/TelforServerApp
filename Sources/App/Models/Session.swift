//
//  File.swift
//  
//
//  Created by Marko Mladenovic on 07/10/2020.
//

import Foundation
import Vapor
import Fluent
import FluentPostgresDriver

final class Session: Model, Content {
    
    static let schema = "sessions"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String
    
    @Field(key: "date")
    var date: Date
    
    @Parent(key: "section_id")
    var section: Section
    
    @Parent(key: "room_id")
    var room: Room
    
    @Children(for: \.$session)
    var papers: [Paper]
    
    @Siblings(through: SessionAuthor.self, from: \.$session, to: \.$author)
    var authors: [Author]

    init() { }

    init(id: UUID? = nil, name: String, date: Date, sectionId: UUID, roomId: UUID) {
        self.id = id
        self.name = name
        self.date = date
        self.$section.id = sectionId
        self.$room.id = roomId
    }
}

