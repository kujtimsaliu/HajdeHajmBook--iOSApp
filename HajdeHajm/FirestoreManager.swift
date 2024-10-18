//
//  FirestoreManager.swift
//  HajdeHajm
//
//  Created by Kujtim Saliu on 17.10.24.
//

import FirebaseFirestore

class FirestoreManager {
    static let shared = FirestoreManager()
    private let db = Firestore.firestore()
    
    private init() {}
    
    func fetchMenuItems(completion: @escaping (Result<[MenuItem], Error>) -> Void) {
        db.collection("menu_items").getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                completion(.failure(NSError(domain: "FirestoreManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "No documents found"])))
                return
            }
            
            let menuItems = documents.compactMap { document -> MenuItem? in
                let data = document.data()
                guard let name = data["name"] as? String,
                      let description = data["description"] as? String,
                      let price = data["price"] as? Int else {
                    return nil
                }
                
                return MenuItem(id: document.documentID,
                                name: name,
                                description: description,
                                price: price,
                                category: data["category"] as? String)
            }
            
            completion(.success(menuItems))
        }
    }
    
    func saveOrder(_ order: Order, completion: @escaping (Result<Void, Error>) -> Void) {
        let orderData: [String: Any] = [
            "userId": order.userId,
            "items": order.items.map { ["id": $0.key.id, "quantity": $0.value] },
            "date": order.date,
            "total": order.total
        ]
        
        db.collection("orders").addDocument(data: orderData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
