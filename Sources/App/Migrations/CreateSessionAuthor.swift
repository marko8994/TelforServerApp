//
//  File.swift
//  
//
//  Created by Marko Mladenovic on 07/10/2020.
//

import Foundation
import Fluent

struct CreateSessionAuthor: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("sessions_authors")
            .id()
            .field("session_id", .uuid, .required, .references("sessions", "id"))
            .field("author_id", .uuid, .required, .references("authors", "id"))
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("sessions_authors").delete()
    }
}
