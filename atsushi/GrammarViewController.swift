//
//  GrammarViewController.swift
//  atsushi
//
//  Created by 廖淳聿 on 2016/5/3.
//  Copyright © 2016年 廖淳聿. All rights reserved.
//

import UIKit

class GrammarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var GRAMMAR_TABLE_VIEW: UITableView!
    
    var receive_data: NSMutableDictionary?
    var SEARCH_RESULT: Array<NSDictionary>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let search_result = receive_data?["search_result"] as? Array<NSDictionary> {
            //print(search_result)
            print(search_result)
            SEARCH_RESULT = search_result
        } else {
            print("no search_result")
        }
        
        let nib = UINib(nibName: "GrammarTableCell", bundle: nil)
        
        //註冊，forCellReuseIdentifier是你的TableView裡面設定的Cell名稱
        GRAMMAR_TABLE_VIEW.registerNib(nib, forCellReuseIdentifier: "GrammarCell")
     
        GRAMMAR_TABLE_VIEW.dataSource = self
        GRAMMAR_TABLE_VIEW.delegate = self
    }
    
    @IBAction func GO_BACK_TO_MAIN_PAGE(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("已選擇的cell編號: \(indexPath.row)")
        //print("cell值: \(dyItems[indexPath.row])")
        print("\r\n")
    }
    
    //MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SEARCH_RESULT!.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //取得myTableView的cell，名稱是myTableView輸入的Cell Identifier
        let cell = GRAMMAR_TABLE_VIEW.dequeueReusableCellWithIdentifier("GrammarCell", forIndexPath: indexPath) as! GrammarTableViewCell;
        
        let title = SEARCH_RESULT![indexPath.row]["title"] as! String
        
        var word_display_level = SEARCH_RESULT![indexPath.row]["level"] as! String
        var g_number = SEARCH_RESULT![indexPath.row]["g_number"] as! String
        
        //var word_display_number: String = orign_arr[list_arr[number]]["level"] as! String
        
        cell.G_NUMBER.text = g_number
        cell.CONTENT.text = title
        cell.LEVEL.text = word_display_level
        
        return cell
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
