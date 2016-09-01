//
//  DRGDocumentPreview.h
//  GraphicsEditor
//
//  Created by Светлана Медоева on 8/29/16.
//  Copyright © 2016 Светлана Медоева. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DRGDocumentPreview : NSObject

@property (copy, nonatomic, readonly) NSImage *image;
@property (copy, nonatomic, readonly) NSString *name;
@property (copy, nonatomic, readonly) NSURL *documentURL;
@property (assign, nonatomic, readonly) NSInteger ID;

- (instancetype)initWithImage:(NSString *)imagePath document:(NSString *)documentPath name:(NSString *)name ID:(NSInteger)ID;

@end
