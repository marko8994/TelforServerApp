//
//  File.swift
//  
//
//  Created by Marko Mladenovic on 07/10/2020.
//

import Foundation
import Fluent

struct UpdateDateFieldInSession: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("sessions")
            .updateField("date", .datetime)
            .update()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("sessions")
            .updateField("date", .date)
            .update()
    }
}
