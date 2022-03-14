//
//  ViewController.swift
//  testCallbackHell
//
//  Created by user on 2022/02/09.
//

import UIKit
import Alamofire
import PromiseKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var txtArea: UITextView!
    @IBAction func btnDown(_ sender: Any) {
        
        self.txtArea.text = ""
        let afterFunc = { (_ url:String) in//2
            let afterFunc2 = { (_ text:String) in//5
                self.txtArea.text += text + "\n"
            }
            self.getTerm(strUrl: url, afterFunc: afterFunc2)//3
            
        }
        self.getList(afterFunc: afterFunc)//1
        
        
        _ = Promise<String> { seal in
            
            self.getList(afterFunc: { (_ url:String) in//1
                seal.fulfill(url)
            })
            
        }.then { url in Promise<String>
            { seal in
                self.getTerm(strUrl: url, afterFunc: { (_ text:String) in//2
                    seal.fulfill(text)
                })
            }
        }.then { text in Promise<Void>
            { seal in
                self.txtArea.text += text + "\n"
                seal.fulfill_()
            }
        }.then { Void in Promise<Void>
            { seal in
                // 他のコールバック処理好きなだけ
                seal.fulfill_()
            }
        }.then { Void in Promise<Void>
            { seal in
                // 他のコールバック処理好きなだけ
                seal.fulfill_()
            }
        }.ensure {
            // nothing to do
            
        }.catch { error in
            print(error)
        }
        
        
        
        
    }
    
    func getList( afterFunc: @escaping (_ url:String)->Void ){
        
        let url = URL(string: "http://qiita.com/api/v2/items")!
        let parameters: Parameters = ["page": 1, "per_page": 10]
        Alamofire.request(url, method: .get, parameters: parameters )
        
            .responseJSON { response in
                
                switch response.result {
                    
                    // 処理成功時
                case .success(let value):
                    
                    let json = JSON(value)
                    let arrJson = json.array
                    for m in arrJson! {
                        let url = m["url"].rawString() ?? ""
                        afterFunc(url)//2
                        return
                    }
                    break
                    // 処理失敗時
                case .failure(let error):
                    print(error)
                    break
                }
            }
    }
    
    func getTerm( strUrl:String, afterFunc: @escaping (_ text:String)->Void ){
        
        let url = URL(string: strUrl)!
        Alamofire.request(url, method: .get )
            .response { response in//4
                
                guard let status = response.response?.statusCode else { return }
                let text = strUrl + " " + String(status)
                afterFunc( text )//5
                
            }
    }
}

