
# Hướng dẫn viết ứng dụng gọi video trên nền tảng iOS với Stringee Call API.

Với sự phát triển không ngừng của công nghệ, việc phải kết nối và giao tiếp trực tuyến trở nên ngày càng phổ biến. Trong thời đại mà video call đã trở thành một phần không thể thiếu của cuộc sống hằng ngày, việc xây dựng một ứng dụng gọi video chất lượng là và ổn định là cực kỳ cần thiết.


# Giới thiệu

Stringee Call API là một trong những công cụ mạnh mẽ và dễ sử dụng để tạo ra các ứng dụng gọi video trên nền tảng iOS. Với Stringee Call API, bạn có thể tạo ra các ứng dụng gọi video linh hoạt, đáp ứng nhu cầu của người dùng.

Trong bài viết này, chúng tôi sẽ hướng dẫn bạn cách sử dụng Stringee Call API để xây dựng một ứng dụng gọi video trên nền tảng iOS. Chúng tôi sẽ đi qua các bước cần thiết để cài đặt API, thiết kế giao diện và viết code để xử lý các sự kiện trong cuộc gọi video.

# Chuẩn bị

1. Before using the Stringee Call API for the first time, you must have a Stringee account. If you do not have a Stringee account, sign up for free here: https://developer.stringee.com/account/register


2. Create a Project on the Stringee Dashboard.
![Stringee create Project](https://static.stringee.com/docs/images/android/20171101/create_stringee_project.png "Stringee create Project")

## Cài đặt Stringee SDK

Để cài đặt Stringee SDK sử dụng CocoaPods, bạn cần làm theo các bước sau:

1. Mở Podfile của dự án và khai báo Stringee:
    2. `pod 'Strinee'`
2. Chạy lệnh sau trên Terminal:
    `pod install --repo-update`
3. Thêm một số config sau trong Build Settings:
    ```
    "Other linker flags" Thêm "(inherited)"
    "Enable bitcode" chọn "NO"
    ```
4. Cấu hình quyền sử dụng Camera và Microphone trong file Info.plist:
    ```
    <key>NSCameraUsageDescription</key>
      <string>$(PRODUCT_NAME) uses Camera</string> 
    <key>NSMicrophoneUsageDescription</key>
      <string>$(PRODUCT_NAME) uses Microphone</string>
    ```
    
## Thiết kế giao diện

Để bắt đầu, chúng ta cần tạo giao diện cho ứng dụng của mình, ở bài viết này mình sẽ sử dụng 3 ViewController sau để thực hiện video call.

1. **StringeeConnectViewController** màn hình quản lý trạng thái của client ( connect/disconnect) thực hiện tạo cuộc gọi đến một client khác.
2. **IncomingCallViewController** Popup thông báo khi có cuộc gọi đến thực hiện các sự kiện trả lời, hoặc từ chối cuộc gọi.
3. **CallingViewController**  Màn hình quản lý trạng thái xử lý các logic của cuộc gọi.

![UI](https://static.stringee.com/blog/images/ui_ios_demo.png)

## Xử lý logic
### 1. Tạo kết nối tới StringeeServer
Ở lớp này chúng ta sẽ kết nối tới Stringee Server.
```
import UIKit
import Stringee
class StringeeConnectViewController: UIViewController {
    private let userToken = "PUSH-YOUR-TOKEN-HEARE"
    
    let client = StringeeClient()    
    
    private func setupStringee() {
        client.connect(withAccessToken: userToken)
    }
}
```
Implement StringeeConnectionDelegate để xử lý các sự kiện liên quan đết kết nối tới StringeeServer:
```
import UIKit
import Stringee
class StringeeConnectViewController: UIViewController {
    private let userToken = "PUSH-YOUR-TOKEN-HEARE"
    
    let client = StringeeClient()    
    
    private func setupStringee() {
        client.connectionDelegate = self
        client.connect(withAccessToken: userToken)
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
```

### 2. Xử lý sự kiện khi có cuộc gọi đến
Implement StringeeIncomingCallDelegate để xử lý sự kiện khi có cuộc gọi đến

```
import UIKit
import Stringee
class StringeeConnectViewController: UIViewController {
    private let userToken = "PUSH-YOUR-TOKEN-HEARE"
    
    let client = StringeeClient()

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination  as? IncomingCallViewController,
           let call = sender as? StringeeCall2 {
               vc.call = call
               vc.ansAction = { [weak self] in
                   DispatchQueue.main.async {
                       guard let self = self else { return }
                        self.performSegue(withIdentifier: "showCallScreen", sender: call)
                    }
                }
        }
    }
    private func setupStringee() {
        client.connectionDelegate = self
        client.incomingCallDelegate = self
        client.connect(withAccessToken: userToken)
    }
}
extension StringeeConnectViewController: StringeeIncomingCallDelegate {
    func incomingCall(with stringeeClient: StringeeClient!, stringeeCall2: StringeeCall2!) {
        DispatchQueue.main.async {
            if stringeeCall2.signalingState != .busy || stringeeCall2.signalingState != .ended {
                self.performSegue(withIdentifier: "showCallScreen", sender: stringeeCall2)
            }
        }
    }
}
```

### 3. Tạo một cuộc gọi video
Khi người dùng nhập UserID của người nhận cuộc gọi và nhấn nút **start video call** ta thực hiện tạo một cuộc gọi Video Call như sau: 

```
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? CallingViewController,
        let call = sender as? StringeeCall2 {
            vc.call = call
        }
    }
    @IBAction func didTapCall(_sender: Any) {
        if let fromUser = client.userId, !fromUser.isEmpty,
           let toUser = self.userIdTf.text, toUser.isEmpty, client.hasConnected {
               let call = StringeeCall(stringeeClient: client,from: fromUser, to: toUser)
               call?.isVideoCall = true
               performSegue(withIdentifier: "showCallScreen", sender: call) 
           }
    }
``` 

### 4. Trả lời/Từ chối cuộc cuộc gọi
```
import UIKit
import Stringee

class  IncomingCallViewController: UIViewController {
    @IBOutlet weak var userIDLBL: UILabel!
    var call: StringeeCall2!
    var ansAction: (() -> Void)?
    override func  viewDidLoad() {
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
```
### 5. Xử lý sự kiện và logic trong cuộc gọi
#### 5.1 setup cuộc gọi

Một cuộc gọi sẽ có 2 trường hợp:

 - ***Incoming call:*** Để bắt đầu cuộc gọi này, ta thực hiện gọi ***call.initAnswer()*** trước khi gọi hàm ***call.answer {status, code, msg in } *** để bắt đầu cuộc gọi.
 -  ***outgoing call:*** Để bắt đầu một cuộc gọi ra ta gọi hàm ***call.make{ status, code, clientMsg, serverMsg in  }***
 
 ```
 class CallingViewController: UIViewController {
     private func setupCall() {
         if call.isIncomingCall {
             call.initAnswer()
             call.answer { status, code,msg in } 
         } else {
             call.make { status, code, clientMsg, serverMsg in }
         }
     }
 } 
 ```

Tiếp theo chúng ta sẽ gán delegate vào viewController để lắng nghe các sự kiện trong cuộc gọi.
 ```
 class CallingViewController: UIViewController {
     private func setupCall() {
         call.delegate = self
         if call.isIncomingCall {
             call.initAnswer()
             call.answer { status, code,msg in } 
         } else {
             call.make { status, code, clientMsg, serverMsg in }
         }
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
 }
 ```

Hiển thị local video và remote video:
```
 extension CallingViewController: StringeeCall2Delegate {
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
```
#### 5.2 một số chức năng khác trong cuộc gọi video
Thay đổi sử dụng camera trước và sau:
```
    @IBAction func didTapSwitchCamera(_sender: Any) {
        call.switchCamera()
    }
```
Ngắt cuộc gọi:
```
    @IBAction func didTapHangup(_ sender: Any) {
        call.hangup { status, code, mess in
            if !status {
                print(mess ?? "")
            }
        }
    }
```
Tắt/Bật tiếng microphone:
```
    @IBAction func didTapMute() {
        self.isMute = !self.isMute
        self.call.mute(self.isMute)
    }
```
Tắt/Bật Camera 
```
    @objc func didTapCameraBtn() {
        self.isEnableLocalVideo = !self.isEnableLocalVideo
        self.localVideo.isHidden = !self.isEnableLocalVideo
        self.call.enableLocalVideo(self.isEnableLocalVideo)
    }
```

## Kết luận
Trong bài viết này, chúng ta đã tìm hiểu về Stringee Call API - một công nghệ cho phép tích hợp chức năng gọi video và âm thanh vào ứng dụng của bạn trên nền tảng iOS. Chúng ta đã học cách cài đặt Stringee SDK thông qua CocoaPods, thiết kế giao diện người dùng cho ứng dụng của mình và viết mã để tích hợp Stringee Call API.

Ngoài ra, bài viết này cũng có video hướng dẫn chi tiết về cách tích hợp Stringee Call API vào ứng dụng của bạn trên nền tảng iOS. Bạn có thể xem video này để có cái nhìn rõ ràng hơn về cách tích hợp Stringee Call API.

Cuối cùng, để giúp bạn có được một khởi đầu nhanh chóng và dễ dàng với Stringee Call API, chúng tôi đã tạo một [GitHub project mẫu](https://github.com/HiepH-Stringee/VideoCallSample.git). Bạn có thể tải xuống và tham khảo code từ project này để bắt đầu phát triển ứng dụng của mình.

Chúng tôi hy vọng bài viết này đã giúp bạn hiểu rõ hơn về Stringee Call API và cách tích hợp nó vào ứng dụng của bạn trên nền tảng iOS. Nếu bạn gặp bất kỳ vấn đề nào trong quá trình tích hợp Stringee Call API, vui lòng liên hệ với chúng tôi để được hỗ trợ.
