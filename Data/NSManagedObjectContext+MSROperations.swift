import CoreData
import Foundation

extension NSManagedObjectContext {
    @objc func msr_deleteAllObjectsWithEntityName(entityName: String, error: NSErrorPointer) {
        let request = NSFetchRequest(entityName: entityName)
        request.predicate = NSPredicate(value: true)
        let results = executeFetchRequest(request, error: error)
        if results != nil {
            for r in results! {
                deleteObject(r as! NSManagedObject)
            }
        } else {
            if error != nil {
                error.memory = NSError() // Needs specification
            }
        }
    }
    @objc func msr_deleteAllObjectsWithEntityName(entityName: String) -> NSError? {
        var error: NSError?
        msr_deleteAllObjectsWithEntityName(entityName, error: &error)
        return error
    }
}
