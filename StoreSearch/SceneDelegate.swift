
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let _ = (scene as? UIWindowScene) else { return }
  
    searchVC.splitViewDetail = detailVC
    splitVC.delegate = self
  }

  func sceneDidDisconnect(_ scene: UIScene) {}

  func sceneDidBecomeActive(_ scene: UIScene) {}

  func sceneWillResignActive(_ scene: UIScene) {}

  func sceneWillEnterForeground(_ scene: UIScene) {}

  func sceneDidEnterBackground(_ scene: UIScene) {}
  
  // MARK: - Properties
  var splitVC: UISplitViewController {
    return window!.rootViewController as! UISplitViewController
  }

  var searchVC: SearchViewController {
    let nav = splitVC.viewControllers.first as! UINavigationController
    return nav.viewControllers.first as! SearchViewController
  }

  var detailVC: DetailViewController {
    let nav = splitVC.viewControllers.last as! UINavigationController
    return nav.viewControllers.first as! DetailViewController
  }

}


extension SceneDelegate: UISplitViewControllerDelegate {
  func splitViewController(_ svc: UISplitViewController,
                           topColumnForCollapsingToProposedTopColumn proposedTopColumn: UISplitViewController.Column) -> UISplitViewController.Column {
    if UIDevice.current.userInterfaceIdiom == .phone {
      return .primary
    }
    return proposedTopColumn
  }
}
