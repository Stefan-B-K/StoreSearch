
import UIKit

class SearchManager {
  
  var searchResults = [SearchResult]()
  var hasSearched = false
  var isLoading = false
  var downloadedImages = [URL: UIImage]()
  private var fetchTask: URLSessionDataTask?
  typealias SearchComplete = (Bool) -> Void

  static let shared: SearchManager = {
    return SearchManager()
  }()
  
  private init() {}
  
  
  // MARK: - HTTP data from API
  private func iTunesURL(searchText: String, category: Int) -> URL {
    let kind: String
    switch category {
    case 1: kind = "musicTrack"
    case 2: kind = "software"
    case 3: kind = "ebook"
    default: kind = ""
    }
    let encodedString = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
    let urlString = "https://itunes.apple.com/search?term=\(encodedString!)&limit=200&entity=\(kind)"
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
  

  
  func performSearch(for searchText: String, category: Int, completion: @escaping SearchComplete) {
    fetchTask?.cancel()
    isLoading = true
//    delegate?.reloadUI()
    searchResults.removeAll()
    hasSearched = true
    
    let url = iTunesURL(searchText: searchText, category: category)
    let session = URLSession.shared
    fetchTask = session.dataTask(with: url) { data, response, error in
      var success = false
      if let error = error as NSError? {
        if error.code == -999 {                                 // Search was cancelled
          return
        } else {
          print("Failure! \(error.localizedDescription)")
        }
      } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data {
        self.searchResults = self.parse(data: data)
        self.searchResults.sort(by: <)
        self.isLoading = false
        success = true
      } else {
        print("Failure! \(response!)")
      }
      if !success {
        self.hasSearched = false
        self.isLoading = false
      }
      DispatchQueue.main.async {
        completion(success)
      }
    }
    fetchTask?.resume()
  }
  
}


