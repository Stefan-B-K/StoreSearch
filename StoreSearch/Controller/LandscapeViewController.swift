
import UIKit

class LandscapeViewController: UIViewController {
  
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var pageControl: UIPageControl!
  
  private let searchManager = SearchManager.shared
  private var firstTime = true
  private var downloads = [URLSessionDownloadTask]()
  
  deinit {
    downloads.forEach { $0.cancel() }
  }

  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.removeConstraints(view.constraints)
    view.translatesAutoresizingMaskIntoConstraints = true
    pageControl.removeConstraints(pageControl.constraints)
    pageControl.translatesAutoresizingMaskIntoConstraints = true
    scrollView.removeConstraints(scrollView.constraints)
    scrollView.translatesAutoresizingMaskIntoConstraints = true
    
    view.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
    pageControl.numberOfPages = 0   // hides pageControl, when no search results
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    let safeFrame = view.safeAreaLayoutGuide.layoutFrame
    scrollView.frame = safeFrame
    pageControl.frame = CGRect(
      x: safeFrame.origin.x,
      y: safeFrame.size.height - pageControl.frame.size.height,
      width: safeFrame.size.width,
      height: pageControl.frame.size.height)
    if firstTime {
      firstTime = false
      switch searchManager.state {
      case .noSearchOrError:
        scrollView.contentSize = CGSize(width: scrollView.bounds.size.width, height: scrollView.bounds.size.height)
      case .loading:
        scrollView.contentSize = CGSize(width: scrollView.bounds.size.width, height: scrollView.bounds.size.height)
        showSpinner()
      case .results(let list):
        tileButtons(list)
      case .noResults:
        scrollView.contentSize = CGSize(width: scrollView.bounds.size.width, height: scrollView.bounds.size.height)
        showNothingFoundLabel()
      }
    }
  }
  
  @IBAction func pageChanged(_ sender: UIPageControl) {
    UIView.animate(
      withDuration: 0.3, delay: 0, options: [.curveEaseInOut],
      animations: {
        self.scrollView.contentOffset = CGPoint(x: self.scrollView.bounds.size.width * CGFloat(sender.currentPage), y: 0)
      }, completion: nil)
  }
  
  // MARK: - Helper Methods
  func searchResultsReceived() {
    hideSpinner()
    switch searchManager.state {
    case .noSearchOrError, .loading:
      break
    case .noResults:
      showNothingFoundLabel()
    case .results(let list):
      tileButtons(list)
    }
  }
  
  // MARK: - Private Methods
  private func tileButtons(_ searchResults: [SearchResult]) {
    let itemWidth: CGFloat = 94
    let itemHeight: CGFloat = 88
    let columnsPerPage: Int
    let rowsPerPage: Int
    let marginX: CGFloat
    let marginY: CGFloat
    let viewWidth = scrollView.bounds.size.width
    let viewHeight = scrollView.bounds.size.height
    
    columnsPerPage = Int(viewWidth / itemWidth)
    rowsPerPage = Int(viewHeight / itemHeight)
    marginX = (viewWidth - (CGFloat(columnsPerPage) * itemWidth)) / 2
    marginY = (viewHeight - (CGFloat(rowsPerPage) * itemHeight)) / 2
    
    let buttonsPerPage = columnsPerPage * rowsPerPage
    let numPages = 1 + (searchResults.count - 1) / buttonsPerPage
    scrollView.contentSize = CGSize(width: CGFloat(numPages) * viewWidth, height: scrollView.bounds.size.height)
    
    let buttonWidth: CGFloat = 82
    let buttonHeight: CGFloat = 82
    let paddingHorz = (itemWidth - buttonWidth) / 2
    let paddingVert = (itemHeight - buttonHeight) / 2
    
    var row = 0
    var column = 0
    var x = marginX
    for (index, result) in searchResults.enumerated() {
      let button = UIButton(type: .custom)
      downloadImage(for: result, andPlaceOn: button)
      button.setBackgroundImage(UIImage(named: "LandscapeButton"), for: .normal)
      button.frame = CGRect(
        x: x + paddingHorz,
        y: marginY + CGFloat(row) * itemHeight + paddingVert,
        width: buttonWidth, height: buttonHeight)
      button.tag = 2000 + index
      button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
      scrollView.addSubview(button)
      
      row += 1
      if row == rowsPerPage {
        row = 0; x += itemWidth; column += 1
        if column == columnsPerPage {
          column = 0; x += marginX * 2
        }
      }
    }
    pageControl.numberOfPages = numPages
    pageControl.currentPage = 0
  }
  
  @objc private func buttonPressed(_ sender: UIButton) {
    performSegue(withIdentifier: "ShowDetail", sender: sender)
  }
  
  private func downloadImage(for searchResult: SearchResult, andPlaceOn button: UIButton) {
    if let url = URL(string: searchResult.imageSmall) {
      let searchManager = SearchManager.shared
      if let loadedImage = searchManager.downloadedImages[url] {
        button.setImage(loadedImage, for: .normal)
      } else {
        let task = URLSession.shared.downloadTask(with: url) { [weak button] localURL, _, error in
          if error == nil, let localURL = localURL, let data = try? Data(contentsOf: localURL), let image = UIImage(data: data) {
            DispatchQueue.main.async {
              if let button = button {
                button.setImage(image, for: .normal)
                searchManager.downloadedImages[url] = image
              }
            }
          }
        }
        task.resume()
        downloads.append(task)
      }
    }
  }
  
  private func showSpinner() {
    let spinner = UIActivityIndicatorView(style: .large)
    spinner.center = CGPoint(x: scrollView.bounds.midX - spinner.frame.width + 0.5, y: scrollView.bounds.midY + 0.5) //
    spinner.tag = 1000
    let label = UILabel(frame: CGRect(x: scrollView.bounds.midX + 0.5,
                                        y: scrollView.bounds.midY - 10,
                                        width: 100, height: 20))
    label.text = "Loading..."
    label.textColor = UIColor(named: "ArtistName")
    label.backgroundColor = UIColor.clear
    label.font = .systemFont(ofSize: 17)
    label.tag = 1001
    view.addSubview(spinner)
    view.addSubview(label)
    spinner.startAnimating()
  }
  
  private func hideSpinner() {
    view.viewWithTag(1000)?.removeFromSuperview()
    view.viewWithTag(1001)?.removeFromSuperview()
  }
  
  private func showNothingFoundLabel() {
    let label = UILabel(frame: CGRect.zero)
    label.text = "Nothing Found"
    label.textColor = UIColor.label
    label.backgroundColor = UIColor.clear
    
    label.sizeToFit()
    
    var rect = label.frame
    rect.size.width = ceil(rect.size.width / 2) * 2             // make even
    rect.size.height = ceil(rect.size.height / 2) * 2           // make even
    label.frame = rect
    
    label.center = CGPoint(x: scrollView.bounds.midX, y: scrollView.bounds.midY)
    view.addSubview(label)
  }
  
  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ShowDetail" {
      if case .results(let list) = searchManager.state {
        let detailViewController = segue.destination as! DetailViewController
        let searchResult = list[(sender as! UIButton).tag - 2000]
        detailViewController.searchResult = searchResult
      }
    }
  }
}



extension LandscapeViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let width = scrollView.bounds.size.width
    let page = Int((scrollView.contentOffset.x + width / 2) / width)
    pageControl.currentPage = page
  }
}

