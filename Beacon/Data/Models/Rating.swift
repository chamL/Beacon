import Foundation
import SwiftData

//INFO
/// model for saving user ratings on places
/// and used to calculate the average star rating.
@Model
public final class Rating {
	@Attribute(.unique) public var id: UUID = UUID()
	public var placeId: String
	public var value: Int
	public var createdAt: Date = Date.now

	//  THE INITIALIZER IS HERE  ************************
	public init(placeId: String, value: Int) {
		self.placeId = placeId
		self.value = value
	}
}
