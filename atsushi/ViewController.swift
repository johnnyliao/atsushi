//
//  ViewController.swift
//  atsushi
//
//  Created by 廖淳聿 on 2016/4/21.
//  Copyright © 2016年 廖淳聿. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.stringByTrimmingCharactersInSet(NSCharacterSet.alphanumericCharacterSet().invertedSet)
        var int = UInt32()
        NSScanner(string: hex).scanHexInt(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

class ViewController: UIViewController {
    @IBOutlet weak var kanji_word: UILabel!
    @IBOutlet weak var word_type: UILabel!
    @IBOutlet weak var word_chinese: UILabel!
    @IBOutlet weak var word_kana: UILabel!
    @IBOutlet weak var chinese_title: UILabel!
    @IBOutlet weak var kana_title: UILabel!
    @IBOutlet weak var total_word_count: UILabel!
    @IBOutlet weak var word_level: UILabel!
    @IBOutlet weak var uchi_title: UILabel!
    @IBOutlet weak var yoso_title: UILabel!
    @IBOutlet weak var word_uchi: UILabel!
    @IBOutlet weak var word_yoso: UILabel!
    @IBOutlet weak var verb_group: UILabel!
    @IBOutlet weak var verb_type: UILabel!
    
    var orign_arr: Array<NSDictionary>!
    var remove_arr = [Int]()
    var list_arr = [Int]()
    var receive_data: NSMutableDictionary?
    var objects_pointer: NSMutableDictionary!
    var have_kanji = true
    var test_mode = false
    var now_count: Int = 0
    var last_swipe: Int = 0 // 0:初始 1:向左 2:向右
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        objects_pointer = ["word_type":["x":word_type.center.x, "y":word_type.center.y], "word_chinese":["x":word_chinese.center.x, "y":word_chinese.center.y], "word_kana":["x":word_kana.center.x, "y":word_kana.center.y], "chinese_title":["x":chinese_title.center.x, "y":chinese_title.center.y], "kana_title":["x":kana_title.center.x, "y":kana_title.center.y], "uchi_title":["x":uchi_title.center.x, "y":uchi_title.center.y], "yoso_title":["x":yoso_title.center.x, "y":yoso_title.center.y], "word_uchi":["x":word_uchi.center.x, "y":word_uchi.center.y], "word_yoso":["x":word_yoso.center.x, "y":word_yoso.center.y]]
        
        
        print(objects_pointer)
        word_type.adjustsFontSizeToFitWidth = true
        word_kana.adjustsFontSizeToFitWidth = true
        word_chinese.adjustsFontSizeToFitWidth = true
        
        /*let url: NSURL = NSURL(string: "http://54.201.255.61/course/get_word/")!
        var err: NSError?
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        
        let dataVal: NSData =  try! NSURLConnection.sendSynchronousRequest(request, returningResponse: nil)
        
        
        parseJSON(dataVal)*/
        
        search_word_config()
        
        //手勢向左滑
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        leftSwipe.direction = .Left
        view.addGestureRecognizer(leftSwipe)
        
        //手勢向右滑
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        rightSwipe.direction = .Right
        view.addGestureRecognizer(rightSwipe)
        
        //手勢向上
        let upSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        upSwipe.direction = .Up
        view.addGestureRecognizer(upSwipe)
        //手勢向下
        let downSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        downSwipe.direction = .Down
        view.addGestureRecognizer(downSwipe)
        
    }
    
    @IBAction func go_back_to_main_page(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func create_word_index_arr() {
        var index: Int?
        list_arr = [Int]()
        
        for index in 0...orign_arr.count - 1 {
            remove_arr.append(index)
            
        }
        
                // 抽取remove_arr.count次卡
        for index in 0...remove_arr.count - 1  {
            let number:Int = Int(arc4random_uniform(UInt32(remove_arr.count)))
            list_arr.append(remove_arr[number])
            remove_arr.removeAtIndex(number)
        }
        
        print("list_arr", list_arr)

    }
    
    func parseJSON(inputData: NSData){
        do {
            let boardsDictionary = try NSJSONSerialization.JSONObjectWithData(inputData, options:NSJSONReadingOptions.MutableContainers ) as? Array<NSDictionary>
            
            orign_arr = boardsDictionary
        } catch {
            // report error
        }
    }
    
    func get_ranom_word(plus: BooleanType) {
        if now_count == orign_arr.count {
            now_count = 0
            create_word_index_arr()
        }
        
        
        setting_storyboard_display(now_count)
        
        total_word_count.text = String(now_count + 1) + " / " + String(orign_arr.count)
        
        check_test_mode_status()
        
        if plus {
            now_count += 1
        }
        
    }
    
    func setting_storyboard_display(number: Int) {
        print("now_number", number)
        
        var word_display_kanji: String = orign_arr[list_arr[number]]["kanji"] as! String
        var word_display_type: String = orign_arr[list_arr[number]]["display_type"] as! String
        var word_setting_type: String = orign_arr[list_arr[number]]["type"] as! String
        var word_displya_chinese: String = orign_arr[list_arr[number]]["chinese"] as! String
        var word_displya_kana: String = orign_arr[list_arr[number]]["kana"] as! String
        var word_display_level: String = orign_arr[list_arr[number]]["level"] as! String
        
        
        //var word_display_number: String = orign_arr[list_arr[number]]["level"] as! String
        
        if let result_number = orign_arr[list_arr[number]]["number"] as? NSNumber {
            var word_display_number: String = "\(result_number)"
            //word_number.text = word_display_number
            word_level.text = word_display_level + "-" + word_display_number
        }
        
        if word_display_kanji.isEmpty {
            have_kanji = false
            
            if let y_pos = objects_pointer["word_kana"]!["y"] as? CGFloat {
                kanji_word.text = word_displya_kana
                word_kana.hidden = true
                kana_title.hidden = true
                word_chinese.center.y = y_pos
                chinese_title.center.y = y_pos
            }
            
            if let y_pos = objects_pointer["word_chinese"]!["y"] as? CGFloat {
                uchi_title.center.y = y_pos
                word_uchi.center.y = y_pos
            }
            
            if let y_pos = objects_pointer["word_uchi"]!["y"] as? CGFloat {
                yoso_title.center.y = y_pos
                word_yoso.center.y = y_pos
            }
            
        } else {
            have_kanji = true
            
            if let y_pos = objects_pointer["word_chinese"]!["y"] as? CGFloat {
                kanji_word.text = word_display_kanji
                word_kana.text = word_displya_kana
                word_kana.hidden = false
                kana_title.hidden = false
                word_chinese.center.y = y_pos
                chinese_title.center.y = y_pos
            }
            
            if let y_pos = objects_pointer["word_uchi"]!["y"] as? CGFloat {
                uchi_title.center.y = y_pos
                word_uchi.center.y = y_pos
            }
            
            if let y_pos = objects_pointer["word_yoso"]!["y"] as? CGFloat {
                yoso_title.center.y = y_pos
                word_yoso.center.y = y_pos
            }
            
        }
        
        if let uchi_data = orign_arr[list_arr[number]]["uchi"] as? NSMutableDictionary {
            var uchi_kanji = uchi_data["kanji"] as! String
            var word_uchi_text: String!
            
            if uchi_kanji.isEmpty {
                word_uchi_text = uchi_data["kana"] as! String
            } else {
                var uchi_kana = uchi_data["kana"] as! String
                word_uchi_text = uchi_kanji + " / " + uchi_kana
            }
             word_uchi.text = word_uchi_text
            uchi_title.hidden = false
            word_uchi.hidden = false
        } else {
            uchi_title.hidden = true
            word_uchi.hidden = true
        }

        if let yoso_data = orign_arr[list_arr[number]]["yoso"] as? NSMutableDictionary {
            var yoso_kanji = yoso_data["kanji"] as! String
            var word_yoso_text: String!
            
            if yoso_kanji.isEmpty {
                word_yoso_text = yoso_data["kana"] as! String
            } else {
                var yoso_kana = yoso_data["kana"] as! String
                word_yoso_text = yoso_kanji + " / " + yoso_kana
                
            }
            word_yoso.text = word_yoso_text
            yoso_title.hidden = false
            word_yoso.hidden = false
        } else {
            yoso_title.hidden = true
            word_yoso.hidden = true
        }
      
        word_type.text = word_display_type
        word_chinese.text = word_displya_chinese
        
        //判斷word_setting_type是否為數字 是數字為動詞
        if let type_num = Int(word_setting_type) {
            var word_setting_group: String = orign_arr[list_arr[number]]["group"] as! String
            print("word_setting_group", word_setting_group)
            switch word_setting_group {
                case "1":
                    verb_group.text = "I"
                case "2":
                    verb_group.text = "II"
                default:
                    verb_group.text = "III"
            }
            verb_type.text = word_setting_type
        }
        
        setting_story_board_word_color(word_setting_type)
    }
    
    func setting_story_board_word_color(word_setting_type: String) {
        word_type.textColor = UIColor(hexString: "#FFFFFF")
        
        word_type.sizeToFit()
        
        verb_type.hidden = true
        verb_group.hidden = true
        
        switch word_setting_type {
            case "noun":
                word_type.backgroundColor = UIColor(hexString: "#FFFF00")
                word_type.textColor = UIColor(hexString: "#000000")
            case "adj":
                word_type.backgroundColor = UIColor(hexString: "#0066FF")
            case "time":
                word_type.backgroundColor = UIColor(hexString: "#FF44AA")
            case "sulu_noun" :
                word_type.backgroundColor = UIColor(hexString: "#AA7700")
                //word_type.textColor = UIColor(hexString: "#000000")
            case "na_noun" :
                word_type.backgroundColor = UIColor(hexString: "#FFBB00")
        default:
            //"verb" type為數字
            word_type.backgroundColor = UIColor(hexString: "#00AA00")
            verb_type.hidden = false
            verb_group.hidden = false
        }
        
    }
    
    func search_word_config() {
        if let search_result = receive_data?["search_result"] as? Array<NSDictionary> {
            //print(search_result)
            orign_arr = search_result
            create_word_index_arr()
            get_ranom_word(true)
        } else {
            print("no search_result")
        }
    }
    
    //手勢滑動偵測
    func handleSwipes(sender:UISwipeGestureRecognizer) {
        if (sender.direction == .Left) {
            print("Swipe Left")
            if last_swipe == 2 {
                now_count += 1
            }
            get_ranom_word(true)
            last_swipe = 1
        }
        
        if(sender.direction == .Up) {
            print("Swipe Up")
            test_mode = true
            check_test_mode_status()
        }
        
        if(sender.direction == .Down) {
            print("Swipe Down")
            test_mode = false
            check_test_mode_status()
        }
        
        if(sender.direction == .Right) {
            print("Swipe Right")
            if now_count == 0 {
                return
            }
            
            if last_swipe == 1 {
                now_count -= 2
            } else {
                now_count -= 1
            }
            
            get_ranom_word(false)
            last_swipe = 2
        }
    
    }
    
    func check_test_mode_status() {
        if test_mode == false {
            if have_kanji {
                word_kana.hidden = false
            }
            word_chinese.hidden = false
        } else {
            word_chinese.hidden = true
            word_kana.hidden = true
        }
    }
    
    /*
    @IBAction func test_mode_change(sender: AnyObject) {
        check_test_mode_status()
    }*/
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

