//
//  AppDelegate.h
//  GraphicsEditor
//
//  Created by Светлана Медоева on 8/24/16.
//  Copyright © 2016 Светлана Медоева. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Document.h"
#import "DRGConnectionManager.h"



@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (retain, nonatomic) DRGConnectionManager *connectionManager;
@property (retain, nonatomic) Document *activeDocument;
@property (retain, nonatomic) NSArray<NSImage *> *standartLibrary;

@property (assign) IBOutlet NSPanel *libraryPanel;
@property (assign) IBOutlet NSPanel *inspectorPanel;
@property (assign) IBOutlet NSPanel *figuresPanel;


@end

