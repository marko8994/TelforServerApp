//
//  File.swift
//  
//
//  Created by Marko Mladenovic on 27/09/2020.
//

import Foundation
import Vapor
import Fluent

final class RoomController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let userRoomRoutes = routes.grouped("api", "u", "room")
        let adminRoomRoutes = routes.grouped("api", "a", "room")
        userRoomRoutes.get("getAll", use: index)
        adminRoomRoutes.post("add", use: create)
    }
    
    func create(req: Request) throws -> EventLoopFuture<Room> {
        let room = try req.content.decode(Room.self)
        return room.save(on: req.db).map { room }
    }
    
    func index(req: Request) throws -> EventLoopFuture<[Room]> {
        return Room.query(on: req.db).all()
    }
}
