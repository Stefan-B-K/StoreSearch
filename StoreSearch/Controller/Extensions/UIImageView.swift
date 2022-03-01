
import UIKit

extension UIImageView {
  func loadImage(url: URL) -> URLSessionDownloadTask {
    let searchManager = SearchManager.shared
    let downloadTask = URLSession.shared.downloadTask(with: url) {[weak self] localURL, _, error in
      if error == nil, let localURL = localURL, let data = try? Data(contentsOf: localURL), let image = UIImage(data: data) {
        DispatchQueue.main.async {
          if let weakSelf = self {
            weakSelf.image = image
            searchManager.downloadedImages[url] = image
          }
        }
      }
    }
    downloadTask.resume()
    return downloadTask
  }
}
