//
//  File.swift
//  
//
//  Created by Marko Mladenovic on 07/10/2020.
//

import Foundation
import Fluent
import FluentPostgresDriver


struct CreateSection: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("sections")
            .id()
            .field("name", .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("sections").delete()
    }
}
