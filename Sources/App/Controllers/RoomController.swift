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
        userRoomRoutes.get(":roomId", use: getRoom)
        adminRoomRoutes.post("add", use: create)
    }
    
    func create(req: Request) throws -> EventLoopFuture<Room> {
        let room = try req.content.decode(Room.self)
        return room.save(on: req.db).map { room }
    }
    
    func index(req: Request) throws -> EventLoopFuture<[Room]> {
        return Room.query(on: req.db).all()
    }
    
    func getRoom(req: Request) throws -> EventLoopFuture<RoomResponse> {
        guard let roomId = req.parameters.get("roomId", as: UUID.self) else { throw Abort(.badRequest) }
        return Room.query(on: req.db).filter(\.$id == roomId).with(\.$sessions).first().unwrap(or: Abort(.notFound))
            .map { roomWithSessions in
                let lightSessions = roomWithSessions.sessions.map {
                    LightSession(id: $0.id, name: $0.name, date: $0.date)
                }
                return RoomResponse(id: roomWithSessions.id, name: roomWithSessions.name,
                                    mapPath: roomWithSessions.mapPath, sessions: lightSessions)
        }
    }
}
