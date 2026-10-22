//
//  SceneDelegate.swift
//  MoraPay
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        
        // Moratuwa Theme Colors
        let moraGold = UIColor(red: 0.85, green: 0.60, blue: 0.15, alpha: 1.0)
        
        // 1. Initialize Tab View Controllers
        let homeVC = UINavigationController(rootViewController: BankHomeViewController())
        let activityVC = UINavigationController(rootViewController: TransactionViewController())
        let payVC = UINavigationController(rootViewController: TransferViewController())
        let cardsVC = UINavigationController(rootViewController: CardsViewController())
        let securityVC = UINavigationController(rootViewController: SecurityEngine())
        
        // 2. Set Tab Bar Items
        homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house.fill"), tag: 0)
        activityVC.tabBarItem = UITabBarItem(title: "Activity", image: UIImage(systemName: "clock.arrow.circlepath"), tag: 1)
        payVC.tabBarItem = UITabBarItem(title: "Pay", image: UIImage(systemName: "qrcode"), tag: 2)
        cardsVC.tabBarItem = UITabBarItem(title: "Cards", image: UIImage(systemName: "creditcard.fill"), tag: 3)
        securityVC.tabBarItem = UITabBarItem(title: "Security", image: UIImage(systemName: "shield.fill"), tag: 4)
        
        // 3. Configure Native Tab Bar Controller
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [homeVC, activityVC, payVC, cardsVC, securityVC]
        
        tabBarController.tabBar.tintColor = moraGold
        tabBarController.tabBar.unselectedItemTintColor = .gray
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.05, green: 0.05, blue: 0.07, alpha: 0.98)
        
        appearance.stackedLayoutAppearance.selected.iconColor = moraGold
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: moraGold]
        
        appearance.stackedLayoutAppearance.normal.iconColor = .gray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]
        
        tabBarController.tabBar.standardAppearance = appearance
        tabBarController.tabBar.scrollEdgeAppearance = appearance
        
        window.rootViewController = tabBarController
        self.window = window
        window.makeKeyAndVisible()
        
        // 4. Present Modal Auth Screen on Launch
        let authVC = AuthViewController()
        authVC.modalPresentationStyle = .fullScreen
        authVC.modalTransitionStyle = .crossDissolve
        tabBarController.present(authVC, animated: false, completion: nil)
    }
}
