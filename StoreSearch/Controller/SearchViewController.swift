
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
  
  private let searchManager = SearchManager.shared
  private var landscapeVC: LandscapeViewController?
  weak var splitViewDetail: DetailViewController?
  
  override func viewWillAppear(_ animated: Bool) {
    if UIDevice.current.userInterfaceIdiom == .phone {
      navigationController?.navigationBar.isHidden = true
    }
  }

  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = NSLocalizedString("Search", comment: "split view primary button")
    
    if UIDevice.current.userInterfaceIdiom != .pad {
      searchBar.becomeFirstResponder()
    }
    tableView.contentInset = UIEdgeInsets(top: 110, left: 0, bottom: 0, right: 0)
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
    
    if UITraitCollection.current.verticalSizeClass == .compact {
      hideKeyboard()
      showLandscape()
      return
    }

  }
  
  override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
    super.willTransition(to: newCollection, with: coordinator)
    
    switch newCollection.verticalSizeClass {
    case .compact:
      hideKeyboard()
      showLandscape(with: coordinator)
    case .regular, .unspecified:
      hideLandscape(with: coordinator)
    @unknown default:
      break
    }
  }
  
  @IBAction func segmentChanged(_ sender: UISegmentedControl) {
    performSearch()
  }
  
  // MARK: - Helper Methods
  @objc func hideKeyboard() {
    searchBar.resignFirstResponder()
  }
  
  func performSearch() {
    if !searchBar.text!.isEmpty {
      hideKeyboard()
      if let category = SearchManager.Category(rawValue: segmentedControl.selectedSegmentIndex) {
        searchManager.performSearch(for: searchBar.text!, category: category) { success, failMessage in
          if !success {
            self.showNetworkError(message: failMessage)
          }
          self.tableView.reloadData()
          self.landscapeVC?.searchResultsReceived()
        }
        tableView.reloadData()
      }
    }
  }
  
  private func searchBarTextFieldColors() {
    searchBar.searchTextField.backgroundColor = UIColor(named: "SearchBarShade")
    searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: searchBar.searchTextField.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor : UIColor(named: "ArtistName")!])
    if let leftView = searchBar.searchTextField.leftView as? UIImageView {
      leftView.image = leftView.image?.withRenderingMode(.alwaysTemplate)
      leftView.tintColor = UIColor(named: "ArtistName")
    }
  }
  
  private func searchBarClearButtonColor() {
    if let clearButton = searchBar.searchTextField.value(forKey: "_clearButton") as? UIButton {
      clearButton.imageView?.image = clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate)
      clearButton.imageView!.tintColor = UIColor(named: "ArtistName")
    }
  }
  
  private func showNetworkError(message: String?) {
    let alert = UIAlertController(title: "Whoops...", message: message ?? "Error accessing iTunes Store", preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
    alert.addAction(action)
    present(alert, animated: true, completion: nil)
  }
  
  // MARK: - Landscape Methods
  private func showLandscape(with coordinator: UIViewControllerTransitionCoordinator? = nil) {      // = nil for initial load in landscape (no animation)
    guard landscapeVC == nil else { return }
    landscapeVC = storyboard!.instantiateViewController(withIdentifier: "LandscapeViewController") as? LandscapeViewController
    if let controller = landscapeVC {
      controller.view.frame = view.bounds
      controller.view.alpha = coordinator == nil ? 1 : 0              //  animation START state 0
      view.addSubview(controller.view)
      addChild(controller)
      if let coordinator = coordinator {
        coordinator.animate(
          alongsideTransition: { _ in
            controller.view.alpha = 1                                 //  animation END state
            self.hideKeyboard()
            if self.presentedViewController != nil {
              self.dismiss(animated: true, completion: nil)
            }
          },
          completion: { _ in
            controller.didMove(toParent: self)
          })
      } else {
        controller.didMove(toParent: self)
      }
    }
  }
  
  private func hideLandscape(with coordinator: UIViewControllerTransitionCoordinator? = nil) {
    if let controller = landscapeVC {
      controller.willMove(toParent: nil)
      if let coordinator = coordinator {
        coordinator.animate(
          alongsideTransition: { _ in
            controller.view.alpha = 0                                 //  animation END state
            if self.presentedViewController != nil {
              self.dismiss(animated: true, completion: nil)
            }
          },
          completion: { _ in
            controller.view.removeFromSuperview()
            controller.removeFromParent()
            self.landscapeVC = nil
          })
      } else {
        controller.view.removeFromSuperview()
        controller.removeFromParent()
        self.landscapeVC = nil
      }
    }
  }
  
  // MARK: - Private Methods
  private func hidePrimaryPane() {
    UIView.animate(withDuration: 0.25, animations: {
      self.splitViewController!.preferredDisplayMode = .secondaryOnly
    }, completion: { _ in
      self.splitViewController!.preferredDisplayMode = .automatic
    }
    )
  }

}


// MARK: - Search Bar Delegate
extension SearchViewController: UISearchBarDelegate {
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    performSearch()
  }
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    searchBarClearButtonColor()
    if searchText == "" {
      guard case .results = searchManager.state else {
        searchManager.cancelSearch()
        tableView.reloadData()
        return
      }
    }
  }
  
  func position(for bar: UIBarPositioning) -> UIBarPosition {       // UIBarPositioningDelegate method
    .topAttached
  }
}


// MARK: - Table View DataSource & Delegate
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch searchManager.state {
    case .noSearchOrError: return 0
    case .loading, .noResults: return 1
    case .results(let list): return list.count
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    switch searchManager.state {
    case .noSearchOrError:
      fatalError("numberOfRowsInSection returns 0 and cellForRowAt should never be called")
    case .loading:
      tableView.separatorStyle = .none
      let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.loadingCell, for: indexPath)
      let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
      spinner.startAnimating()
      return cell
    case .results(let list):
      let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.searchResultCell, for: indexPath) as! SearchResultCell
      let searchResult = list[indexPath.row]
      cell.configure(for: searchResult)
      return cell
    case .noResults:
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
    switch searchManager.state {
    case .noSearchOrError, .loading, .noResults:
      return nil
    case .results:
      return indexPath
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    searchBar.resignFirstResponder()
    if view.window?.rootViewController?.traitCollection.horizontalSizeClass == .compact {
      tableView.deselectRow(at: indexPath, animated: true)
      performSegue(withIdentifier: Identifiers.detailSegue, sender: indexPath)
    } else {
      if case .results(let list) = searchManager.state {
        splitViewDetail?.searchResult = list[indexPath.row]
        if splitViewController?.displayMode != .oneBesideSecondary {
          hidePrimaryPane()
        }
      }
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == Identifiers.detailSegue {
      if case .results(let list) = searchManager.state {
        let indexPath = sender as! IndexPath
        let searchResult = list[indexPath.row]
        let popUp = segue.destination as! DetailViewController
        popUp.searchResult = searchResult
        popUp.isPopUp = true
      }
    }
  }
  
}
