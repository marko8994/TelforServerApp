import Fluent
import Vapor
import FluentPostgresDriver

public struct AuthorResponse: Content {
    let author: Author
    let papers: [LightPaper]
}

final class AuthorController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let userAuthorRoutes = routes.grouped("api", "u", "author")
        let adminAuthorRoutes = routes.grouped("api", "a", "author")
        userAuthorRoutes.get("getAll", use: index)
        userAuthorRoutes.get(":authorId", use: getAuthor)
        adminAuthorRoutes.post("add", use: create)
    }
    
    func create(req: Request) throws -> EventLoopFuture<Author> {
        let author = try req.content.decode(Author.self)
        return author.save(on: req.db).map { author }
    }
    
    func index(req: Request) throws -> EventLoopFuture<[Author]> {
        return Author.query(on: req.db).all()
    }
    
    func getAuthor(req: Request) throws -> EventLoopFuture<AuthorResponse> {
        guard let authorId = req.parameters.get("authorId", as: UUID.self) else { throw Abort(.badRequest) }
        let author = Author.find(authorId, on: req.db).unwrap(or: Abort(.notFound))
        let papers = Paper.query(on: req.db).join(AuthorPaper.self, on: \Paper.$id == \AuthorPaper.$paper.$id)
            .filter(AuthorPaper.self, \AuthorPaper.$author.$id == authorId).with(\.$authors).all()
            .flatMapThrowing { papers in
                papers.map { paper in
                LightPaper(id: paper.id ?? UUID(), title: paper.title, authorNames: paper.authors.map {$0.name})
                }
            }
        return author.and(papers).map { (author, papers) -> (AuthorResponse) in
            AuthorResponse(author: author, papers: papers)
        }
    }
}
