//
//  Database.swift
//  Database_Demo
//
//  Created by Aditya Bhandari on 3/9/16.
//  Copyright © 2016 Aditya Bhandari. All rights reserved.
//

import UIKit

class Database: NSObject {
    
    let strDBName = "MainDB.sqlite"

    var db:COpaquePointer = nil
    
    class sharedDatabaseInstance {
        class var sharedInstance: Database {
            struct Static {
                static let instance = Database()
            }
            return Static.instance
        }
    }
    
    func getDatabaseFilePath()-> String!{
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        
        let docDirPath = paths[0] as NSString
        
        return docDirPath.stringByAppendingPathComponent("\(strDBName)") as String
    }
    
    func createDatabaseIfNotExist()->Bool {
        
        let manager = NSFileManager.defaultManager()
        
        let success = manager.fileExistsAtPath(getDatabaseFilePath())
    
        let arrDBName = strDBName.componentsSeparatedByString(".")
        
        let dbFileBundlePath = NSBundle.mainBundle().pathForResource(arrDBName[0] as String, ofType: arrDBName[1] as String)
    
        if(success){
            return true
        }else{
            
            let dbToPath = getDatabaseFilePath() as String
            
            do {
                
                //try NSFileManager.defaultManager().copyItemAtPath(dbFileBundlePath! , toPath: dbToPath)
                
                try NSFileManager.defaultManager().createFileAtPath(dbToPath, contents: nil, attributes: nil)
                
                let strCreateQuery1 = "create table UserInfo (first_name varchar2(30),last_name varchar2(30),phone_number varchar2(10), password varchar2(30))" as String
                
                
                self.createQuery(strCreateQuery1)
                
                let strCreateQuery2 = "create table contacts (user_contact_no varchar2(10),emergency_contact_no varchar2(10),emergency_contact_name varchar2(30),contact_type varchar2(30),is_accepted varchar2(1))"
                
                self.createQuery(strCreateQuery2)
                
                
            } catch let error as NSError {
                print("Error while Coping database \(error.description)")
                return false
            }
        }
        return true
    }
    
    func createQuery (strQuery:String) -> Bool{
        
        var result = sqlite3_open(getDatabaseFilePath(), &db)
        
        if (result != SQLITE_OK){
            sqlite3_close(db)
            print("Failed To Open Database")
            return false
        }
        
        var errMsg:UnsafeMutablePointer<Int8> = nil

        result = sqlite3_exec(db, strQuery, nil, nil, &errMsg)
        
        if (result != SQLITE_OK){
            sqlite3_close(db)
            print("Failed To Open Database")
            return false
        }
        return true
    }
    

    func insertQuery(strQuery:String)->Bool{
        var result = sqlite3_open(getDatabaseFilePath(), &db)
        
        if (result != SQLITE_OK){
            sqlite3_close(db)
            print("Failed To Open Database")
            return false
        }
        
        var statement:COpaquePointer = nil
        
        result = sqlite3_prepare_v2(db, strQuery, -1, &statement, nil)
        
        if (result != SQLITE_OK){
            sqlite3_close(db)
            print("Databse returned error \(sqlite3_errcode(db)) : \(sqlite3_errmsg(db))")
            return false
        }
        sqlite3_step(statement)
        sqlite3_finalize(statement)
        
        result = sqlite3_close(db)
        if (result != SQLITE_OK){
            print("Failed To Close Database")
            return false
        }
        return true
    }
    
    func deleteQuery(strQuery:String)->Bool{
        var result = sqlite3_open(getDatabaseFilePath(), &db)
        
        if (result != SQLITE_OK){
            sqlite3_close(db)
            print("Failed To Open Database")
            return false
        }
        
        var statement:COpaquePointer = nil
        
        result = sqlite3_prepare_v2(db, strQuery, -1, &statement, nil)
        
        if (result != SQLITE_OK){
            sqlite3_close(db)
            print("Databse returned error \(sqlite3_errcode(db)) : \(sqlite3_errmsg(db))")
            return false
        }
        sqlite3_step(statement)
        sqlite3_finalize(statement)
        
        result = sqlite3_close(db)
        if (result != SQLITE_OK){
            print("Failed To Close Database")
            return false
        }
        return true
    }
    
    func updateQuery(strQuery:String)->Bool{
        var result = sqlite3_open(getDatabaseFilePath(), &db)
        
        if (result != SQLITE_OK){
            sqlite3_close(db)
            print("Failed To Open Database")
            return false
        }
        
        var statement:COpaquePointer = nil
        
        result = sqlite3_prepare_v2(db, strQuery, -1, &statement, nil)
        
        if (result != SQLITE_OK){
            sqlite3_close(db)
            print("Databse returned error \(sqlite3_errcode(db)) : \(sqlite3_errmsg(db))")
            return false
        }
        sqlite3_step(statement)
        sqlite3_finalize(statement)
        
        result = sqlite3_close(db)
        if (result != SQLITE_OK){
            print("Failed To Close Database")
            return false
        }
        return true
    }
    
    func selectQuery(strQuery:String) -> [Dictionary<String, String>]  {
        var result = sqlite3_open(getDatabaseFilePath(), &db)
        
        if (result != SQLITE_OK){
            sqlite3_close(db)
            print("Failed To Open Database")
        }
        
        var statement:COpaquePointer = nil
        
        result = sqlite3_prepare_v2(db, strQuery, -1, &statement, nil)
        
        var arrResult = [Dictionary<String, String>] ()
        
        if(result == SQLITE_OK){
            
            while sqlite3_step(statement) == SQLITE_ROW{
                
                var dictCurrentRow = Dictionary<String, String> ()
                
                let ColumnCount = Int(sqlite3_column_count(statement))
                
                for i in 0..<ColumnCount{
                    let name = sqlite3_column_name(statement, Int32(i))
                    let rowData = sqlite3_column_text(statement, Int32(i))
                    
                    let strColumnName = String.fromCString(UnsafePointer<CChar>(name))
                    var strColumnData:String? = nil
                    
                    if(rowData != nil){
                        strColumnData = String.fromCString(UnsafePointer<CChar>(rowData))
                    }
                    dictCurrentRow[strColumnName!] = strColumnData
                }
                
                arrResult.append(dictCurrentRow)
            }
        }
        return arrResult
    }
}
