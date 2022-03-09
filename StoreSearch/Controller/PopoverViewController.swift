
import UIKit

protocol PopoverViewControllerDelegate: AnyObject {
  func popoverSendEmail(_ controller: PopoverViewController)
}


class PopoverViewController: UITableViewController {
  
  weak var delegate: PopoverViewControllerDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  
  // MARK: - Table View Delegates
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    if indexPath.row == 0 {
      delegate?.popoverSendEmail(self)
    }
  }
  
  
}
