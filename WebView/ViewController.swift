//
//  ViewController.swift
//  WebView
//
//  Created by 大江祥太郎 on 2019/03/13.
//  Copyright © 2019 shotaro. All rights reserved.
//

import UIKit

class ViewController: UIViewController ,UIWebViewDelegate{
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var reloadButton: UIBarButtonItem!
    @IBOutlet weak var stopButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //ホームページのURL。起動時にこのページを開く
    let homeUrlString = "http://www.yahoo.co.jp"
    
    //検索機能で使うURL
    let searchUrlString = "http://search.yahoo.co.jp/search?p="
    
    //URLのホワイトリスト
    //このURLに当てはまればアプリ内プラウザで表示許可
    //前方一致の正規表現で処理される
    let whiteList = ["https?://.*\\.yahoo\\.co\\.jp","https?//.*\\.yahoo\\.com"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        webView.delegate = self
        searchBar.delegate = self as! UISearchBarDelegate
        //ホームページを開く
        open(urlString:homeUrlString);
    }
    
    //文字列で指定されたURLをWebViewで開く
    func open(urlString:String){
        let url = URL(string: urlString);
        let urlRequest = URLRequest(url: url!)
        webView.loadRequest(urlRequest);
    }
    
    //文字列で指定されたURLをSafariで開く
    func openInSafari(urlString:String){
        if let nsUrl=URL(string: urlString){
            UIApplication.shared.open(nsUrl)
        }
    }
    
    //読み込み完了時の処理
    func stopLoading(){
        activityIndicator.alpha = 0
        activityIndicator.stopAnimating()
        backButton.isEnabled = webView.canGoBack
        reloadButton.isEnabled = true
        stopButton.isEnabled = false
    }

    //MARK-UIWebViewDelegate
    func webViewDidStartLoad(_ webView: UIWebView) {//1
        activityIndicator.alpha = 1//2
        activityIndicator.stopAnimating()//3
        backButton.isEnabled = false//4
        reloadButton.isEnabled = false//5
        stopButton.isEnabled = true//6
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
       stopLoading()
    }

    /*
     
     1,WebViewwが読み込みを開始した時に実行されるメソッド。この各行はそれぞれ以下のような処理をしている
     2,ActivityIndicatorViewのAlphaを1(不透明)にする。これによってActivityIndicatorView
     が表示される。
     3,ActivityIndicatorViewのアニメーションを開始する
     4,5,6,戻るボタン、再読み込みボタンを非活性化、読み込み停止ボタンを活性化する。
 
 */
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        //ユーザ操作によるリクエストがなければ表示許可
        if navigationType == UIWebView.NavigationType.other{
            return true
        }
        
        //現在表示のURL取得
        var theUrl:String
        if let unwrappedUrl = request.url?.absoluteString {
            theUrl = unwrappedUrl
        }else{
            //現在表示中のURLが取得できない場合は表示不許可
            stopLoading()
            return false
        }
        
        //ホワイトリストでループしてURLがホワイトリスト内にあるかチェック
        var canStayApp = false
        for url in whiteList {
            if theUrl.range(of: url,options: NSString.CompareOptions.regularExpression) != nil{
                canStayApp = true
                break
            }
        }
        
        //ホワイトリスト内になければSafariで開く
        if !canStayApp {
            openInSafari(urlString: theUrl)
            stopLoading()
            return false
        }
        
        return true
    }
    
    //UISearchBarDelegate
    func searchBarSearchButtonClicked(_searchBar:UISearchBar){
        guard let searchText = searchBar.text else {
            return
        }
        guard let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            return
        }
        let urlString = searchUrlString + encodedText
        open(urlString: urlString)
        searchBar.resignFirstResponder()
        
    }
    @IBAction func backButtonTapped(_ sender: Any) {
        webView.goBack()
    }
    @IBAction func reloadButtonTapped(_ sender: Any) {
        webView.reload()
    }
    @IBAction func stopButtonTapped(_ sender: Any) {
        webView.stopLoading()
    }
    
}

