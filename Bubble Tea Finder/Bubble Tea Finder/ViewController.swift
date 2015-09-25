//
//  ViewController.swift
//  Bubble Tea Finder
//
//  Created by Pietro Rea on 8/24/14.
//  Copyright (c) 2014 Pietro Rea. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController,FilterViewControllerDelegate {
  
  @IBOutlet weak var tableView: UITableView!
  var coreDataStack: CoreDataStack!
	
	var fetchRequest: NSFetchRequest!
//	var venues: [Venue]!
	var venues: [Venue]! = []
	
	var asyncFetchRequest: NSAsynchronousFetchRequest!
	
  override func viewDidLoad() {
    super.viewDidLoad()
		
		// 普通请求 注意更改上下文异步类型
//		noramlFetch()
		
		// 异步请求
//		asyncFetchRequest()
		
		// 批量无请求 ios8
		batchNoFetch()
  }
	
	// MARK: 批量无请求
	func batchNoFetch() {
		// 批量请求：指明更新属性 指明作用存储 指明结果类型
		let batchUpdate = NSBatchUpdateRequest(entityName: "Venue")
		batchUpdate.propertiesToUpdate = ["favorite": NSNumber(bool: true)]
		batchUpdate.affectedStores = coreDataStack.psc.persistentStores
		batchUpdate.resultType = NSBatchUpdateRequestResultType.UpdatedObjectsCountResultType
		
		// 执行 - 返回NSBatchUpdateResult
		do {
			let result = try coreDataStack.context.executeRequest(batchUpdate) as! NSBatchUpdateResult
			print("更新记录：\(result.result)")
		}catch let error as NSError {
			print("未能批量更新\(error),\(error.userInfo)")
		}
		
	}
	
	// MARK: 异步请求
	func asynFetch() {
		// 1 创建请求
		fetchRequest = NSFetchRequest(entityName: "Venue")
		
		// 2 异步请求 ＋ 完成回调更新UI
		asyncFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetchRequest, completionBlock: { (results: NSAsynchronousFetchResult) -> Void in
			self.venues = results.finalResult as! [Venue]
			self.tableView.reloadData()
		})
		
		// 3 执行请求
		do {
			try coreDataStack.context.executeRequest(asyncFetchRequest)
		}catch let error as NSError {
			print("未能成功获取\(error),\(error.userInfo)")
		}
	}
	
	// MARK：普通请求
	func noramlFetch() {
	
		// 关联editor的request
		// －－ 通过model ＋ Xcode辅助 －－ 注意错误'Can't modify a named fetch request in an immutable model.'
		//		fetchRequest = coreDataStack.model.fetchRequestTemplateForName("FetchRequest")
		
		// 创建请求
		fetchRequest = NSFetchRequest(entityName: "Venue")
		
		// 执行和加载
		fetchAndReload()
	}
	func fetchAndReload() {
		do {
			let results = try coreDataStack.context.executeFetchRequest(fetchRequest) as! [Venue]
			venues = results
		}catch let error as NSError {
			print("未能取得结果\(error),\(error.userInfo)")
		}
		
		tableView.reloadData()
	}
	
	// MARK: DataSource
  func tableView(tableView: UITableView?,
    numberOfRowsInSection section: Int) -> Int {
      return venues.count
  }
  
  func tableView(tableView: UITableView!,
    cellForRowAtIndexPath
    indexPath: NSIndexPath!) -> UITableViewCell! {
      
      let cell = tableView.dequeueReusableCellWithIdentifier("VenueCell") as UITableViewCell!
			// 装载数据
			let venue = venues[indexPath.row]
      cell.textLabel!.text = venue.name
      cell.detailTextLabel!.text = venue.priceInfo.priceCategory
      
      return cell
  }
	
	// MARK: segue
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
    if segue.identifier == "toFilterViewController" {
      
      let navController = segue.destinationViewController as! UINavigationController
      let filterVC = navController.topViewController as! FilterViewController

			// 传递stack
			filterVC.coreDataStack = coreDataStack
			// 设置代理
			filterVC.delegate = self
		}
  }
  
  @IBAction func unwindToVenuListViewController(segue: UIStoryboardSegue) {
    
  }
	
	//MARK:- FilterViewControllerDelegate methods
	func filterViewController(filter: FilterViewController, didSelectPredicate predicate: NSPredicate?, sortDescriptor: NSSortDescriptor?) {
		
		fetchRequest.predicate = nil
		fetchRequest.sortDescriptors = nil

		if let fetchPredicate = predicate {
			fetchRequest.predicate = fetchPredicate
		}
		
		if let sr = sortDescriptor {
			fetchRequest.sortDescriptors = [sr]
		}
		
		fetchAndReload()
	}
	
	
}