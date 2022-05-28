//
//  IAPManager.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/28/21.
//

//
//  In-AppPurchase.swift
//  AudiConverter
//
//  Created by vinova on 4/23/21.
//

import Foundation
import SwiftyStoreKit
import StoreKit
import PKHUD



public typealias ProductIdentifier = String
public typealias ProductsRequestCompletionHandler = (_ products: [SKProduct]) -> Void
public typealias PurchaseSuccess = () -> Void

struct IAPManager  {
    
    
    static let store = IAPManager()
    
    
    static let oneMonth = "com.ringtonestune.one.month"
    static let oneYear = "com.ringtonestune.one.year"
    static let onWeek = "com.ringtonestune.one.week"
    private static let sharedSecret = "4a7fd7ae3c0540bc8aa0258fc33c8890"
    
    private static let productIdentifiers: Set<ProductIdentifier> = [onWeek,oneMonth, oneYear]
    
    
    //
    
    func requestPackInfo(completion: @escaping ProductsRequestCompletionHandler){
        
        HUD.show(.progress)
        SwiftyStoreKit.retrieveProductsInfo(IAPManager.productIdentifiers) { result in
            let products = result.retrievedProducts
            var productsList:[SKProduct] = []
            products.forEach { product in
                productsList.append(product)
            }
            HUD.hide()
            completion(productsList)
        }
    }
    
    func purchasePack(packNameId:String, completion: @escaping PurchaseSuccess ){
        HUD.show(.progress)
        SwiftyStoreKit.purchaseProduct(packNameId, quantity: 1, atomically: true) { result in
            switch result {
            case .success( _):
                HUD.show(.labeledSuccess(title: "Success", subtitle: "Purchase Success"))
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    HUD.hide()
                    UserDefaults.setPremiumUser(inPre: true)
                    completion()
                }
                
            case .error(let error):
                switch error.code {
                case .unknown:   HUD.show(.labeledError(title: nil, subtitle: "Unknown error. Please contact support"))
                case .clientInvalid: HUD.show(.labeledError(title: nil, subtitle: "Not allowed to make the payment"))
                case .paymentCancelled: HUD.show(.labeledError(title: nil, subtitle: "Payment Cancel"))
                case .paymentInvalid: HUD.show(.labeledError(title: nil, subtitle: "The purchase identifier was invalid"))
                case .paymentNotAllowed:
                    HUD.show(.labeledError(title: nil, subtitle: "The device is not allowed to make the payment"))
                    
                case .storeProductNotAvailable:
                    HUD.show(.labeledError(title: nil, subtitle: "The product is not available in the current storefront"))
                case .cloudServicePermissionDenied:
                    HUD.show(.labeledError(title: nil, subtitle: "Access to cloud service information is not allowed"))
                case .cloudServiceNetworkConnectionFailed:
                    HUD.show(.labeledError(title: nil, subtitle: "Could not connect to the network"))
                case .cloudServiceRevoked:
                    HUD.show(.labeledError(title: nil, subtitle: "User has revoked permission to use this cloud service"))
                   
                default:
                    HUD.show(.labeledError(title: nil, subtitle: "Unknown error. Please contact support"))
                }
                
                
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    HUD.hide()
                }
            }
        }
    }
    
    func restorePurchase(completion: @escaping PurchaseSuccess){
        HUD.show(.progress)
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            if results.restoreFailedPurchases.count > 0 {
                
                
                HUD.show(.labeledError(title: nil, subtitle: "Restore Fail"))
                
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    HUD.hide()
                    UserDefaults.setPremiumUser(inPre: false)
                }
                
            }
            else if results.restoredPurchases.count > 0 {
                HUD.show(.labeledSuccess(title: "Success", subtitle: "Restore Success"))
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    HUD.hide()
                    UserDefaults.setPremiumUser(inPre: true)
                    completion()
                }
               
            }
            else {
                
                HUD.show(.labeledError(title: nil, subtitle: "Nothing to Restore"))
                
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    HUD.hide()
                    UserDefaults.setPremiumUser(inPre: false)
                }
                
                
                
            }
        }
    }
    
    
    func veryPurchase(packNameId: String, completion: @escaping PurchaseSuccess) ->Bool{
        let appleValidator = AppleReceiptValidator(service: .sandbox, sharedSecret: IAPManager.sharedSecret)
        var isPurchase = false
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):
                
               
                
                // Verify the purchase of Consumable or NonConsumable
                let purchaseResult = SwiftyStoreKit.verifyPurchase(
                    productId: packNameId,
                    inReceipt: receipt)
                    
                switch purchaseResult {
                case .purchased(_):
                    isPurchase = true
                    
                    UserDefaults.setPremiumUser(inPre: true)
                    
                case .notPurchased:
                    
                   isPurchase = false
                    UserDefaults.setPremiumUser(inPre: false)
                }
                
                
            case .error(_):
               
                isPurchase = false
                UserDefaults.setPremiumUser(inPre: false)
            }
            
        }
        return isPurchase
    }
    
    func veryCheckRegisterPack(){
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: IAPManager.sharedSecret)
        
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):

                
                let purchaseResult = SwiftyStoreKit.verifySubscriptions(ofType: .autoRenewable, productIds: [IAPManager.oneYear, IAPManager.onWeek, IAPManager.oneYear], inReceipt: receipt)
                
                    
                switch purchaseResult {
                case .purchased( _, _):
                    UserDefaults.setPremiumUser(inPre: true)
                    
                    
                case .expired(_,_):
                    
                    UserDefaults.setPremiumUser(inPre: false)
                case .notPurchased:
                    
                    UserDefaults.setPremiumUser(inPre: false)
                }
            case .error(_):
                UserDefaults.setPremiumUser(inPre: false)
            }
            
        }
    }
    
    
    
  
}

