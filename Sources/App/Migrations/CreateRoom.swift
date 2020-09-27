//
//  File.swift
//  
//
//  Created by Marko Mladenovic on 27/09/2020.
//

import Foundation
import Fluent

struct CreateRoom: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("rooms")
            .id()
            .field("name", .string, .required)
            .field("map_path", .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("rooms").delete()
    }
}
