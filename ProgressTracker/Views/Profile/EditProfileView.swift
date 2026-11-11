import PhotosUI
import SwiftUI

// Feuille « Edit profile » : photo, prénom, e-mail. Elle remonte un `ProfileDraft` validé par `onSave`.
struct EditProfileView: View {
    let user: User
    let onSave: (ProfileDraft) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var draft: ProfileDraft
    // ⚛️ React : `PhotosPicker` ≈ `expo-image-picker` (`launchImageLibraryAsync`), mais sans demander d'autorisation : le sélecteur
    // système tourne dans un processus séparé et ne donne accès qu'à la photo CHOISIE. `PhotosPickerItem` est un « ticket » :
    // on charge ensuite ses données avec `loadTransferable`.
    @State private var pickedItem: PhotosPickerItem?
    @FocusState private var focusedField: Field?
    private enum Field { case name, email }

    init(user: User, onSave: @escaping (ProfileDraft) -> Void) {
        self.user = user
        self.onSave = onSave
        _draft = State(initialValue: ProfileDraft(user: user))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.section) {
                header
                avatarSection
                form
            }
            .padding(.horizontal, Spacing.screen)
            .padding(.top, Spacing.s)
        }
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom) {
            Button("Save Changes") {
                onSave(draft)
                dismiss()
            }
            .buttonStyle(.primary)
            // Désactivé tant que le formulaire est invalide OU que rien n'a changé.
            .disabled(!draft.isValid || !draft.hasChanges(from: user))
            .padding(.horizontal, Spacing.screen)
            .padding(.bottom, Spacing.s)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(Radius.sheet)
        .presentationBackground {
            LinearGradient(colors: [Color.sheetTop, Color.sheetBottom], startPoint: .top, endPoint: .bottom)
        }
        // ⚛️ React : `onChange` ≈ `useEffect(() => …, [pickedItem])` : quand une photo est choisie, on charge ses données
        // (asynchrone) puis on les range dans le brouillon.
        .onChange(of: pickedItem) { _, item in
            guard let item else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    draft.avatar = .replace(data)
                }
            }
        }
    }

    // MARK: - Sections

    private var header: some View {
        ZStack {
            Text("Edit Profile")
                .font(.appSheetTitle)
                .foregroundStyle(Color.textPrimary)
                .accessibilityAddTraits(.isHeader)
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.appIconButton)
                        .foregroundStyle(Color.textPrimary)
                        .frame(width: Size.circleButton, height: Size.circleButton)
                        .background(Circle().fill(Color.closeFill))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Close")
                Spacer()
            }
        }
    }

    private var avatarSection: some View {
        VStack(spacing: Spacing.m) {
            avatarPreview
                .frame(width: Size.profileAvatar, height: Size.profileAvatar)
                .clipShape(Circle())
                .overlay(Circle().strokeBorder(Color.avatarBorder, lineWidth: 4))
                .shadow(color: Color.avatarShadow, radius: Shadow.avatarRadius, y: Shadow.avatarY)
                .accessibilityHidden(true)
            HStack(spacing: Spacing.l) {
                PhotosPicker(selection: $pickedItem, matching: .images) {
                    Text("Change photo")
                        .font(.appChip)
                        .foregroundStyle(Color.appPrimaryStrong)
                        .frame(minHeight: Size.circleButton)
                }
                if draft.avatar != .remove, hasCustomPhoto {
                    Button("Remove") {
                        pickedItem = nil
                        draft.avatar = .remove
                    }
                    .font(.appChip)
                    .foregroundStyle(Color.destructive)
                    .frame(minHeight: Size.circleButton)
                }
            }
        }
    }

    // L'aperçu suit le brouillon : nouvelle photo choisie, avatar par défaut si retirée, sinon la photo actuelle.
    @ViewBuilder
    private var avatarPreview: some View {
        switch draft.avatar {
        case .replace(let data):
            if let image = UIImage(data: data) {
                Image(uiImage: image).resizable().scaledToFill()
            } else {
                AvatarImage(assetName: user.avatarName).scaledToFill()
            }
        case .remove:
            AvatarImage(assetName: user.avatarName).scaledToFill()
        case .keep:
            AvatarImage(assetName: user.avatarName, url: user.avatarURL).scaledToFill()
        }
    }

    private var hasCustomPhoto: Bool {
        if case .replace = draft.avatar { return true }
        return user.avatarURL != nil
    }

    private var form: some View {
        VStack(alignment: .leading, spacing: Spacing.l) {
            AuthField(
                label: tr("First name"),
                errorMessage: (!draft.isFirstNameValid && focusedField != .name) ? tr("Enter your first name.") : nil
            ) {
                TextField("", text: $draft.firstName, prompt: Text("Alex").foregroundStyle(Color.textPlaceholder))
                    .font(.appFieldText)
                    .foregroundStyle(Color.textPrimary)
                    .textContentType(.givenName)
                    .textInputAutocapitalization(.words)
                    .focused($focusedField, equals: .name)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .email }
                    .formField(isFocused: focusedField == .name)
            }
            AuthField(
                label: tr("Email"),
                errorMessage: (!draft.email.isEmpty && !draft.isEmailValid && focusedField != .email)
                    ? tr("Enter a valid email address.") : nil
            ) {
                TextField("", text: $draft.email, prompt: Text(verbatim: "you@example.com").foregroundStyle(Color.textPlaceholder))
                    .font(.appFieldText)
                    .foregroundStyle(Color.textPrimary)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .email)
                    .submitLabel(.done)
                    .onSubmit { focusedField = nil }
                    .formField(isFocused: focusedField == .email)
            }
        }
    }
}

#Preview {
    EditProfileView(user: MockData.user, onSave: { _ in })
}
