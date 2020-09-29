//
//  File.swift
//  
//
//  Created by Marko Mladenovic on 29/09/2020.
//

import Foundation
import Fluent

struct CreateConference: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("conference")
            .id()
            .field("name", .string, .required)
            .field("description", .string, .required)
            .field("image_paths", .string, .required)
            .field("contact_email", .string, .required)
            .field("start_date", .datetime, .required)
            .field("end_date", .datetime, .required)
            .field("survey_path", .string)
            .field("map_path", .string)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("conference").delete()
    }
}
