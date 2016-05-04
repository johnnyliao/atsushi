//
//  MainViewController.swift
//  atsushi
//
//  Created by 廖淳聿 on 2016/4/25.
//  Copyright © 2016年 廖淳聿. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate {
    @IBOutlet weak var input_word: UITextField!
    @IBOutlet weak var class_level: UIButton!
    @IBOutlet weak var class_level_value: UILabel!
    @IBOutlet weak var class_date_value: UILabel!
    @IBOutlet weak var search_type_value: UILabel!
    
    var pickerView: UIPickerView?
    var date_pick_option = ["all", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17"]
    var level_pick_option = ["all", "J1", "J2", "J3", "J4", "J5", "J6", "J7", "J8", "J9"]
    var search_type_option = ["文法", "單字"]
    
    var pickOption:[[String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickOption = [search_type_option, level_pick_option, date_pick_option]
        
        input_word.delegate = self
        pickerView = UIPickerView(frame: CGRectMake(0, 0, 295, 150))
        pickerView!.delegate = self
                
    }
    
    @IBAction func class_level_picker(sender: AnyObject) {
    
        let alertView = UIAlertController(title: "選則課程", message: "\n\n\n\n\n", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        
        alertView.modalInPopover = true;
        alertView.view.addSubview(pickerView!)
        
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        
        alertView.addAction(action)
        presentViewController(alertView, animated: true, completion: nil)
    }
    
    //收起鍵盤
    override func touchesBegan(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        input_word.resignFirstResponder()
    }
    

    @IBAction func search_word(sender: AnyObject) {
        var post_url: String!
        
        if search_type_value.text == "文法" {
            post_url = "/course/search_grammar/"
        } else {
            post_url = "/course/search_word/"
        }
        
        let url: NSURL = NSURL(string: SERVER_URL + post_url)!
        
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        var stringPost = "word="+input_word.text! + "&number=" + class_date_value.text! + "&level=" + class_level_value.text!
        
        request.timeoutInterval = 60
     
        request.HTTPShouldHandleCookies=false
        
        let queue:NSOperationQueue = NSOperationQueue()
        
        request.HTTPBody = stringPost.dataUsingEncoding(NSUTF8StringEncoding);
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {
            (response, data, error) in
            let data_val: NSData = data!
            
            var search_result: Array<NSDictionary> = self.parse_JSON(data_val)
            
            if search_result.count == 0 {
                print("no search result ")
                self.show_no_search_result()
                return
            }
            
            
            let dict_params: NSMutableDictionary? = ["search_result" : search_result]
            let sb = UIStoryboard(name: "Main", bundle:nil)
            
            if self.search_type_value.text == "文法" {
                let vc = sb.instantiateViewControllerWithIdentifier("GRAMMAR_LIST_VC") as! GrammarViewController
                vc.receive_data = dict_params
                self.presentViewController(vc, animated: true, completion: nil)
            } else {
                let vc = sb.instantiateViewControllerWithIdentifier("WORD_DETAIL_VC") as! ViewController
                vc.receive_data = dict_params
                self.presentViewController(vc, animated: true, completion: nil)
            }
            
            return
        }
    }
    
    func parse_JSON(inputData: NSData) -> Array<NSDictionary>{
        var result: Array<NSDictionary>?
        
        do {
            let boardsDictionary = try NSJSONSerialization.JSONObjectWithData(inputData, options:NSJSONReadingOptions.MutableContainers ) as? Array<NSDictionary>
            
            return boardsDictionary!
        } catch {
            // report error
        }
        
        return result!
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    
    /*
    func textFieldDidBeginEditing(textField: UITextField) {
        print("TextField did begin editing method called")
    }
    func textFieldDidEndEditing(textField: UITextField) {
        print("TextField did end editing method called")
    }
    
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        print("TextField should begin editing method called")
        return true;
    }
    func textFieldShouldClear(textField: UITextField) -> Bool {
        print("TextField should clear method called")
        return true;
    }
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        print("TextField should snd editing method called")
        return true;
    }
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        print("While entering the characters this method gets called")
        return true;
    }*/
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        print("TextField should return method called")
        textField.resignFirstResponder()
        return true;
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 3
    }
    
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return search_type_option.count
        } else if component == 1 {
            return level_pick_option.count
        } else {
            return date_pick_option.count
        }
    }
    
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickOption[component][row]
    }
    
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            return search_type_value.text = search_type_option[row] as! String
        } else if component == 1 {
            return class_level_value.text = level_pick_option[row] as! String
        } else {
            return class_date_value.text = date_pick_option[row] as! String
        }
    }
    
    
    //设置行高
    func pickerView(pickerView: UIPickerView,rowHeightForComponent component: Int) -> CGFloat{
        return 40
    }
    
    func show_no_search_result() {
        let alertController = UIAlertController(title: "ごめん", message:
            "搜尋不到單字", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "確定", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
   
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
