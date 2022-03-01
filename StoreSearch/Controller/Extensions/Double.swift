
import Foundation

extension Double {
  func showAsPrice(currency: String) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = currency

    let priceText: String
    if self == 0 {
      priceText = "Free"
    } else if let text = formatter.string(from: self as NSNumber) {
      priceText = text
    } else {
      priceText = ""
    }
    return priceText
  }
}
