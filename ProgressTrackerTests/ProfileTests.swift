import Foundation
import Testing
import UIKit
@testable import ProgressTracker

struct ProfileDraftTests {
    private let user = User(firstName: "Alex", avatarName: "Avatar", email: "alex@example.com")

    @Test func startsFromTheUserAndHasNoChanges() {
        let draft = ProfileDraft(user: user)
        #expect(draft.firstName == "Alex")
        #expect(draft.email == "alex@example.com")
        #expect(draft.avatar == .keep)
        #expect(draft.isValid)
        #expect(!draft.hasChanges(from: user))
    }

    @Test func detectsChangesInEachField() {
        var draft = ProfileDraft(user: user)
        draft.firstName = "Sam"
        #expect(draft.hasChanges(from: user))

        draft = ProfileDraft(user: user)
        draft.email = "sam@example.com"
        #expect(draft.hasChanges(from: user))

        draft = ProfileDraft(user: user)
        draft.avatar = .remove
        #expect(draft.hasChanges(from: user))
    }

    @Test func whitespaceAndCaseAloneAreNotChanges() {
        var draft = ProfileDraft(user: user)
        draft.firstName = "  Alex "
        draft.email = " ALEX@example.com "
        #expect(!draft.hasChanges(from: user))
    }

    @Test func validationRequiresANameAndAValidEmail() {
        var draft = ProfileDraft(user: user)
        draft.firstName = "   "
        #expect(!draft.isValid)

        draft.firstName = "Alex"
        draft.email = "not-an-email"
        #expect(!draft.isValid)
    }
}

@MainActor
struct AvatarAndProfileUpdateTests {
    private func temporaryStore() -> AvatarStore {
        AvatarStore(directory: FileManager.default.temporaryDirectory.appending(path: "avatars-\(UUID().uuidString)"))
    }

    private func makeDefaults() -> UserDefaults {
        let name = "profile-tests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        return defaults
    }

    // Une vraie image PNG (le stockage décode l'image avant de la réduire).
    private func imageData(side: CGFloat = 1200) -> Data {
        UIGraphicsImageRenderer(size: CGSize(width: side, height: side / 2)).pngData { context in
            UIColor.systemPurple.setFill()
            context.fill(CGRect(origin: .zero, size: CGSize(width: side, height: side / 2)))
        }
    }

    private func loggedInViewModel(store: AvatarStore, defaults: UserDefaults) async -> AuthViewModel {
        let viewModel = AuthViewModel(provider: MockAuthProvider(delay: .zero), defaults: defaults, avatarStore: store)
        _ = await viewModel.logIn(email: "alex@example.com", password: "secret")
        return viewModel
    }

    // MARK: - AvatarStore

    @Test func storeSavesAResizedJPEGAndCanRemoveIt() throws {
        let store = temporaryStore()
        let name = try store.save(imageData(side: 2000))

        let saved = try #require(UIImage(contentsOfFile: store.url(for: name).path))
        #expect(max(saved.size.width, saved.size.height) <= 600)      // réduite à 600 px

        store.remove(name)
        #expect(!FileManager.default.fileExists(atPath: store.url(for: name).path))
    }

    @Test func storeRejectsDataThatIsNotAnImage() {
        #expect(throws: (any Error).self) { try temporaryStore().save(Data("not an image".utf8)) }
    }

    // MARK: - updateProfile

    @Test func updatingNameAndEmailIsPersisted() async {
        let defaults = makeDefaults()
        let store = temporaryStore()
        let viewModel = await loggedInViewModel(store: store, defaults: defaults)

        var draft = ProfileDraft(user: viewModel.currentUser!)
        draft.firstName = "  Sam "
        draft.email = "SAM@Example.com"
        viewModel.updateProfile(draft)

        #expect(viewModel.session?.firstName == "Sam")
        #expect(viewModel.session?.email == "sam@example.com")

        // Relancement : même suite de réglages, nouveau ViewModel.
        let relaunched = AuthViewModel(provider: MockAuthProvider(delay: .zero), defaults: defaults, avatarStore: store)
        #expect(relaunched.currentUser?.firstName == "Sam")
        #expect(relaunched.currentUser?.email == "sam@example.com")
    }

    @Test func invalidDraftIsIgnored() async {
        let viewModel = await loggedInViewModel(store: temporaryStore(), defaults: makeDefaults())
        var draft = ProfileDraft(user: viewModel.currentUser!)
        draft.firstName = ""
        viewModel.updateProfile(draft)

        #expect(viewModel.session?.firstName == "Alex")
    }

    @Test func replacingThePhotoStoresItAndRemovingItDeletesTheFile() async throws {
        let store = temporaryStore()
        let viewModel = await loggedInViewModel(store: store, defaults: makeDefaults())
        #expect(viewModel.currentUser?.avatarURL == nil)

        var draft = ProfileDraft(user: viewModel.currentUser!)
        draft.avatar = .replace(imageData())
        viewModel.updateProfile(draft)

        let url = try #require(viewModel.currentUser?.avatarURL)
        #expect(FileManager.default.fileExists(atPath: url.path))

        var removal = ProfileDraft(user: viewModel.currentUser!)
        removal.avatar = .remove
        viewModel.updateProfile(removal)

        #expect(viewModel.currentUser?.avatarURL == nil)
        #expect(!FileManager.default.fileExists(atPath: url.path))
    }

    @Test func replacingAgainDeletesThePreviousPhoto() async throws {
        let store = temporaryStore()
        let viewModel = await loggedInViewModel(store: store, defaults: makeDefaults())

        var first = ProfileDraft(user: viewModel.currentUser!)
        first.avatar = .replace(imageData())
        viewModel.updateProfile(first)
        let firstURL = try #require(viewModel.currentUser?.avatarURL)

        var second = ProfileDraft(user: viewModel.currentUser!)
        second.avatar = .replace(imageData(side: 800))
        viewModel.updateProfile(second)

        #expect(!FileManager.default.fileExists(atPath: firstURL.path))
        #expect(viewModel.currentUser?.avatarURL != nil)
    }

    @Test func homeCanReceiveTheUpdatedUser() async throws {
        let viewModel = HomeViewModel(provider: MockHomeDataProvider(delay: .zero))
        await viewModel.load()
        let before = try #require(viewModel.data).tasks.count

        viewModel.updateUser(User(firstName: "Sam", avatarName: "Avatar", email: "sam@example.com"))

        #expect(viewModel.data?.user.firstName == "Sam")
        #expect(viewModel.data?.tasks.count == before)               // le reste des données est intact
    }
}
