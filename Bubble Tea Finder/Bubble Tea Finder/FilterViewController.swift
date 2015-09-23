//
//  FilterViewController.swift
//  Bubble Tea Finder
//
//  Created by Pietro Rea on 8/27/14.
//  Copyright (c) 2014 Pietro Rea. All rights reserved.
//

import UIKit
import CoreData

// defines a delegate method that will notify the delegate that the user selected a new sort/filter combination.
protocol FilterViewControllerDelegate: class {
	func filterViewController(filter: FilterViewController, didSelectPredicate predicate: NSPredicate?, sortDescriptor: NSSortDescriptor?)
}

class FilterViewController: UITableViewController {
  
  @IBOutlet weak var firstPriceCategoryLabel: UILabel!
  @IBOutlet weak var secondPriceCategoryLabel: UILabel!
  @IBOutlet weak var thirdPriceCategoryLabel: UILabel!
  @IBOutlet weak var numDealsLabel: UILabel!
  
  //Price section
  @IBOutlet weak var cheapVenueCell: UITableViewCell!
  @IBOutlet weak var moderateVenueCell: UITableViewCell!
  @IBOutlet weak var expensiveVenueCell: UITableViewCell!
  
  //Most popular section
  @IBOutlet weak var offeringDealCell: UITableViewCell!
  @IBOutlet weak var walkingDistanceCell: UITableViewCell!
  @IBOutlet weak var userTipsCell: UITableViewCell!
  
  //Sort section
  @IBOutlet weak var nameAZSortCell: UITableViewCell!
  @IBOutlet weak var nameZASortCell: UITableViewCell!
  @IBOutlet weak var distanceSortCell: UITableViewCell!
  @IBOutlet weak var priceSortCell: UITableViewCell!

	// coreDataStack
	var coreDataStack: CoreDataStack!
	
	// delegate
	weak var delegate: FilterViewControllerDelegate?
	var selectedSortDescriptor: NSSortDescriptor?
	var selectedPredicate: NSPredicate?

	override func viewDidLoad() {
		super.viewDidLoad()
		
		// 'PEICE'
		populateCheapVenueCountLable()
		populateModerateVenueCountLable()
		populateExpensiveVenueCountLable()
		
		// 'offering a deal'
		populateDealsCountLabel()
	}
	
	
	func populateDealsCountLabel() {
		// 1 使用DictionaryResultType方式--即是以NSDictionary的格式组织返回的数据
		let fetchRequest = NSFetchRequest(entityName: "Venue")
		fetchRequest.resultType = NSFetchRequestResultType.DictionaryResultType
		
		// 2 创建NSExpressionDescription，并命名
		let sumExpressionDesc = NSExpressionDescription()
		sumExpressionDesc.name = "sumDeals"
		
		// 3 截取specialCount字段，并做sum计算
		sumExpressionDesc.expression = NSExpression(forFunction: "sum:", arguments: [NSExpression(forKeyPath: "specialCount")])
		sumExpressionDesc.expressionResultType = NSAttributeType.Integer32AttributeType
		
		// 4 配置请求:propertiesToFetch属性赋值
		fetchRequest.propertiesToFetch = [sumExpressionDesc]
		
		// 5 执行请求 ＋ 更新UI
		do {
			let results = try coreDataStack.context.executeFetchRequest(fetchRequest) as! [NSDictionary]
			// 实际上会返回一个包含一个字典的数组 ［{sumDeals ＝ 12;}］
			let resultDict = results[0]
			print(results)
			let numDeals: AnyObject? = resultDict["sumDeals"]
			numDealsLabel.text = "\(numDeals!) total deals"
		}catch let error as NSError{
			print("未能成功获取折扣数量\(error),\(error.userInfo)")
		}
	}
	
	
	// 使用CountResultType方式，返回一个只包含总数目的数组
	// 当然你也可以返回所有的[Venue],在得出数量，但当数据巨大时，
	// CountResultType方式就是一种高效的选择（is more memory- efficient）
	func populateCheapVenueCountLable() {
		
		let fetchRequest = NSFetchRequest(entityName: "Venue")
		fetchRequest.resultType = NSFetchRequestResultType.CountResultType
		fetchRequest.predicate = cheapVenuePredicate
		
		// 执行请求
		do {
			let results = try coreDataStack.context.executeFetchRequest(fetchRequest) as! [NSNumber]
			// 从数组中取出
			let count = results[0].integerValue
			firstPriceCategoryLabel.text = "\(count) bubbke tea places"
		}catch let error as NSError {
			print("未能成功获取\(error) ,\(error.userInfo)")
		}
	}
	func populateModerateVenueCountLable() {
		let fetchRequest = NSFetchRequest(entityName: "Venue")
		fetchRequest.resultType = NSFetchRequestResultType.CountResultType
		fetchRequest.predicate = moderateVenuePredicate
		// 执行请求
		do {
			let results = try coreDataStack.context.executeFetchRequest(fetchRequest) as! [NSNumber]
			// 从数组中取出
			let count = results[0].integerValue
			secondPriceCategoryLabel.text = "\(count) bubbke tea places"
		}catch let error as NSError {
			print("未能成功获取\(error) ,\(error.userInfo)")
		}
	}
	func populateExpensiveVenueCountLable() {
		
		let fetchRequest = NSFetchRequest(entityName: "Venue")
		fetchRequest.resultType = NSFetchRequestResultType.CountResultType
		fetchRequest.predicate = expensiveVenuePredicate
		
		// 执行请求
		do {
			let results = try coreDataStack.context.executeFetchRequest(fetchRequest) as! [NSNumber]
			// 从数组中取出
			let count = results[0].integerValue
			thirdPriceCategoryLabel.text = "\(count) bubbke tea places"
		}catch let error as NSError {
			print("未能成功获取\(error) ,\(error.userInfo)")
		}
	}
	
  //MARK: - UITableViewDelegate methods
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let cell = tableView.cellForRowAtIndexPath(indexPath)!
		// 不同的cell，对应不用的predicate
		switch cell {
		case cheapVenueCell:
				selectedPredicate = cheapVenuePredicate
		case moderateVenueCell:
			selectedPredicate = moderateVenuePredicate
		case expensiveVenueCell:
			selectedPredicate = expensiveVenuePredicate
		case offeringDealCell:
			selectedPredicate = offeringDealPredicate
		case walkingDistanceCell:
			selectedPredicate = walkingDistancePredicate
		case userTipsCell:
			selectedPredicate = hasUserTipsPredicate
		default:
			print("default case")
		}
		cell.accessoryType = UITableViewCellAccessoryType.Checkmark
  }
  
  //MARK: - UIButton target action
  @IBAction func saveButtonTapped(sender: UIBarButtonItem) {
		
		delegate?.filterViewController(self, didSelectPredicate: selectedPredicate, sortDescriptor: selectedSortDescriptor)
		
    dismissViewControllerAnimated(true, completion:nil)
  }
	
	//MARK: - lazy predicate
	lazy var cheapVenuePredicate: NSPredicate = {
		var predicate = NSPredicate(format: "priceInfo.priceCategory == %@", "$")
		return predicate
		}()
	lazy var moderateVenuePredicate: NSPredicate = {
		var predicate = NSPredicate(format: "priceInfo.priceCategory == %@", "$$")
		return predicate
		}()
	lazy var expensiveVenuePredicate: NSPredicate = {
		var predicate = NSPredicate(format: "priceInfo.priceCategory == %@", "$$$")
		return predicate
		}()
	lazy var offeringDealPredicate: NSPredicate = {
		var pr = NSPredicate(format: "specialCount > 0")
		return pr
	}()
	lazy var walkingDistancePredicate: NSPredicate = {
		var pr = NSPredicate(format: "location.distance < 500")
		return pr
		}()
	lazy var hasUserTipsPredicate: NSPredicate = {
		var pr = NSPredicate(format: "stats.tipCount > 0")
		return pr
		}()

 }
