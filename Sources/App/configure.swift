import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    app.databases.use(.postgres(hostname: "localhost", username: "postgres", password: "", database: "telfor_db"), as: .psql)

    app.migrations.add(CreateAuthor())
    app.migrations.add(CreateRoom())
    app.migrations.add(CreatePaper())
    app.migrations.add(CreateAuthorPaper())
    app.migrations.add(UpdatePaperDateField())
    app.migrations.add(CreateConference())

    // register routes
    try routes(app)
}
