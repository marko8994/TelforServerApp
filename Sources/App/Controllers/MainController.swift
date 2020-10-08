//
//  File.swift
//  
//
//  Created by Marko Mladenovic on 27/09/2020.
//

import Foundation

import Vapor
import Fluent

final class MainController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let mainRoutes = routes.grouped("api", "u")
        let mainAdminRoutes = routes.grouped("api", "a")
        mainRoutes.get("primaryInfo", use: getPrimaryInfo)
        mainRoutes.get("secondaryInfo", use: getSecondaryInfo)
        mainRoutes.get("tertiaryInfo", use: getTertiaryInfo)
        mainAdminRoutes.post("conference", "add", use: createConference)
    }
    
    func getPrimaryInfo(req: Request) throws -> EventLoopFuture<PrimaryInfoResponse> {
        let info = Conference.query(on: req.db).field(\.$name).field(\.$imagePaths).first().unwrap(or: Abort(.notFound))
        let sections = Section.query(on: req.db).with(\.$sessions).all().map { sectionsWithSessions in
            sectionsWithSessions.map { sectionWithSessions -> SectionResponse in
                    let lightSessions = sectionWithSessions.sessions.map {
                    LightSession(id: $0.id, name: $0.name, date: $0.date)
                }
                return SectionResponse(id: sectionWithSessions.id,
                                       name: sectionWithSessions.name,
                                       sessions: lightSessions)
            }
        }
        return info.and(sections).map { (info, sections) -> (PrimaryInfoResponse) in
            return PrimaryInfoResponse(name: info.name, imagePaths: info.imagePaths, sections: sections)
        }
    }
    
    func getSecondaryInfo(req: Request) throws -> EventLoopFuture<SecondaryInfoResponse> {
        let limit = try req.query.get(Int.self, at: "limit")
        let info = Conference.query(on: req.db).field(\.$name).field(\.$imagePaths).first().unwrap(or: Abort(.notFound))
        let authors = Author.query(on: req.db).limit(limit).all().flatMapThrowing { authors in
            authors.map { author in
                LightAuthor(id: author.id ?? UUID(), name: author.name, imagePath: author.imagePath)
            }
        }
        let papers = Paper.query(on: req.db).limit(limit).all().flatMapThrowing { papers in
            papers.map { LightPaper(id: $0.id, title: $0.title, authorNames: $0.authorNames) }
        }
        let rooms = Room.query(on: req.db).limit(limit).all().flatMapThrowing { rooms in
            rooms.map { room in
                LightRoom(id: room.id ?? UUID(), name: room.name)
            }
        }
        return info.and(authors).and(papers).and(rooms).map { (arguments) -> (SecondaryInfoResponse) in
            let (((conference, authors), papers), rooms) = arguments
            return SecondaryInfoResponse(name: conference.name, imagePaths: conference.imagePaths,
                            authors: authors, papers: papers, rooms: rooms)
        }
    }

    func getTertiaryInfo(req: Request) throws -> EventLoopFuture<Conference> {
        return Conference.query(on: req.db).first().unwrap(or: Abort(.notFound))
    }
    
    func createConference(req: Request) throws -> EventLoopFuture<Conference> {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        let conference = try req.content.decode(Conference.self, using: decoder)
        return conference.save(on: req.db).map { conference }
    }
}
