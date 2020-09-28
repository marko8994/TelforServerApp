//
//  File.swift
//  
//
//  Created by Marko Mladenovic on 28/09/2020.
//

import Foundation
import Fluent


struct UpdatePaperDateField: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("papers")
            .updateField("presentation_date", .datetime)
            .update()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("papers").delete()
    }
    
}
