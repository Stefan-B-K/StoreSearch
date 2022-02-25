
import UIKit

class SearchViewController: UIViewController {
  
  enum Identifiers {
    static let searchResultCell = "SearchResultCell"
    static let noResultCell = "NoResultCell"
  }

  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var tableView: UITableView!
  
  var searchResults = [SearchResult]()
  var hasSearched = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.contentInset = UIEdgeInsets(top: 51, left: 0, bottom: 0, right: 0)      // съдържанието (не целия tableView) да не е покрит от SearchBar-a ( h = 51 )
    searchBarTextFieldColors()
    
    let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
    gestureRecognizer.cancelsTouchesInView = false
    tableView.addGestureRecognizer(gestureRecognizer)
    
    var cellNib = UINib(nibName: Identifiers.searchResultCell, bundle: nil)
    tableView.register(cellNib, forCellReuseIdentifier: Identifiers.searchResultCell)
    cellNib = UINib(nibName: Identifiers.noResultCell, bundle: nil)
    tableView.register(cellNib, forCellReuseIdentifier: Identifiers.noResultCell)
  }
  

  // MARK: - Helper Functions
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
  
}


// MARK: - Search Bar Delegate
extension SearchViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
    searchResults.removeAll()
    if searchBar.text != "Madonna" {
      for i in 0...5 {
        let searchResult = SearchResult()
        searchResult.name = String(format: "Fake result %d", i)
        searchResult.artist = searchBar.text!
        searchResults.append(searchResult)
      }
    }
    hasSearched = true
    tableView.reloadData()
  }
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
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
    return searchResults.isEmpty ? (hasSearched ? 1 : 0) : searchResults.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if !searchResults.isEmpty {
      let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.searchResultCell, for: indexPath) as! SearchResultCell
      cell.nameLabel.text = !searchResults.isEmpty ? searchResults[indexPath.row].name : "(Nothng found)"
      cell.artistNameLabel.text = !searchResults.isEmpty ? searchResults[indexPath.row].artist : ""
    
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
    return searchResults.isEmpty ? nil : indexPath
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
}
