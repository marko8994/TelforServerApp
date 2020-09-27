//
//  File.swift
//  
//
//  Created by Marko Mladenovic on 27/09/2020.
//

import Foundation
import Vapor
import Fluent

final class PaperController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let userPaperRoutes = routes.grouped("api", "u", "paper")
        let adminPaperRoutes = routes.grouped("api", "a", "paper")
        userPaperRoutes.get("getAll", use: index)
        adminPaperRoutes.post("add", use: create)
    }
    
    func create(req: Request) throws -> EventLoopFuture<Paper> {
        let paper = try req.content.decode(Paper.self)
        return paper.save(on: req.db).map { paper }
    }
    
    func index(req: Request) throws -> EventLoopFuture<[Paper]> {
        return Paper.query(on: req.db).all()
    }
    
}
