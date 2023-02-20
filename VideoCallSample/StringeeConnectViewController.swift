//
//  StringeeConnectViewController.swift
//  VideoCallSample
//
//  Created by Hiệp Hoàng on 16/02/2023.
//

import UIKit
import Stringee

class StringeeConnectViewController: UIViewController {
    
    let client = StringeeClient()
    
    let userToken = "eyJjdHkiOiJzdHJpbmdlZS1hcGk7dj0xIiwidHlwIjoiSldUIiwiYWxnIjoiSFMyNTYifQ.eyJqdGkiOiJTSy4wLlZBOU1JODhobXVSemNJbUFTZFUwdUE2SDZuWWd6elAtMTY3NjUzMDkwNCIsImlzcyI6IlNLLjAuVkE5TUk4OGhtdVJ6Y0ltQVNkVTB1QTZINm5ZZ3p6UCIsImV4cCI6MTY3NjYxNzMwNCwidXNlcklkIjoiMTIzNCJ9.9JyKDNkQUgynNFWHCHfsmFk35x6ztrJMphCip5uTVus"
    
    let userToken2 = "eyJjdHkiOiJzdHJpbmdlZS1hcGk7dj0xIiwidHlwIjoiSldUIiwiYWxnIjoiSFMyNTYifQ.eyJqdGkiOiJTSy4wLlZBOU1JODhobXVSemNJbUFTZFUwdUE2SDZuWWd6elAtMTY3NjUzNzYxNiIsImlzcyI6IlNLLjAuVkE5TUk4OGhtdVJ6Y0ltQVNkVTB1QTZINm5ZZ3p6UCIsImV4cCI6MTY3NjYyNDAxNiwidXNlcklkIjoiMTIzNSJ9.YCajGe5oT5qKUXAY5opr09gpI-LFfYpnoOsQaJ_e5l0"

    @IBOutlet weak var userIdTf: UITextField!
    @IBOutlet weak var statusLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStringee()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? IncomingCallViewController,
           let call = sender as? StringeeCall2 {
            vc.call = call
            vc.ansAction = { [weak self] in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.performSegue(withIdentifier: "showCallScreen", sender: call)
                }
            }
        }
        if let vc = segue.destination as? CallingViewController,
           let call = sender as? StringeeCall2 {
            vc.call = call
        }
    }
    
    private func setupStringee() {
        client.connectionDelegate = self
        client.incomingCallDelegate = self
        client.connect(withAccessToken: userToken)
    }
    

    @IBAction func didTapCall(_ sender: Any) {
        if let fromUser = client.userId,
           !fromUser.isEmpty,
           let toUser = self.userIdTf.text,
           !toUser.isEmpty,
           client.hasConnected {
            let call = StringeeCall(stringeeClient: client, from: fromUser, to: toUser)
            call?.isVideoCall = true
            performSegue(withIdentifier: "showCallScreen", sender: call)
        }
        
    }

}

extension StringeeConnectViewController: StringeeConnectionDelegate {
    func requestAccessToken(_ stringeeClient: StringeeClient!) {
        print("token exp")
    }
    
    func didConnect(_ stringeeClient: StringeeClient!, isReconnecting: Bool) {
        self.statusLbl.text = stringeeClient.userId
    }
    
    func didDisConnect(_ stringeeClient: StringeeClient!, isReconnecting: Bool) {
        self.statusLbl.text = "Disconnect"
    }
    
    func didFailWithError(_ stringeeClient: StringeeClient!, code: Int32, message: String!) {
        print("Connect Error ====> \(message ?? "")")
    }
    
    
}

extension StringeeConnectViewController: StringeeIncomingCallDelegate {
    func incomingCall(with stringeeClient: StringeeClient!, stringeeCall: StringeeCall!) {
    }
    
    func incomingCall(with stringeeClient: StringeeClient!, stringeeCall2: StringeeCall2!) {
        DispatchQueue.main.async {
            if stringeeCall2.signalingState != .busy || stringeeCall2.signalingState != .ended {
                self.performSegue(withIdentifier: "showCallScreen", sender: stringeeCall2)
            }
        }
    }
    
}
