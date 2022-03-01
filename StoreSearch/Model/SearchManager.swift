
import UIKit

class SearchManager {
  
  var searchResults = [SearchResult]()
  var hasSearched = false
  var isLoading = false
  var downloadedImages = [URL: UIImage]()
  weak var presentResultIn: SearchViewController?
  private var fetchTask: URLSessionDataTask?
  
  static let shared: SearchManager = {
    return SearchManager()
  }()
  
  private init() {}
  
  
  // MARK: - HTTP data from API
  func iTunesURL(searchText: String, category: Int) -> URL {
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
  
  func parse(data: Data) -> [SearchResult] {
    do {
      return try JSONDecoder().decode(ResultArray.self, from: data).results
    } catch {
      print("JSON Error: \(error)")
      return []
    }
  }
  
  func showNetworkError() {
    let alert = UIAlertController(title: "Whoops...", message: "Error accessing iTunes Store", preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
    alert.addAction(action)
    presentResultIn?.present(alert, animated: true, completion: nil)
  }
  
    func performSearch(for searchText: String) {
        presentResultIn?.searchBar.resignFirstResponder()
        fetchTask?.cancel()
        isLoading = true
        presentResultIn?.tableView.reloadData()
        searchResults.removeAll()
        hasSearched = true
  
      let url = iTunesURL(searchText: searchText, category: presentResultIn!.segmentedControl.selectedSegmentIndex)
        let session = URLSession.shared
        fetchTask = session.dataTask(with: url) { data, response, error in
          if let error = error as NSError? {
            if error.code == -999 {                                 // Search was cancelled
              return
            } else {
              print("Failure! \(error.localizedDescription)")
            }
          } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data {
            self.searchResults = self.parse(data: data)
            self.searchResults.sort(by: <)
            DispatchQueue.main.async {
              self.isLoading = false
              self.presentResultIn?.tableView.reloadData()
            }
            return
          } else {
            print("Failure! \(response!)")
          }
          DispatchQueue.main.async {
            self.hasSearched = false
            self.isLoading = false
            self.presentResultIn?.tableView.reloadData()
            self.showNetworkError()
          }
        }
        fetchTask?.resume()
    }

}


