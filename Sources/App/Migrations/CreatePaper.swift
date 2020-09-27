//
//  File.swift
//  
//
//  Created by Marko Mladenovic on 27/09/2020.
//

import Foundation
import Fluent

struct CreatePaper: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("papers")
            .id()
            .field("title", .string, .required)
            .field("type", .string, .required)
            .field("presentation_date", .date, .required)
            .field("summary", .string)
            .field("questions_form_path", .string)
            .field("room_id", .uuid, .references("rooms", "id"))
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("papers").delete()
    }
}
