import Foundation

struct ImagesDataPresentation {
    let originalImageURL: URL
    let thumbnailImageURL: URL

    init(originalImageURL: URL, thumbnailImageURL: URL) {
        self.originalImageURL = originalImageURL
        self.thumbnailImageURL = thumbnailImageURL
    }
}
