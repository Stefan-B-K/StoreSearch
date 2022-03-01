//

import UIKit

class DetailViewController: UIViewController {
  
  @IBOutlet weak var popupView: UIView!
  @IBOutlet weak var artworkImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var artistNameLabel: UILabel!
  @IBOutlet weak var kindLabel: UILabel!
  @IBOutlet weak var genreLabel: UILabel!
  @IBOutlet weak var priceButton: UIButton!
  
  var searchResult: SearchResult!
  private var downloadImageTask: URLSessionDownloadTask?
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    transitioningDelegate = self
  }
  
  deinit {
    downloadImageTask?.cancel()
    downloadImageTask = nil
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    popupView.layer.cornerRadius = 10
    
    let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(close))
    gestureRecognizer.cancelsTouchesInView = false
    gestureRecognizer.delegate = self
    view.addGestureRecognizer(gestureRecognizer)
    
    updateUI()
    
    view.backgroundColor = UIColor.clear
    let dimmingView = GradientView(frame: view.bounds)
    view.insertSubview(dimmingView, at: 0)
  }
  
  @IBAction func close() {
    dismiss(animated: true)
  }
  
  @IBAction func openInStore() {
    if let url = URL(string: searchResult.storeURL) {
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
  }

  
  func updateUI() {
      nameLabel.text = searchResult.name
      artistNameLabel.text = !searchResult.artist.isEmpty ? searchResult.artist : "Unknown"
      kindLabel.text = searchResult.type
      genreLabel.text = searchResult.genre
      priceButton.setTitle(searchResult.price.showAsPrice(currency: searchResult.currency), for: .normal)
      if let _ = URL(string: searchResult.storeURL) {
        priceButton.isEnabled = true
      }
    if let largeURL = URL(string: searchResult.imageLarge) {
      downloadImageTask = artworkImageView.loadImage(url: largeURL)
    }
  }
  
}

extension DetailViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    return (touch.view is GradientView)
  }
}


extension DetailViewController: UIViewControllerTransitioningDelegate {
  func animationController(
    forPresented presented: UIViewController,
    presenting: UIViewController,
    source: UIViewController
  ) -> UIViewControllerAnimatedTransitioning? {
    return BounceAnimationController()
  }
}
