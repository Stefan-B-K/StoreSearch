//

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
      if searchManager.searchResults.isEmpty {
        scrollView.contentSize = CGSize(width: scrollView.bounds.size.width, height: scrollView.bounds.size.height)
      } else {
        tileButtons(searchManager.searchResults)
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
    for result in searchResults {
      let button = UIButton(type: .custom)
      downloadImage(for: result, andPlaceOn: button)
      button.setBackgroundImage(UIImage(named: "LandscapeButton"), for: .normal)
      button.frame = CGRect(
        x: x + paddingHorz,
        y: marginY + CGFloat(row) * itemHeight + paddingVert,
        width: buttonWidth, height: buttonHeight)
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

  
}

extension LandscapeViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let width = scrollView.bounds.size.width
    let page = Int((scrollView.contentOffset.x + width / 2) / width)
    pageControl.currentPage = page
  }
}

