import Foundation

struct UserAccount: Identifiable, Codable, Equatable {
    enum Avatar: String, CaseIterable, Codable {
        case ana, moris, veggie, shrimp, chefHat, spoon

        var systemName: String {
            switch self {
            case .chefHat: return "takeoutbag.and.cup.and.straw.fill"
            case .spoon:   return "fork.knife"
            default:       return "person.crop.circle.fill"
            }
        }
    }

    let id: UUID
    var name: String
    var email: String
    var password: String
    var avatar: Avatar?
    var followers: Int
    var following: Int

    init(
        id: UUID = UUID(),
        name: String,
        email: String,
        password: String,
        avatar: Avatar? = nil,
        followers: Int = 0,
        following: Int = 0
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.password = password
        self.avatar = avatar
        self.followers = followers
        self.following = following
    }
}

extension UserAccount.Avatar {
    var imageName: String? {
        switch self {
        case .ana, .moris, .veggie, .shrimp:
            return rawValue
        case .chefHat, .spoon:
            return nil
        }
    }
}
