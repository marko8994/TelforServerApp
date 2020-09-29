import Fluent
import Vapor
import FluentPostgresDriver

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
        return Author.query(on: req.db).filter(\.$id == authorId).with(\.$papers).first().unwrap(or: Abort(.notFound))
            .map { authorWithPapers in
                let lightPapers = authorWithPapers.papers.map {
                    LightPaper(id: $0.id, title: $0.title, authorNames: $0.authorNames)
                }
                return AuthorResponse(id: authorWithPapers.id, name: authorWithPapers.name,
                                      organization: authorWithPapers.organization,
                                      position: authorWithPapers.organization, imagePath: authorWithPapers.imagePath,
                                      biography: authorWithPapers.biography, papers: lightPapers)
        }
    }
}
