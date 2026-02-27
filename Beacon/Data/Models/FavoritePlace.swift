import SwiftData
//INFO
/// model for the favorite places saved by the user
/// also using identifier for uniqe key to avoid duplicates
@Model
public final class FavoritePlace {
	@Attribute(.unique) public var id: String
	public var name: String
	public var address: String
	public var category: String?

	public init(id: String, name: String, address: String, category: String? = nil) {
		self.id = id
		self.name = name
		self.address = address
		self.category = category
	}
}

