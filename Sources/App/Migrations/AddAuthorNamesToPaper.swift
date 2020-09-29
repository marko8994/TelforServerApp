//
//  File.swift
//  
//
//  Created by Marko Mladenovic on 29/09/2020.
//

import Foundation
import Fluent

struct AddAuthorNamesToPaper: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("papers")
            .field("author_names", .string)
            .update()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("papers")
            .deleteField("author_names")
            .update()
    }
    
}
