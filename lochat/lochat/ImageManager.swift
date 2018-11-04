//
//  ImageManager.swift
//  
//
//  Created by 中田　優樹 on 2018/11/04.
//

import Foundation
import Alamofire

class ImageManager: NSObject{
    
    
    func send_to_flask(originImage: UIImage, framedImage: UIImage){
        let urlStr = "https://lochat-python.herokuapp.com/image_post?user_id="+UserDefaults.standard.string(forKey: UDKey_userID)! + "&event_id=" + UserDefaults.standard.string(forKey: UDKey_joinedEventID)!
        let originImageData = originImage.jpegData(compressionQuality: 1.0)
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                // 送信する値の指定をここでします
                multipartFormData.append(originImageData!, withName: "img_file", fileName:"aaa.jpg" ,mimeType: "image/jpg")
//                multipartFormData.append(framedImage, withName: "img", mimeType: <#T##String#>)
        },
            to: urlStr,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        // 成功
                        let responseData = response
                        print(responseData ?? "成功")
                    }
                case .failure(let encodingError):
                    // 失敗
                    print(encodingError)
                }
        })
    }
}
