import SwiftUI
import UIKit

// Affiche la photo choisie par l'utilisateur si elle existe, sinon l'avatar par défaut de l'asset catalog.
// Renvoie une `Image` redimensionnable : l'appelant ajoute `.scaledToFill()`, `.frame(…)` et `.clipShape(…)`.
struct AvatarImage: View {
    let assetName: String
    var url: URL?

    var body: some View {
        // ⚛️ React : `source={url ? { uri: url } : require('./avatar.png')}` : une photo locale OU l'image embarquée.
        if let url, let image = UIImage(contentsOfFile: url.path) {
            Image(uiImage: image).resizable()
        } else {
            Image(assetName).resizable()
        }
    }
}
