# BubbleTea-_swift2.0

swift2.0 + Xcode7

CoreData中的Request

－ 普通的NSFetchRequest

－ 异步的NSAsynchronousFetchRequest

－ 批量的NSBatchUpdateRequest

resulteType

• NSManagedObjectResultType:  Returns managed objects (default value).

• NSCountResultType: Returns the count of the objects that match the fetch request.

• NSDictionaryResultType: This is a catch-all return type for returning the results of different calculations.

• NSManagedObjectIDResultType: Returns unique identifiers instead of full- fledged managed objects.

context－ConcurrencyType

		NSManagedObjectContextConcurrencyType.ConfinementConcurrencyType  // 默认
		NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType // 多线程
		NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType		// 主线程并发
