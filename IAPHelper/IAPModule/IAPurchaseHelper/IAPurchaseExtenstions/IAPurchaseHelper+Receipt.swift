
extension IAPurchaseHelper {
    
    /** Fetch application's Receipt.This method does two things:
     *   If the receipt is missing, refresh it
     *   If the receipt is availalbe or is refreshed, validate it
     -   Parameter online:   if true, try to fetch receipt from the app store receipt url otherwise will load local validated receipt
     -   Parameter forceRefresh: if true, it will try to refresh receipt if no receipt available
     -   Parameter completion:   completion after receipt fetch  and validation.
     */
    @objc public func uploadReceiptForValidation(inServer: Bool = true, forceRefresh: Bool = false, completion: @escaping ((_ receiptValidated: Bool) -> Void)) {
        
        guard inServer == true else {
            loadLastSession( lastSessionLoaded: completion)
            return
        }
        
        if let receiptData = loadReceiptFromBundle() {
            
            httpRequestForValidation(receipt: receiptData, serverURL: IAPurchaseConstants.urlAppStore, onCompletion: { [weak self] (session, error) in
                
                guard let strongSelf = self else {
                    completion(false)
                    return
                }
                
                if let session = session {
                    strongSelf.savedInAppSession = session
                    strongSelf.currentSubscription = session.currentSubscription
                    strongSelf.saveLastSession()
                    IAPLog.event(.receiptVerificationSuccessful)
                    completion(true)
                    
                } else {
                    //Try to load Last Saved Session
                    if let session = strongSelf.restoreLastSession() {
                        
                        strongSelf.savedInAppSession = session
                        strongSelf.currentSubscription = session.currentSubscription
                        IAPLog.event(.loadLastSessionSucceed)
                        completion(true)
                    }
                    else {
                        IAPLog.event(.receiptVerificationFailed)
                        completion(false)
                    }
                }
            })
        }
        else {
            self.loadLastSession(lastSessionLoaded: completion)
        }
    }
    
    private func loadLastSession(lastSessionLoaded: @escaping ((_ success: Bool) -> Void)) {
        
        IAPLog.event(.loadLastSessionStarted)
        
        guard hasLastSession() else {
            
            IAPLog.event(.loadLastSessionFailed)
            lastSessionLoaded(false)
            return
        }
        
        if let session = self.restoreLastSession() {
            
            self.savedInAppSession = session
            self.currentSubscription = session.currentSubscription
            IAPLog.event(.loadLastSessionSucceed)
            lastSessionLoaded(true)
        }
        else {
            IAPLog.event(.loadLastSessionFailed)
            lastSessionLoaded(false)
        }
    }
    
    private func loadReceiptFromBundle() -> Data? {
        
        guard let url = Bundle.main.appStoreReceiptURL else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            return data
        
        } catch {
            IAPLog.event(.receiptNotFoundInBundle)
            return nil
        }
    }
}

extension IAPurchaseHelper {
    
    private func httpRequestForValidation(receipt data: Data , serverURL: URL, onCompletion: @escaping (InAppSession?, Error?) -> Void) {
        
        // Validating with the App Store requires a secure connection between your app and your server to validate the receipt with the App Store.
        // Submit an HTTP POST request with the contents detailed in requestBody using the verifyReceipt endpoint to verify receipts with the App Store.
        // Use the receipt fields in the responseBody to validate app and in-app purchases.
        //
        // Verify your receipt first with the production URL;
        // Proceed to verify with the sandbox URL if you receive a 21007 status code.
        // Following this approach ensures that you do not have to switch between URLs while your application is tested, reviewed by App Review, or live in the App Store.
        //
        // N.B. As a best practice, always call the production URL for verifyReceipt first, and proceed to verify with the sandbox URL if you receive a 21007 status code.
        //
        // Ref: https://developer.apple.com/documentation/appstorereceipts/verifyreceipt
        
        let receiptBody = [
            "receipt-data": data.base64EncodedString(),
            "password": self.getSharedKey()
        ]
        
        let httpBodyData = try! JSONSerialization.data(withJSONObject: receiptBody, options: [])
        var urlRequest = URLRequest(url: serverURL)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = httpBodyData
        IAPLog.event(.uploadReceiptForValidationStart)
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (responseData, response, error) in
            
            if let res = response as? HTTPURLResponse {
                
                if (res.statusCode == 200 || res.statusCode == 201){
                    
                    if let responseData = responseData {
                        
                        let session = InAppSession(decryptedData: responseData)
                        
                        if let statusCode =  session.parsedReceipt?["status"] as? Int
                        {
                            if statusCode == 21007 {
                                
                                IAPLog.event(.uploadInSandboxForReceiptValidationStart)
                                
                                self.httpRequestForValidation(receipt: data, serverURL: IAPurchaseConstants.urlSandbox, onCompletion: onCompletion)
                                
                            } else {
                                onCompletion(session, nil)
                            }
                            
                        } else {
                            onCompletion(session, nil)
                        }
                        
                    } else {
                        onCompletion(nil, error)
                    }
                    
                } else {
                    onCompletion(nil, error)
                }
                
            } else {
                onCompletion(nil, error)
            }
        }
        
        task.resume()
    }
    
}


extension IAPurchaseHelper {
    
    private func saveLastSession(){
        
        guard let iAPsession = self.savedInAppSession else {
            return
        }
        do{
            let archivedSession = try NSKeyedArchiver.archivedData(withRootObject: iAPsession, requiringSecureCoding: false)
            IAPersistManager.setUserDefaultData(keyValue: IAPurchaseConstants.IAP_SAVED_SESSION_KEY, data: archivedSession)
            IAPersistManager.shouldSynchronize()
            IAPLog.event(.sessionArchivingSucceed)
        }catch{
            IAPLog.event(.sessionArchivingFailed)
        }
    }
    
    private func hasLastSession() -> Bool {
        
        guard IAPersistManager.getUserDefaultData(for: IAPurchaseConstants.IAP_SAVED_SESSION_KEY) != nil else{
            return false
        }
        return true
    }
    
    private func restoreLastSession() -> InAppSession? {
        
        guard let unarchived = IAPersistManager.getUserDefaultData(for: IAPurchaseConstants.IAP_SAVED_SESSION_KEY) else{
            return nil
        }
        
        do{
            let iAPsession = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(unarchived) as? InAppSession
            return iAPsession
        }catch{
            return nil
        }
    }
}
