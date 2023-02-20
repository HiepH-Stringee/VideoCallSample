//
//  IncomingCallViewController.swift
//  VideoCallSample
//
//  Created by Hiệp Hoàng on 16/02/2023.
//

import UIKit
import Stringee

class IncomingCallViewController: UIViewController {

    @IBOutlet weak var userIDLBL: UILabel!
    var call: StringeeCall2!
    var ansAction: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userIDLBL.text = "Call from \(call.from ?? "stringee")"
    }
    
    @IBAction func didTapReject(_ sender: Any) {
        call.reject { [weak self] status, code, message in
            guard let self = self else { return }
            if status {
                self.dismiss(animated: true)
            }else {
                print("Reject call error ===> \(code) - \(message ?? "")")
            }
        }
    }
    
    @IBAction func didTapAnswer(_ sender: Any) {
        self.dismiss(animated: true) {
            self.ansAction?()
        }
    }
}
