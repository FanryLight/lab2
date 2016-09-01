//
//  DRGAccountManager.m
//  GraphicsEditor
//
//  Created by Светлана Медоева on 8/27/16.
//  Copyright © 2016 Светлана Медоева. All rights reserved.
//

#import "DRGAccountManager.h"
#import "DRGConnectionManager.h"
#import "AppDelegate.h"


NSString *const kDRGLogInAction = @"Log In";
NSString *const kDRGSignUpAction = @"Sign Up";

@interface DRGAccountManager()

@property (assign) IBOutlet NSTableView *tableOfDocuments;
@property (retain, nonatomic) NSArray *myDocuments;

@property (copy, nonatomic) NSString *apikey;
@property (retain, nonatomic) DRGConnectionManager *connectionManager;

@end

@implementation DRGAccountManager

- (BOOL)isLogIn
{
    return !!self.apikey;
}

+ (NSSet *)keyPathsForValuesAffectingIsLogIn
{
    return [NSSet setWithObject:@"apikey"];
}

- (void)awakeFromNib
{
    self.connectionManager = ((AppDelegate *)[NSApplication sharedApplication].delegate).connectionManager;
}

- (void)logIn:(id)sender
{
    self.OKButton.title = kDRGLogInAction;
}

- (void)logOut:(id)sender
{
    self.apikey = nil;
    [self.documentsPanel orderOut:self];
}

- (void)signUp:(id)sender
{
    self.OKButton.title = kDRGSignUpAction;
}

- (void)cancel:(id)sender
{
    [self.accountPanel orderOut:self];
}

- (IBAction)uploadDocument:(NSButton *)sender
{
    Document *document = ((AppDelegate *)[NSApplication sharedApplication].delegate).activeDocument;
    NSString *name =document.windowControllers[0].window.title;
    NSImage *image = [document getImageRepresentation];
    if (document.fileURL)
    {
        NSURL *path = document.fileURL;
        dispatch_async(dispatch_get_main_queue(), ^{
        [self.connectionManager uploadDocumentWithImage:image name:name documentData:path apikey:self.apikey completionHandler:^(NSString *error) {
            if (error)
            {
                self.errorUpload.stringValue = error;
            }
            [self getDocuments];
        }];
        });
    }
    else
    {
        self.errorUpload.stringValue = @"Save Document first";
    }
}

- (void)getDocuments
{
    self.previews = nil;
    [self.connectionManager getDocumentsWithApikey:self.apikey completionHandler:^(NSArray *documents, NSString *error)
     {
         if (!error)
         {
             self.myDocuments = documents;
             for (NSDictionary *dic in self.myDocuments)
             {
                 DRGDocumentPreview *preview = [[DRGDocumentPreview alloc] initWithImage:dic[@"image"] document:dic[@"document"] name:dic[@"name"] ID:[dic[@"id"] integerValue]];
                 if (self.previews)
                 {
                     self.previews = [self.previews arrayByAddingObject:preview];
                 }
                 else
                 {
                     self.previews = @[preview];
                 }
                 [preview release];
             }
         }
         else
         {
             self.error.stringValue = error;
         }
     }];
}

- (void)confirm:(id)sender
{
    self.error.stringValue = @"";
    if (![self.username.stringValue isEqualToString:@""] &&
        ![self.password.stringValue isEqualToString:@""])
    {
        if ([self.OKButton.title isEqualToString:kDRGLogInAction])
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [self.connectionManager getAppkeyWithUsername:self.username.stringValue password:self.password.stringValue atAction:kDRGActionLogin completionHandler:^(NSString *apikey, NSString *error)
                 {
                     if (!error)
                     {
                         self.apikey = apikey;
                         [self.accountPanel orderOut:self];
                         [self getDocuments];
                         [self.documentsPanel orderFront:self];
                     }
                     else
                     {
                         self.error.stringValue = error;
                     }
                 }];
            });
        }
        else if ([self.OKButton.title isEqualToString:kDRGSignUpAction])
        {
            dispatch_async(dispatch_get_main_queue(), ^
               {
                   [self.connectionManager getAppkeyWithUsername:self.username.stringValue password:self.password.stringValue atAction:kDRGActionRegistration completionHandler:^(NSString *apikey, NSString *error)
                    {
                        if (!error)
                        {
                            self.apikey = apikey;
                            [self.accountPanel orderOut:self];
                        }
                        else
                        {
                            self.error.stringValue = error;
                        }
                    }];
               });
        }
    }
}

- (IBAction)deleteDocument:(NSButton *)sender
{
    NSInteger index = self.tableOfDocuments.selectedRow;
    if (index != -1)
    {
        NSInteger ID = self.previews[index].ID;
        dispatch_async(dispatch_get_main_queue(), ^
           {
               [self.connectionManager deleteFileWithID:ID apikey:self.apikey name:self.previews[index].name completionHandler:^(NSString *error)
               {
                   self.errorUpload.stringValue = error;
                   [self getDocuments];
               }];
           });
    }
}

- (IBAction)downloadDocument:(NSButton *)sender
{
    NSInteger index = self.tableOfDocuments.selectedRow;
    if (index != -1)
    {
        NSURL *url = self.previews[index].documentURL;
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           NSString *name = [NSString stringWithFormat:@"%@.drg", self.previews[index].name];
                           [self.connectionManager downloadByURL:url apikey:self.apikey withName:name completionHandler:^(NSString *error)
                           {
                               self.errorUpload.stringValue = error;
                           }];
                       });
    }
}



- (void)dealloc
{
    [_previews release];
    [_myDocuments release];
    [_apikey release];
    [_connectionManager release];
    [super dealloc];
}

@end
