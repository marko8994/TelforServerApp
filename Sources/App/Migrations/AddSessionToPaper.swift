//
//  File.swift
//  
//
//  Created by Marko Mladenovic on 07/10/2020.
//

import Foundation
import Fluent

struct AddSessionToPaper: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("papers")
            .field("session_id", .uuid, .references("sessions", "id"))
            .update()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("papers")
            .deleteField("session_id")
            .update()
    }
}
