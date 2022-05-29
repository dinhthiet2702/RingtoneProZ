//
//  WebViewVC.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/28/21.
//

import UIKit
import WebKit

class WebViewVC: BaseViewControllers {

    var webView:WKWebView!
    
    var url:URL?
    
    init(url:URL?) {
        self.url = url
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        // Do any additional setup after loading the view.
    }
    
    func setupView(){
        
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        self.view = webView
        if let url = url{
            
            webView.load(URLRequest(url: url))
        }
        webView.allowsBackForwardNavigationGestures = true
        
        
        changeLeftButton(image: ImageProvider.image(named: "backTrim"))
    }
    func changeLeftButton(image:UIImage){
        
        let btn = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
        
        btn.setImage(image, for: .normal)
        
        
        btn.addTarget(self, action: #selector(clickLeft), for: .touchUpInside)
        
        navigationItem.leftBarButtonItem =  UIBarButtonItem(customView: btn)
        
        
    }
    
    override func clickLeft(sender:UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

}
extension WebViewVC:WKNavigationDelegate, WKUIDelegate{
    
}
