
import UIKit

class SearchResultCell: UITableViewCell {
  
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var artistNameLabel: UILabel!
  @IBOutlet weak var artworkImageView: UIImageView!
  
  private var downloadImageTask: URLSessionDownloadTask?
  private let searchManager = SearchManager.shared
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    let selectedView = UIView(frame: CGRect.zero)
    selectedView.backgroundColor = UIColor(named: "SearchBar")?.withAlphaComponent(0.5)
    selectedBackgroundView = selectedView
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    downloadImageTask?.cancel()
    downloadImageTask = nil
  }
  
  // MARK: - Helper Methods
  func configure(for result: SearchResult) {
    nameLabel.text = result.name
    artistNameLabel.text = !result.artist.isEmpty ? String(format: "%@ by %@", result.type, result.artist) : "Unknown"
    
    artworkImageView.image = UIImage(systemName: "square")  // to show while downloading
    if let smallURL = URL(string: result.imageSmall) {
      if let loadedImage = searchManager.downloadedImages[smallURL] {
        artworkImageView.image = loadedImage
      } else {
        downloadImageTask = artworkImageView.loadImage(url: smallURL)
      }
    }
  }
}
