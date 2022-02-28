
import UIKit

class SearchViewController: UIViewController {
  
  enum Identifiers {
    static let searchResultCell = "SearchResultCell"
    static let noResultCell = "NoResultCell"
    static let loadingCell = "LoadingCell"
  }
  
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var segmentedControl: UISegmentedControl!
  
  
  var searchResults = [SearchResult]()
  var hasSearched = false
  var isLoading = false
  var dataTask: URLSessionDataTask?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    searchBar.becomeFirstResponder()
    
    tableView.contentInset = UIEdgeInsets(top: 91, left: 0, bottom: 0, right: 0)
    searchBarTextFieldColors()
    
    let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
    gestureRecognizer.cancelsTouchesInView = false
    tableView.addGestureRecognizer(gestureRecognizer)
    
    var cellNib = UINib(nibName: Identifiers.searchResultCell, bundle: nil)
    tableView.register(cellNib, forCellReuseIdentifier: Identifiers.searchResultCell)
    cellNib = UINib(nibName: Identifiers.noResultCell, bundle: nil)
    tableView.register(cellNib, forCellReuseIdentifier: Identifiers.noResultCell)
    cellNib = UINib(nibName: Identifiers.loadingCell, bundle: nil)
    tableView.register(cellNib, forCellReuseIdentifier: Identifiers.loadingCell)
    
  }
  
  @IBAction func segmentChanged(_ sender: UISegmentedControl) {
    performSearch()
  }
  
  // MARK: - Helper Methods
  @objc func hideKeyboard() {
    searchBar.resignFirstResponder()
  }
  
  func searchBarTextFieldColors() {
    searchBar.searchTextField.backgroundColor = UIColor(named: "SearchBarShade")
    searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: searchBar.searchTextField.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor : UIColor(named: "ArtistName")!])
    if let leftView = searchBar.searchTextField.leftView as? UIImageView {
      leftView.image = leftView.image?.withRenderingMode(.alwaysTemplate)
      leftView.tintColor = UIColor(named: "ArtistName")
    }
  }
  
  func searchBarClearButtonColor() {
    if let clearButton = searchBar.searchTextField.value(forKey: "_clearButton") as? UIButton {
      clearButton.imageView?.image = clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate)
      clearButton.imageView!.tintColor = UIColor(named: "ArtistName")
    }
  }
  
  
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
    present(alert, animated: true, completion: nil)
  }
  
  
}


// MARK: - Search Bar Delegate
extension SearchViewController: UISearchBarDelegate {
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    performSearch()
  }
  
  func performSearch() {
    if !searchBar.text!.isEmpty {
      searchBar.resignFirstResponder()
      dataTask?.cancel()
      isLoading = true
      tableView.reloadData()
      searchResults.removeAll()
      hasSearched = true
      
      let url = iTunesURL(searchText: searchBar.text!, category: segmentedControl.selectedSegmentIndex)
      let session = URLSession.shared
      dataTask = session.dataTask(with: url) { data, response, error in
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
            self.tableView.reloadData()
          }
          return
        } else {
          print("Failure! \(response!)")
        }
        DispatchQueue.main.async {
          self.hasSearched = false
          self.isLoading = false
          self.tableView.reloadData()
          self.showNetworkError()
        }
      }
      dataTask?.resume()
    }
  }
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    searchBarClearButtonColor()
    if searchText == "" && searchResults.isEmpty {
      tableView.reloadData()
    }
  }
  
  func position(for bar: UIBarPositioning) -> UIBarPosition {       // UIBarPositioningDelegate method
    .topAttached
  }
  
}


// MARK: - Table View DataSource & Delegate
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isLoading ? 1 : (searchResults.isEmpty ? (hasSearched ? 1 : 0) : searchResults.count)
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    if isLoading {
      let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.loadingCell, for: indexPath)
      let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
      spinner.startAnimating()
      return cell
    } else if !searchResults.isEmpty {
      let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.searchResultCell, for: indexPath) as! SearchResultCell
      cell.nameLabel.text = !searchResults.isEmpty ? searchResults[indexPath.row].name : "(Nothng found)"
      let searchResult = searchResults[indexPath.row]
      cell.artistNameLabel.text = !searchResults.isEmpty ? String(format: "%@ by %@", searchResult.type, searchResult.artist) : "Unknown"
      return cell
    } else {
      tableView.separatorStyle = .none
      if searchBar.text == "" {
        return UITableViewCell()
      } else {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.noResultCell, for: indexPath)
        return cell
      }
    }
  }
  
  func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    return searchResults.isEmpty || isLoading ? nil : indexPath
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
  }
  
}
