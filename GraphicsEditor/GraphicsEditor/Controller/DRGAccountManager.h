//
//  DRGAccountManager.h
//  GraphicsEditor
//
//  Created by Светлана Медоева on 8/27/16.
//  Copyright © 2016 Светлана Медоева. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DRGDocumentPreview.h"

@interface DRGAccountManager : NSObject

@property (readonly, nonatomic, assign) BOOL isLogIn;

@property (assign, nonatomic) IBOutlet NSPanel *accountPanel;
@property (assign, nonatomic) IBOutlet NSPanel *documentsPanel;

@property (assign, nonatomic) IBOutlet NSButton *OKButton;
@property (assign) IBOutlet NSTextField *username;
@property (assign) IBOutlet NSTextField *password;
@property (assign) IBOutlet NSTextField *error;
@property (assign) IBOutlet NSTextField *errorUpload;

@property (retain, nonatomic) NSArray<DRGDocumentPreview *> *previews;

- (IBAction)logIn:(id)sender;
- (IBAction)logOut:(id)sender;
- (IBAction)signUp:(id)sender;

- (IBAction)cancel:(id)sender;
- (IBAction)confirm:(id)sender;

@end
