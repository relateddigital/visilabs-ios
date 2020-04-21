//
//  VisilabsPersistentTargetManager.swift
//  VisilabsIOS
//
//  Created by Egemen on 15.04.2020.
//

import Foundation

class VisilabsPersistentTargetManager {
    
    class func saveParameters(_ parameters: [String : String]) {
        let lockQueue = DispatchQueue(label: "self")
        lockQueue.sync {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
            let dateString = dateFormatter.string(from: Date())
            
            for visilabsParameter in VisilabsConfig.visilabsParameters() {
                let key = visilabsParameter.key
                let storeKey = visilabsParameter.storeKey
                let relatedKeys = visilabsParameter.relatedKeys
                let count = visilabsParameter.count

                let parameterValue = parameters[key]
                
                if parameterValue != nil && parameterValue!.count > 0 {
                    if count == 1 {
                        if relatedKeys != nil && relatedKeys!.count > 0 {
                            var parameterValueToStore = parameterValue!.copy() as! String
                            let relatedKey = relatedKeys![0] as? String
                            if parameters[relatedKey ?? ""] != nil {
                                let relatedKeyValue = (parameters[relatedKey ?? ""])?.trimmingCharacters(in: CharacterSet.whitespaces)
                                parameterValueToStore = parameterValueToStore + ("|")
                                parameterValueToStore = parameterValueToStore + (relatedKeyValue ?? "")
                            } else {
                                parameterValueToStore = parameterValueToStore + ("|0")
                            }
                            parameterValueToStore = parameterValueToStore + (dateString)
                            VisilabsDataManager.save(storeKey, withObject: parameterValueToStore)
                        } else {
                            VisilabsDataManager.save(storeKey, withObject: parameterValue)
                        }
                    }
                    else if count > 1 {
                        let previousParameterValue = VisilabsDataManager.read(storeKey) as? String
                        var parameterValueToStore = parameterValue!.copy() as! String + ("|")
                        parameterValueToStore = parameterValueToStore + (dateString)
                        if previousParameterValue != nil && previousParameterValue!.count > 0 {
                            let previousParameterValueParts = previousParameterValue!.components(separatedBy: "~")
                            for i in 0..<previousParameterValueParts.count {
                                if i == 9 {
                                    break
                                }
                                let decodedPreviousParameterValuePart = previousParameterValueParts[i] as String
                                //TODO:burayı kontrol et java'da "\\|" yapmak gerekiyordu.
                                let decodedPreviousParameterValuePartArray = decodedPreviousParameterValuePart.components(separatedBy: "|")
                                if decodedPreviousParameterValuePartArray.count == 2 {
                                    parameterValueToStore = parameterValueToStore + ("~")
                                    parameterValueToStore = parameterValueToStore + (decodedPreviousParameterValuePart )
                                }
                            }
                        }
                        VisilabsDataManager.save(storeKey, withObject: parameterValueToStore)
                    }
                    
                }
            }
            
        }
    }
    
    class func getParameters() -> [AnyHashable : Any]? {
        var parameters: [AnyHashable : Any] = [:]
        for visilabsParameter in VisilabsConfig.visilabsParameters() {
            let storeKey = visilabsParameter.storeKey
            let value = VisilabsDataManager.read(storeKey) as? String
            if value != nil && (value?.count ?? 0) > 0 {
                parameters[storeKey] = value
            }
        }
        return parameters
    }

    class func clearParameters() {
        for visilabsParameter in VisilabsConfig.visilabsParameters() {
            VisilabsDataManager.remove(visilabsParameter.storeKey)
        }
    }
}
