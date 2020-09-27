import Fluent

struct CreateAuthor: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("authors")
            .id()
            .field("name", .string, .required)
            .field("organization", .string, .required)
            .field("position", .string, .required)
            .field("image_path", .string)
            .field("biography", .string)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("authors").delete()
    }
}
