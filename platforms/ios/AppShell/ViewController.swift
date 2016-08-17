//
//  ViewController.swift
//  AppShell
//
//  Created by Julien Rouzieres on 03/08/2016.
//  Copyright © 2016 Julien Rouzieres. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {
    
    var webView: WKWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let contentController = WKUserContentController()
        contentController.addScriptMessageHandler(self, name: "handler")
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        self.webView = WKWebView (frame: self.view.frame, configuration: config)
        self.webView!.navigationDelegate = self
        self.webView!.scrollView.bounces = false
        self.webView!.allowsBackForwardNavigationGestures = true
        self.view.addSubview(self.webView!)
        
        let starter = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("platform", ofType: "js")!)
        self.webView!.evaluateJavaScript(try! String(contentsOfURL: starter), completionHandler: nil)
        
        let www = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("index", ofType: "html", inDirectory: "www")!)
        self.webView!.loadFileURL(www, allowingReadAccessToURL: www.URLByDeletingLastPathComponent!)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.onPause), name: UIApplicationDidEnterBackgroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.onResume), name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    func onPause(notification: NSNotification) {
        self.webView!.evaluateJavaScript("document.dispatchEvent(new Event('pause'));", completionHandler: nil)
    }
    
    func onResume(notification: NSNotification) {
        self.webView!.evaluateJavaScript("document.dispatchEvent(new Event('resume'));", completionHandler: nil)
    }
    
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        if message.name == "handler" {
            switch message.body["method"] as! String {
            case "foo":
                self.foo(message.body["message"] as! String)
                break
            case "bar":
                self.bar(message.body["message"] as! String, callback: message.body["callback"] as! String)
                break
            default:
                break
            }
        }
    }
    
    func foo(message: String) {
        let alert = UIAlertController(title: "Foo", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func bar(message: String, callback: String) {
        let alert = UIAlertController(title: "Bar", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
            self.webView!.evaluateJavaScript("platform._invoke('" + callback + "', null, true);", completionHandler: nil)
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
            self.webView!.evaluateJavaScript("platform._invoke('" + callback + "', null, false);", completionHandler: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}