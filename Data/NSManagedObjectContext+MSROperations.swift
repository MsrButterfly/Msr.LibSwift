import CoreData
import Foundation

extension NSManagedObjectContext {
    @objc func msr_deleteAllObjectsWithEntityName(entityName: String) throws {
        let request = NSFetchRequest(entityName: entityName)
        request.predicate = NSPredicate(value: true)
        let results = try executeFetchRequest(request)
        for result in results {
            deleteObject(result as! NSManagedObject)
        }
    }
}
