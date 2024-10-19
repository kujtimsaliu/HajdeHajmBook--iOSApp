//
//  FirestoreManager.swift
//  HajdeHajm
//
//  Created by Kujtim Saliu on 17.10.24.
//

import Firebase
import FirebaseFirestore
import FirebaseAuth

class FirestoreManager {
    static let shared = FirestoreManager()
    private let db = Firestore.firestore()
    
    private init() {}
    
    func getCurrentUser(completion: @escaping (Result<User, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "FirestoreManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])))
            return
        }
        
        db.collection("users").document(userId).getDocument { (document, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = document, document.exists,
                  let user = try? document.data(as: User.self) else {
                completion(.failure(NSError(domain: "FirestoreManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not found"])))
                return
            }
            
            completion(.success(user))
        }
    }
    
    func fetchMenuItems(completion: @escaping (Result<[MenuItem], Error>) -> Void) {
        db.collection("menu_items").getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                completion(.failure(NSError(domain: "FirestoreManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "No menu items found"])))
                return
            }
            
            let menuItems = documents.compactMap { try? $0.data(as: MenuItem.self) }
            completion(.success(menuItems))
        }
    }
    
    func saveOrder(_ order: Order, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let _ = try db.collection("orders").addDocument(from: order)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetchUserOrders(for userId: String, completion: @escaping (Result<[Order], Error>) -> Void) {
        db.collection("orders")
            .whereField("userId", isEqualTo: userId)
            .order(by: "date", descending: true)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let orders = querySnapshot?.documents.compactMap { try? $0.data(as: Order.self) } ?? []
                completion(.success(orders))
            }
    }
    
    func fetchAllOrdersForDate(_ date: Date, completion: @escaping (Result<[Order], Error>) -> Void) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        db.collection("orders")
            .whereField("date", isGreaterThanOrEqualTo: startOfDay)
            .whereField("date", isLessThan: endOfDay)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let orders = querySnapshot?.documents.compactMap { try? $0.data(as: Order.self) } ?? []
                completion(.success(orders))
            }
    }
    
    func fetchWeeklyOrders(for weekStart: Date, completion: @escaping (Result<[Order], Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "FirestoreManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])))
            return
        }
        
        let weekEnd = Calendar.current.date(byAdding: .day, value: 7, to: weekStart)!
        
        db.collection("orders")
            .whereField("userId", isEqualTo: userId)
            .whereField("date", isGreaterThanOrEqualTo: weekStart)
            .whereField("date", isLessThan: weekEnd)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let orders = querySnapshot?.documents.compactMap { document -> Order? in
                    try? document.data(as: Order.self)
                } ?? []
                
                completion(.success(orders))
            }
    }
    
    func markWeekAsPaid(orders: [Order], completion: @escaping (Result<Void, Error>) -> Void) {
        let batch = db.batch()
        
        for order in orders {
            let orderRef = db.collection("orders").document(order.id)
            batch.updateData(["isPaid": true], forDocument: orderRef)
        }
        
        batch.commit { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func markOrderAsPaid(order: Order, completion: @escaping (Result<Void, Error>) -> Void) {
          let orderRef = db.collection("orders").document(order.id)
          orderRef.updateData(["isPaid": true]) { error in
              if let error = error {
                  completion(.failure(error))
              } else {
                  completion(.success(()))
              }
          }
      }
    
    
    func fetchWeeklyOrders(for weekStart: Date, userId: String, completion: @escaping (Result<[Order], Error>) -> Void) {
           let weekEnd = Calendar.current.date(byAdding: .day, value: 7, to: weekStart)!
           
           db.collection("orders")
               .whereField("userId", isEqualTo: userId)
               .whereField("date", isGreaterThanOrEqualTo: weekStart)
               .whereField("date", isLessThan: weekEnd)
               .getDocuments { (querySnapshot, error) in
                   if let error = error {
                       completion(.failure(error))
                       return
                   }
                   
                   let orders = querySnapshot?.documents.compactMap { document -> Order? in
                       try? document.data(as: Order.self)
                   } ?? []
                   
                   completion(.success(orders))
               }
       }
       
       func markOrdersAsPaid(orders: [Order], completion: @escaping (Result<Void, Error>) -> Void) {
           let batch = db.batch()
           
           for order in orders {
               let orderRef = db.collection("orders").document(order.id)
               batch.updateData(["isPaid": true], forDocument: orderRef)
           }
           
           batch.commit { error in
               if let error = error {
                   completion(.failure(error))
               } else {
                   completion(.success(()))
               }
           }
       }
       
       func toggleOrderPaymentStatus(order: Order, completion: @escaping (Result<Void, Error>) -> Void) {
           let orderRef = db.collection("orders").document(order.id)
           orderRef.updateData(["isPaid": !order.isPaid]) { error in
               if let error = error {
                   completion(.failure(error))
               } else {
                   completion(.success(()))
               }
           }
       }
}
