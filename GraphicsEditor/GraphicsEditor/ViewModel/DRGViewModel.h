//
//  DRGViewModel.h
//  GraphicsEditor
//
//  Created by Светлана Медоева on 8/24/16.
//  Copyright © 2016 Светлана Медоева. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DRGImage.h"

@class DRGCanvasView;

extern NSString *const kDRGKeyPathImageRep;
extern NSString *const kDRGKeyPathRect;
extern NSString *const kDRGKeyPathSelectedImage;

extern NSInteger const kDRGDefaultWidth;
extern NSInteger const kDRGDefaultHeight;
extern NSString *const kDRGKeyForImageRep;

@interface DRGViewModel : NSObject <NSCoding>

@property (retain, nonatomic, readonly) NSArray<DRGImage *> *imageRep;
@property (retain, nonatomic, readonly) DRGImage *selectedImage;

- (void)addImage:(NSImage *)image atPoint:(NSPoint)point;
- (void)addFigureWithMode:(NSInteger)mode from:(NSPoint)startPoint to:(NSPoint)endPoint;
- (void)selectImageAtPoint:(NSPoint)point;
- (void)changePositionTo:(NSPoint)delta;
- (void)deleteImage;
- (void)unselect;

- (NSImage *)imageRepresentationWithSize:(NSSize)size;

@end