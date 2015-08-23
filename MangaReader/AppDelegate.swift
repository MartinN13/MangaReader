//
//  AppDelegate.swift
//  Testing App
//
//  Created by Martin on 7/15/14.
//  Copyright (c) 2014 Martin. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
                            
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var viewImage : NSImageView!
    @IBOutlet weak var toolbar: NSToolbar!
    @IBOutlet weak var turnPage: NSSegmentedControl!
    @IBOutlet weak var pageScaling: NSSegmentedCell!
    
    //Variables that need to be global
    var openFileDialog = NSOpenPanel()
    var chosenFile = NSURL()
    var chosenFiles = NSArray()
    var img = NSImage()
    var rotateCount = 0
    var fileCount = 0
    var screenResolution = NSScreen.mainScreen()
    
    override init() {
        openFileDialog.canChooseDirectories = true
        openFileDialog.canChooseFiles = true
        openFileDialog.allowsMultipleSelection = true
    }
    
    //Buttons
    @IBAction func openManga(sender: AnyObject) {
        openFileDialog.runModal()
        chosenFiles = openFileDialog.URLs
        chosenFile = chosenFiles[fileCount] as! NSURL
        img = NSImage(byReferencingURL: chosenFile)
        viewImage.image = img
        resizeWindow()
    }
    @IBAction func rotate(sender: AnyObject) {
        viewImage.rotateByAngle(-90)
        img = NSImage(byReferencingURL: chosenFile)
        viewImage.image = img
        rotateCount++
        resizeWindow()
    }
    @IBAction func menuNext(sender: AnyObject) {
        if fileCount == chosenFiles.count - 1 {
            fileCount = 0
            chosenFile = chosenFiles[fileCount] as! NSURL
            img = NSImage(byReferencingURL: chosenFile)
            viewImage.image = img
            resizeWindow()
        }
        else {
            fileCount++
            chosenFile = chosenFiles[fileCount] as! NSURL
            img = NSImage(byReferencingURL: chosenFile)
            viewImage.image = img
            resizeWindow()
        }
    }
    @IBAction func menuPrevious(sender: AnyObject) {
        if fileCount == 0 {
            fileCount = chosenFiles.count - 1
            chosenFile = chosenFiles[fileCount] as! NSURL
            img = NSImage(byReferencingURL: chosenFile)
            viewImage.image = img
            resizeWindow()
        }
        else {
            fileCount--
            chosenFile = chosenFiles[fileCount] as! NSURL
            img = NSImage(byReferencingURL: chosenFile)
            viewImage.image = img
            resizeWindow()
        }
    }
    @IBAction func turnPage(sender: AnyObject) {
        if turnPage.selectedSegment == 0 {
            if fileCount == 0 {
                fileCount = chosenFiles.count - 1
                chosenFile = chosenFiles[fileCount] as! NSURL
                img = NSImage(byReferencingURL: chosenFile)
                viewImage.image = img
                resizeWindow()
            }
            else {
                fileCount--
                chosenFile = chosenFiles[fileCount] as! NSURL
                img = NSImage(byReferencingURL: chosenFile)
                viewImage.image = img
                resizeWindow()
            }
        }
        else if turnPage.selectedSegment == 1 {
            if fileCount == chosenFiles.count - 1 {
                fileCount = 0
                chosenFile = chosenFiles[fileCount] as! NSURL
                img = NSImage(byReferencingURL: chosenFile)
                viewImage.image = img
                resizeWindow()
            }
            else {
                fileCount++
                chosenFile = chosenFiles[fileCount] as! NSURL
                img = NSImage(byReferencingURL: chosenFile)
                viewImage.image = img
                resizeWindow()
            }
        }
    }
    @IBAction func pageScaling(sender: AnyObject) {
        if pageScaling.selectedSegment == 0 {
            viewImage.imageScaling = NSImageScaling.ImageScaleProportionallyUpOrDown
            resizeWindow()
        }
        else if pageScaling.selectedSegment == 1 {
            viewImage.imageScaling = NSImageScaling.ImageScaleAxesIndependently
        }
    }
    
    func resizeWindow() {
        var resize = window.frame
        var ratio_h = img.size.height / screenResolution!.visibleFrame.height
        var ratio_w = img.size.width / screenResolution!.visibleFrame.width
        var scale = fmax(ratio_h, ratio_w)
        var toolbarHeight = window.frame.size.height - viewImage.frame.size.height
        
        if window.styleMask & NSFullScreenWindowMask == NSFullScreenWindowMask {
            resize.size.height = screenResolution!.frame.height
            resize.size.width = screenResolution!.frame.width
        }
        else if viewImage.imageScaling == NSImageScaling.ImageScaleAxesIndependently {
            //Do nothing
        }
        else if ratio_h > (screenResolution!.visibleFrame.height - toolbarHeight) / screenResolution!.visibleFrame.height || ratio_w > (screenResolution!.visibleFrame.height - toolbarHeight) / screenResolution!.visibleFrame.width {
            if rotateCount == 0 || rotateCount == 2 {
                resize.size.height = img.size.height / scale
                resize.size.width = img.size.width / (img.size.height / (resize.size.height - toolbarHeight))
            }
            else if rotateCount == 4 {
                resize.size.height = img.size.height / scale
                resize.size.width = img.size.width / (img.size.height / (resize.size.height - toolbarHeight))
                rotateCount = 0
            }
            else {
                ratio_h = img.size.width / screenResolution!.visibleFrame.height
                ratio_w = img.size.height / screenResolution!.visibleFrame.width
                scale = fmax(ratio_h, ratio_w)
                resize.size.height = img.size.width / scale
                resize.size.width = img.size.height / (img.size.width / (resize.size.height - toolbarHeight))
            }
        }
        else {
            if rotateCount == 0 || rotateCount == 2 {
                resize.size.height = img.size.height + toolbarHeight
                resize.size.width = img.size.width
            }
            else if rotateCount == 4 { //This resets rotateCount when we've gone 360 degrees
                resize.size.height = img.size.height + toolbarHeight
                resize.size.width = img.size.width
                rotateCount = 0
            }
            else {
                resize.size.height = img.size.width + toolbarHeight //Height and width are flipped
                resize.size.width = img.size.height
            }
        }
        resize.origin.y -= resize.size.height - window.frame.height //Fixes upper-left corner in place
        window.setFrame(resize, display: true, animate: false)
        //viewImage.imageScaling == NSImageScaling.ImageScaleAxesIndependently (ugly fix because window.setFrame rounds up/down)
    }
    
    //Window delegates
    func window(window: NSWindow!, willUseFullScreenPresentationOptions proposedOptions: NSApplicationPresentationOptions) -> NSApplicationPresentationOptions {
        return (NSApplicationPresentationOptions.FullScreen | NSApplicationPresentationOptions.AutoHideDock | NSApplicationPresentationOptions.AutoHideMenuBar | NSApplicationPresentationOptions.AutoHideToolbar)
    }
    func windowDidEnterFullScreen(notification: NSNotification!) {
        resizeWindow()
    }
    func windowDidExitFullScreen(notification: NSNotification!) {
        resizeWindow()
    }
}