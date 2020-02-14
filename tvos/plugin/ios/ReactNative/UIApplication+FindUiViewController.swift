//
//  UIView+FindUiViewController.swift
//  DefaultPlayer
//
//  Created by Anton Kononenko on 12/6/18.
//

//  Source: http://stackoverflow.com/a/3732812/1123156

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}
