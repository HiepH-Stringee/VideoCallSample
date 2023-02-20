//
//  CallingViewController.swift
//  VideoCallSample
//
//  Created by Hiệp Hoàng on 16/02/2023.
//

import UIKit
import Stringee

class CallingViewController: UIViewController {
    
    @IBOutlet weak var cameraBtn: UIButton!
    @IBOutlet weak var soundBtn: UIButton!
    @IBOutlet weak var hangupBtn: UIButton!
    @IBOutlet weak var muteBtn: UIButton!
    
    private var isEnableSpeaker = true
    private var isEnableLocalVideo = true

    
    
    var call: StringeeCall2!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var remoteVideo: UIView!
    @IBOutlet weak var localVideo: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCall()
        StringeeAudioManager.instance().setLoudspeaker(true)
        setupAction()
    }

    private func setupCall() {
        call.delegate = self
        if call.isIncomingCall {
            call.initAnswer()
            call.answer { _, _, _ in }
            
        }else {
            call.make { status, _, mess, mess1 in
                if !status {
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    private func setupAction() {
        cameraBtn.addTarget(self, action: #selector(didTapCameraBtn), for: .touchUpInside)
        soundBtn.addTarget(self, action: #selector(didTapSpeaker), for: .touchUpInside)
        hangupBtn.addTarget(self, action: #selector(didTapHangup), for: .touchUpInside)
        
    }
    
    @objc func didTapCameraBtn() {
        self.isEnableLocalVideo = !self.isEnableLocalVideo
        self.localVideo.isHidden = !self.isEnableLocalVideo
        self.call.enableLocalVideo(self.isEnableLocalVideo)
    }
    
    @objc func didTapSpeaker() {
        self.isEnableSpeaker = !self.isEnableSpeaker
        StringeeAudioManager.instance().setLoudspeaker(self.isEnableSpeaker)
    }
    
    @objc func didTapHangup() {
        call.hangup { status, code, mess in
            if !status {
                print(mess ?? "")
            }
        }
    }
        
    @IBAction func didTapSwitchCamera(_ sender: Any) {
        call.switchCamera()
    }
    
}

extension CallingViewController: StringeeCall2Delegate {

    
    func didChangeSignalingState2(_ stringeeCall2: StringeeCall2!, signalingState: SignalingState, reason: String!, sipCode: Int32, sipReason: String!) {
        DispatchQueue.main.async {
            switch signalingState {
            case .calling:
                self.status.text = "calling"
            case .ringing:
                self.status.text = "ringing"
            case .answered:
                self.status.text = "answered"
            default:
                self.navigationController?.popViewController(animated: true)
            }
        }
        
    }
    
    func didChangeMediaState2(_ stringeeCall2: StringeeCall2!, mediaState: MediaState) {
        DispatchQueue.main.async {
            self.status.text = mediaState == .connected ? "connnected" : "disconnect"
        }
    }
    
    func didReceiveLocalStream2(_ stringeeCall2: StringeeCall2!) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            stringeeCall2.localVideoView.frame = CGRect(origin: .zero, size: self.localVideo.frame.size)
            self.localVideo.insertSubview(stringeeCall2.localVideoView, at: 0)
        }
    }
    
    func didReceiveRemoteStream2(_ stringeeCall2: StringeeCall2!) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            stringeeCall2.remoteVideoView.frame = CGRect(origin: .zero, size: self.remoteVideo.frame.size)
            self.remoteVideo.insertSubview(stringeeCall2.remoteVideoView, at: 0)
        }
    }
}
