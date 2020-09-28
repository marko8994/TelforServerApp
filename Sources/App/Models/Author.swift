import Fluent
import Vapor
import FluentPostgresDriver

final class Author: Model, Content {
    
    static let schema = "authors"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String
    
    @Field(key: "organization")
    var organization: String
    
    @Field(key: "position")
    var position: String
    
    @Field(key: "image_path")
    var imagePath: String?
    
    @Field(key: "biography")
    var biography: String?
    
    @Siblings(through: AuthorPaper.self, from: \.$author, to: \.$paper)
    var papers: [Paper]

    init() { }

    init(id: UUID? = nil, name: String, organization: String, position: String,
         imagePath: String? = nil, biography: String? = nil) {
        self.id = id
        self.name = name
        self.organization = organization
        self.position = position
        self.imagePath = imagePath
        self.biography = biography
    }
}
