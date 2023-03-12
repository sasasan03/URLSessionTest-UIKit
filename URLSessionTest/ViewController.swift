//
//  ViewController.swift
//  URLSessionTest
//
//  Created by sako0602 on 2023/03/06.
//

import UIKit

//Userを内包している記事データ
struct Item: Decodable {
    let title: String
    let createdAt: String
    let user: User? //入れ子になったものは使える
    
    enum  CodingKeys: String, CodingKey {
        case title
        case createdAt = "created_at"//これで対応付けができる
        case user
    }
}

//userdataを取り出すための構造体
struct User: Decodable {
    let name: String
    let profileImageURL: URL
    
    enum CodingKeys: String, CodingKey {
        case name
        //Jsonの場合はこんな感じ
        case profileImageURL = "profile_image_url"
    }
}
                                          //⏬つける
class ViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    var items: [Item] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Task { //aysnc awaitの非同期処理のため今回はTaskに入れる

            let url = URL(string:
                            "https://qiita.com/api/v2/items?page=1&per_page=10")!//今回はページがあることが保証されている
            let (data, _ ) = try await URLSession.shared.data(from: url)//responseは今回使っていないため _ になっている

//            print(data) //157413 bytes変わっていく
            
//            let text = String(data: data, encoding: .utf8)
            //ただの文字列として出力。超長いJsonになる
//            print(text)
            DispatchQueue.main.async { [weak self] in //do try なし。Invalid conversion from throwing function of type '@Sendable () throws -> Void' to non-throwing function type '@MainActor @Sendable @convention(block) () -> Void'
                do {
                    //①どんな型にパースするのか？[Item]に変換する。②fromにはURLにアクセスしてて取ってきたdataを入れてあげる
                    //.decodeは throwがあるためエラーを発生させる。＝tryが必要
        //            do {
                    //⏬初期はlet
                    self?.items = try JSONDecoder().decode([Item].self, from: data)

//                        print("items: \(items)")
        //                let imageURL = items.first?.user.profileImageURL
        //            } catch {
                        
        //            }
                    self?.tableView.reloadData()
                } catch {
                    
                }
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { //表示するデータの数
        items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)//for で cellのインスタンスをとってくる
        //⏬cellインスタンスからcontentConfigurationをとってくる
        var configuration = cell.defaultContentConfiguration()
        //⏬[indexPathの.row番目]のものをとってきて、そのタイトルをtextに設定する
        configuration.text = items[indexPath.row].title
        //⏬cellのcontentConfigurationに今設定したconfigurationを設定する
        cell.contentConfiguration = configuration
        
        return cell
    }
}

