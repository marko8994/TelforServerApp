//
//  File.swift
//  
//
//  Created by Marko Mladenovic on 27/09/2020.
//

import Foundation
import Vapor
import Fluent

public struct RoomResponse: Content {
    let room: Room
    let papers: [LightPaper]
}

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
        let room = Room.find(roomId, on: req.db).unwrap(or: Abort(.notFound))
        let papers = Paper.query(on: req.db).filter(\.$room.$id == roomId).with(\.$authors).all()
            .flatMapThrowing { papers in
                papers.map { paper in
                LightPaper(id: paper.id ?? UUID(), title: paper.title, authorNames: paper.authors.map {$0.name})
                }
            }
        return room.and(papers).map { (room, papers) -> (RoomResponse) in
            RoomResponse(room: room, papers: papers)
        }
    }
}
