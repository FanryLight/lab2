//
//  DRGConnectionManager.h
//  GraphicsEditor
//
//  Created by Светлана Медоева on 8/27/16.
//  Copyright © 2016 Светлана Медоева. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString *const kDRGActionLogin;
extern NSString *const kDRGActionRegistration;

@interface DRGConnectionManager : NSObject

- (BOOL)getAppkeyWithUsername:(NSString *)username password:(NSString *)password atAction:(NSString *)action completionHandler:(void (^)(NSString *apikey, NSString *error))block;

- (void)uploadDocumentWithImage:(NSImage *)image name:(NSString *)name documentData:(NSURL *)documentData apikey:(NSString *)apikey completionHandler:(void (^)(NSString *error))block;

- (void)getDocumentsWithApikey:(NSString *)apikey completionHandler:(void(^)(NSArray *documents, NSString *error))block;
- (void)downloadByURL:(NSURL *)url apikey:(NSString *)apikey withName:(NSString *)name completionHandler:(void (^)(NSString *error))block;
- (void)deleteFileWithID:(NSInteger)ID apikey:(NSString *)apikey name:(NSString *)name completionHandler:(void (^)(NSString *error))block;

@end
