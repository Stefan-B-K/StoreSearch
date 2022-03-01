
import UIKit

class SearchViewController: UIViewController {
  
  enum Identifiers {
    static let searchResultCell = "SearchResultCell"
    static let noResultCell = "NoResultCell"
    static let loadingCell = "LoadingCell"
    static let detailSegue = "ShowDetail"
  }
  
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var segmentedControl: UISegmentedControl!
  
  let searchManager = SearchManager.shared
  
  override func viewDidLoad() {
    super.viewDidLoad()
    searchManager.presentResultIn = self
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
    if !searchBar.text!.isEmpty {
      searchManager.performSearch(for: searchBar.text!)
    }
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

}


// MARK: - Search Bar Delegate
extension SearchViewController: UISearchBarDelegate {
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    if !searchBar.text!.isEmpty {
      searchManager.performSearch(for: searchBar.text!)
    }
  }
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    searchBarClearButtonColor()
    if searchText == "" && searchManager.searchResults.isEmpty {
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
    return searchManager.isLoading ? 1 : (searchManager.searchResults.isEmpty ? (searchManager.hasSearched ? 1 : 0) : searchManager.searchResults.count)
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    if searchManager.isLoading {
      let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.loadingCell, for: indexPath)
      let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
      spinner.startAnimating()
      return cell
    } else if !searchManager.searchResults.isEmpty {
      let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.searchResultCell, for: indexPath) as! SearchResultCell
      cell.nameLabel.text = !searchManager.searchResults.isEmpty ? searchManager.searchResults[indexPath.row].name : "(Nothng found)"
      let searchResult = searchManager.searchResults[indexPath.row]
      cell.configure(for: searchResult)
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
    return searchManager.searchResults.isEmpty || searchManager.isLoading ? nil : indexPath
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    performSegue(withIdentifier: Identifiers.detailSegue, sender: indexPath)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == Identifiers.detailSegue {
      let indexPath = sender as! IndexPath
      let searchResult = searchManager.searchResults[indexPath.row]
      let popUp = segue.destination as! DetailViewController
      popUp.searchResult = searchResult
    }
  }

}
