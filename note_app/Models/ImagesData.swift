import Foundation

struct ImagesData: Codable {
    let originalImagePath: String
    let thumbnailImagePath: String
    
    init() {
        originalImagePath = ""
        thumbnailImagePath = ""
    }
    
    init(originalImagePath: String, thumbnailImagePath: String) {
        self.originalImagePath = originalImagePath
        self.thumbnailImagePath = thumbnailImagePath
    }
}
