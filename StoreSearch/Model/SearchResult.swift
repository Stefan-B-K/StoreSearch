
import UIKit

class ResultArray: Decodable {
  var resultCount = 0
  var results = [SearchResult]()
}


class SearchResult: Decodable {
  
  private var kind: String?
  private var artistName: String?
  private var trackName: String?; private var collectionName: String?
  private var trackPrice: Double?; var collectionPrice: Double?; private var itemPrice: Double?
  private var trackViewUrl: String?;  private var collectionViewUrl: String?
  private var itemGenre: String?; private var bookGenre: [String]?
  var currency = ""
  var imageSmall = ""
  var imageLarge = ""
  
  enum CodingKeys: String, CodingKey {
    case kind, artistName, currency, trackName, collectionName
    case trackPrice, collectionPrice
    case imageSmall = "artworkUrl60"
    case imageLarge = "artworkUrl100"
    case itemGenre = "primaryGenreName"
    case bookGenre = "genres"
    case itemPrice = "price"
    case trackViewUrl, collectionViewUrl
  }
  
  var name: String { trackName ?? collectionName ?? "( no name )" }
  var price: Double { trackPrice ?? collectionPrice ?? itemPrice ?? 0.0 }
  var storeURL: String { trackViewUrl ?? collectionViewUrl ?? "" }
  var artist: String { artistName ?? "" }
  
  var genre: String {
    if let genres = bookGenre {
      return genres.joined(separator: ", ")
    } else {
      return itemGenre ?? "( not specified )"
    }
  }
  
  private let typeForKind = [
    "album": NSLocalizedString("Album", comment: "Localized kind: Album"),
    "audiobook": NSLocalizedString("Audio Book", comment: "Localized kind: Audio Book"),
    "book": NSLocalizedString("Book", comment: "Localized kind: Book"),
    "ebook": NSLocalizedString("E-Book", comment: "Localized kind: E-Book"),
    "feature-movie": NSLocalizedString("Movie",comment: "Localized kind: Feature Movie"),
    "music-video": NSLocalizedString("Music Video", comment: "Localized kind: Music Video"),
    "podcast": NSLocalizedString("Podcast", comment: "Localized kind: Podcast"),
    "software": NSLocalizedString("App", comment: "Localized kind: Software"),
    "song": NSLocalizedString("Song", comment: "Localized kind: Song"),
    "tv-episode": NSLocalizedString("TV Episode", comment: "Localized kind: TV Episode"),
    "unknown": NSLocalizedString("Unknown", comment: "Localized kind: Unknown")
  ]

  var type: String {
    let kind = self.kind ?? "audiobook"
    return typeForKind[kind] ?? typeForKind["unknown"]!
  }

  
  
}

