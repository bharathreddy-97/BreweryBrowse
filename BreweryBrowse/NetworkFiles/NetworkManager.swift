//
//  NetworkManager.swift
//  BreweryBrowse
//
//  Created by Next on 01/01/18.
//  Copyright © 2018 Next. All rights reserved.
//

import Foundation
import Alamofire
import CoreData

class NetworkManager{
    
    static let sharedInstance = NetworkManager()
    
    private init(){}
    
    func getData(fromURL url:String,_ method:HTTPMethod,_ encoding: URLEncoding, completion:@escaping (Data?,Error?)->Void ){
        //print("Fetching data from URL ",url)
        Alamofire.request(url).responseJSON { (dataResponse) in
            guard let response = dataResponse.response, let data = dataResponse.data else
            {
                completion(nil,self.getNullDataResponseError())
                return
            }
            guard 200..<300 ~= response.statusCode else
            {
                completion(nil,self.getStatusCodeError(withResponse: response))
                return
            }
            guard let json = try? JSONSerialization.jsonObject(with: data) else
            {
                completion(nil,self.getInvalidJsonError())
                return
            }
            print(json)
            completion(data,nil)
        }
    }
    
}

extension NetworkManager{
    private func getStatusCodeError(withResponse response:HTTPURLResponse)-> Error{
        let error = NSError(domain: Constants.NetworkConstants.incorrectStatusDomain, code: response.statusCode, userInfo: nil)
        return error as Error
    }
    
    private func getNullDataResponseError()->Error{
        let error = NSError(domain: Constants.NetworkConstants.nullDataOrResponseDomain, code: 500, userInfo: nil)
        return error as Error
    }
    
    private func getInvalidJsonError()->Error{
        let error = NSError(domain: Constants.NetworkConstants.invalidJsonErrorDomain, code: 500, userInfo: nil)
        return error as Error
    }
    
    private func getJsonParseError()->Error{
        let error = NSError(domain: Constants.NetworkConstants.jsonToModelParseErrorDomain, code: 400, userInfo: nil)
        return error as Error
    }
}

extension CodingUserInfoKey {
    static let context = CodingUserInfoKey(rawValue: "context")
}

