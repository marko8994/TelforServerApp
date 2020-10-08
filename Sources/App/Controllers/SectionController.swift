//
//  File.swift
//  
//
//  Created by Marko Mladenovic on 07/10/2020.
//

import Foundation
import Vapor
import Fluent

final class SectionController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let userSectionRoutes = routes.grouped("api", "u", "section")
        let adminSectionRoutes = routes.grouped("api", "a", "section")
        userSectionRoutes.get("getAll", use: index)
        userSectionRoutes.get(":sectionId", use: getSection)
        adminSectionRoutes.post("add", use: create)
    }
    
    func create(req: Request) throws -> EventLoopFuture<Section> {
        let section = try req.content.decode(Section.self)
        return section.save(on: req.db).map { section }
    }
    
    func index(req: Request) throws -> EventLoopFuture<[Section]> {
        return Section.query(on: req.db).with(\.$sessions).all()
    }
    
    func getSection(req: Request) throws -> EventLoopFuture<SectionResponse> {
        guard let sectionId = req.parameters.get("sectionId", as: UUID.self) else { throw Abort(.badRequest) }
        return Section.query(on: req.db).filter(\.$id == sectionId).with(\.$sessions).first().unwrap(or: Abort(.notFound))
            .map { sectionWithSessions in
                let lightSessions = sectionWithSessions.sessions.map {
                    LightSession(id: $0.id, name: $0.name, date: $0.date)
                }
                return SectionResponse(id: sectionWithSessions.id,
                                       name: sectionWithSessions.name,
                                       sessions: lightSessions)
        }
    }
}
