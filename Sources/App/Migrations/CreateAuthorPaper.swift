//
//  File.swift
//  
//
//  Created by Marko Mladenovic on 27/09/2020.
//

import Foundation
import Fluent

struct CreateAuthorPaper: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("author_papers")
            .id()
            .field("author_id", .uuid, .required, .references("authors", "id"))
            .field("paper_id", .uuid, .required, .references("papers", "id"))
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("author_papers").delete()
    }
}
