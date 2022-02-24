
import UIKit

class SearchViewController: UIViewController {

  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var tableView: UITableView!
  
  var searchResults = [SearchResult]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.contentInset = UIEdgeInsets(top: 51, left: 0, bottom: 0, right: 0)      // съдържанието (не целия tableView) да не е покрит от SearchBar-a ( h = 51 )
    
    let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
    gestureRecognizer.cancelsTouchesInView = false
    tableView.addGestureRecognizer(gestureRecognizer)
  }
  

  // MARK: - Helper Functions
  @objc func hideKeyboard() {
    searchBar.resignFirstResponder()
  }
  
}


// MARK: - Search Bar Delegate
extension SearchViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
    for i in 0...5 {
      let searchResult = SearchResult()
      searchResult.name = String(format: "Fake result %d for %@", i, searchBar.text!)
      searchResults.append(searchResult)
    }
    tableView.reloadData()
  }
  
  func position(for bar: UIBarPositioning) -> UIBarPosition {       // UIBarPositioningDelegate method
    .topAttached
  }

}


// MARK: - Table View Delegate
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return searchResults.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cellIdentifier = "SearchResultCell"
    var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
    if cell == nil {
      cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
    }
    var content = cell?.defaultContentConfiguration()
    content?.text = searchResults[indexPath.row].name
    cell?.contentConfiguration = content
    return cell
  }
  
  
}
