//
//  ViewController.swift
//  RealmPhotoReader
//
//  Created by 陳劭任 on 2018/9/27.
//  Copyright © 2018 陳劭任. All rights reserved.
//

import Cocoa
import RealmSwift

class ViewController: NSViewController {

    @IBOutlet weak var realmFilePathLabel: NSTextField!
    
    @IBOutlet weak var photoSavedPathLabel: NSTextField!
    
    @IBOutlet weak var progressLabel: NSTextField!
    
    //    @IBOutlet weak var photoView: NSImageView!
    
    var fileURL: URL?
    
    var savedFileURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func chooseFile(_ sender: NSButton) {
        
        guard let window = view.window else { return }
        
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedFileTypes = ["realm"]
        
        panel.beginSheetModal(for: window) { (result) in
            
            if result == NSApplication.ModalResponse.OK {
                
                self.realmFilePathLabel.stringValue = (panel.url?.absoluteString)!
                
                self.fileURL = panel.url
            }
        }
        
    }
    
    @IBAction func chooseFilePath(_ sender: NSButton) {
        
        guard let window = view.window else { return }
        
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false

        panel.canCreateDirectories = true
        
        panel.beginSheetModal(for: window) { (result) in
            
            if result == NSApplication.ModalResponse.OK {
                
                self.photoSavedPathLabel.stringValue = panel.urls[0].absoluteString
                
                self.savedFileURL = panel.url
                
            }
        }
    }
    
    
    @IBAction func startReadingFile(_ sender: NSButton) {
        
        guard let fileURL = self.fileURL else { return }
        
        guard let savedFileURL = self.savedFileURL else { return }
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        
        hud?.mode = MBProgressHUDModeIndeterminate
        
        DispatchQueue.global().async {
            
            self.exportImageFromRealm(
                fileURL: fileURL,
                savedFileURL: savedFileURL,
                updateProgress: { (index, total) in
                    
                    DispatchQueue.main.async {
                        
                        self.progressLabel.stringValue = "\(index+1) / \(total)"
                        
                    }
            },
                completion: { [weak self] in
                    
                    DispatchQueue.main.async {
                        
                        MBProgressHUD.hideAllHUDs(for: self?.view, animated: true)
                        
                    }
            })
            
        }
        
    }
    
    func exportImageFromRealm(fileURL: URL, savedFileURL: URL, updateProgress: (_ index: Int, _ total: Int) -> Void ,completion: () -> Void) {
        
        let config = Realm.Configuration(
            fileURL: fileURL,
            schemaVersion: 99999,
            migrationBlock: { (migration, oldSchemaVersion) in
                
                migration.enumerateObjects(ofType: User.className(), { (oldObject, newObject) in
                    let uuid = oldObject!["UUID"] as! String
                    let pictures = oldObject!["pictures"] as! String
                    let info = migration.create("UserInfo", value: oldObject!["info"]!)
                    let itvid = oldObject!["ITVID"] as! Int
                    
                    newObject!["uuid"] = uuid
                    newObject!["pictures"] = pictures
                    newObject!["info"] = info
                    newObject!["itvid"] = itvid
                    
                })
                
        },
            objectTypes: [User.self,UserInfo.self])
        
        let realm = try! Realm(configuration: config)
        
        let users = realm.objects(User.self)
        
        for (index, user) in users.enumerated() {
            
            let base64ImageString = user.pictures
            
            guard let imageData = Data(base64Encoded: base64ImageString, options: .ignoreUnknownCharacters) else { continue }
            
            guard let image = NSImage(dataIgnoringOrientation: imageData) else { continue }
            
            //            self.photoView.image = image
            
            updateProgress(index,users.count)
            
            image.saveAsJpegWithName(fileName: String(user.info!.name), url: savedFileURL)
        }
        
        completion()
    }
    
}

extension NSImage {

    func saveAsJpegWithName(fileName: String, url: URL) {
        
        guard let data = self.tiffRepresentation else { return }
        
        guard let imageRep = NSBitmapImageRep(data: data) else { return }
        
        let imageProps = [NSBitmapImageRep.PropertyKey.compressionFactor: 1.0]
        
        guard let imageData = imageRep.representation(using: .jpeg, properties: imageProps) else { return }
        
        let fileUrl = url.appendingPathComponent(fileName + ".jpg")
        
        try? imageData.write(to: fileUrl)
    }
}
