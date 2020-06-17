//
//  ViewController.swift
//  WKWebView
//
//  Created by Zafar on 1/24/20.
//  Copyright © 2020 Zafar. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKUIDelegate {
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavItem()
        
        check_record_permission()
        
        let myURL = URL(string: "https://api.voxm.live/p/1103")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
        
    }
    
    @IBOutlet var recordingTimeLabel: UILabel!
    @IBOutlet var record_btn_ref: UIButton!
    @IBOutlet var play_btn_ref: UIButton!

    var audioRecorder: AVAudioRecorder!
    var audioPlayer : AVAudioPlayer!
    var meterTimer:Timer!
    var isAudioRecordingGranted: Bool!
    var isRecording = false
    var isPlaying = false
    
    func check_record_permission()
    {
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSessionRecordPermission.granted:
            isAudioRecordingGranted = true
            break
        case AVAudioSessionRecordPermission.denied:
            isAudioRecordingGranted = false
            break
        case AVAudioSessionRecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (allowed) in
                    if allowed {
                        self.isAudioRecordingGranted = true
                    } else {
                        self.isAudioRecordingGranted = false
                    }
            })
            break
        default:
            break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavBar()
    }
    
    // MARK: - Actions
    @objc func forwardAction() {
        if webView.canGoForward {
            webView.goForward()
        }
    }
    
    @objc func backAction() {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    func getMyJavaScript() -> String {
        if let filepath = Bundle.main.path(forResource: "WKWebViewGetUserMediaShim", ofType: "js") {
            do {
                return try String(contentsOfFile: filepath)
            } catch {
                return ""
            }
        } else {
           return ""
        }
    }

    
    // MARK: - Properties
    lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true
        webConfiguration.mediaTypesRequiringUserActionForPlayback = .video
        let controller = WKUserContentController()
        webConfiguration.userContentController = controller
        
//        let scriptSource = getMyJavaScript()
//        let script = WKUserScript(
//            source: "document.body.style = 'border: 20px solid red';",
//            source: scriptSource,
//            injectionTime: WKUserScriptInjectionTime.atDocumentStart,
//            forMainFrameOnly: true
//        )
//        webConfiguration.userContentController.addUserScript(script)
        
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        
        // apply shim
        WKWebViewGetUserMediaShim(webView: webView, contentController: controller)
        

        webView.uiDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    let forwardBarItem = UIBarButtonItem(title: "Forward", style: .plain, target: self, action: #selector(forwardAction))
    
    let backBarItem = UIBarButtonItem(title: "Backward", style: .plain, target: self, action: #selector(backAction))
    
}

extension ViewController {
    func setupUI() {
        self.view.backgroundColor = .white
        self.view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.topAnchor
                .constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            webView.leftAnchor
                .constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor),
            webView.bottomAnchor
                .constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            webView.rightAnchor
                .constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor)
        ])
    }
    
    func setupNavItem() {
        self.navigationItem.leftBarButtonItem = backBarItem
        self.navigationItem.rightBarButtonItem = forwardBarItem
    }
    
    func setupNavBar() {
        self.navigationController?.navigationBar
            .barTintColor = .systemBlue
        self.navigationController?.navigationBar
            .tintColor = .white
    }
}

