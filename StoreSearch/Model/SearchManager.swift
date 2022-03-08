
import UIKit

class SearchManager {
  
  enum Category: Int {
    case all, music, software, ebooks
    
    var kind: String {
      switch self {
      case .all: return ""
      case .music: return "musicTrack"
      case .software: return "software"
      case .ebooks: return "ebook"
      }
    }
  }
  
  enum State {
    case noSearchOrError, loading, noResults, results([SearchResult])
  }

  private(set) var state: State = .noSearchOrError
  private var fetchTask: URLSessionDataTask?
  var downloadedImages = [URL: UIImage]()
  typealias SearchComplete = (Bool, String?) -> Void

  static let shared: SearchManager = {
    return SearchManager()
  }()
  
  private init() {}
  
  
  // MARK: - HTTP data from API
  private func iTunesURL(searchText: String, category: Category) -> URL {
    let encodedString = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
    let urlString = "https://itunes.apple.com/search?term=\(encodedString!)&limit=200&entity=\(category.kind)"
    return URL(string: urlString)!
  }
  
  private func parse(data: Data) -> [SearchResult] {
    do {
      return try JSONDecoder().decode(ResultArray.self, from: data).results
    } catch {
      print("JSON Error: \(error)")
      return []
    }
  }
  

  
  func performSearch(for searchText: String, category: Category, completion: @escaping SearchComplete) {
    fetchTask?.cancel()
    state = .loading
    
    let url = iTunesURL(searchText: searchText, category: category)
    let session: URLSession = {
      let configuration = URLSessionConfiguration.default
      configuration.timeoutIntervalForResource = 10
      configuration.timeoutIntervalForRequest = 10
      return URLSession(configuration: configuration)
    }()
    fetchTask = session.dataTask(with: url) { data, response, error in
      var newState = State.noSearchOrError
      var success = false
      var failMessage: String? = nil
      if let error = error as NSError? {
        if error.code == -999 {                                 // Search was cancelled
          return
        } else {
          failMessage = "Error connecting to iTunes Store: \(error.localizedDescription)"
        }
      } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data {
        var searchResults = self.parse(data: data)
        if searchResults.isEmpty {
          newState = .noResults
        } else {
          searchResults.sort(by: <)
          newState = .results(searchResults)
        }
        success = true
      } else {
        if let httpResponse = response as? HTTPURLResponse {
          failMessage = "Response from iTunes Store server: \(httpResponse.statusCode)"
        }
      }
      DispatchQueue.main.async {
        self.state = newState
        completion(success, failMessage)
      }
    }
    fetchTask?.resume()
  }
  
  func cancelSearch() {
    fetchTask?.cancel()
    state = .noSearchOrError
  }
  
}


