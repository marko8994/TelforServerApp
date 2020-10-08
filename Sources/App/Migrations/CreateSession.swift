//
//  File.swift
//  
//
//  Created by Marko Mladenovic on 07/10/2020.
//

import Foundation
import Fluent
import FluentPostgresDriver

struct CreateSession: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("sessions")
            .id()
            .field("name", .string, .required)
            .field("date", .date, .required)
            .field("section_id", .uuid, .references("sections", "id"))
            .field("room_id", .uuid, .references("rooms", "id"))
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("sessions").delete()
    }
    
}
