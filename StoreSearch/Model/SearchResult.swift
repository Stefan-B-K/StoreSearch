
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
  
  var type: String {
    let kind = self.kind ?? "audiobook"
    switch kind {
    case "album": return "Album"
    case "audiobook": return "Audio Book"
    case "book": return "Book"
    case "ebook": return "E-Book"
    case "feature-movie": return "Movie"
    case "music-video": return "Music Video"
    case "podcast": return "Podcast"
    case "software": return "App"
    case "song": return "Song"
    case "tv-episode": return "TV Episode"
    default: break
    }
    return "Unknown"
  }

  
  
}

