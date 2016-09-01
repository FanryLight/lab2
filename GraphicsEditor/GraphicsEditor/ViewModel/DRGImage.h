//
//  DRGImage.h
//  GraphicsEditor
//
//  Created by Светлана Медоева on 8/24/16.
//  Copyright © 2016 Светлана Медоева. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DRGFigure.h"

extern NSString *const kDRGKeyForImage;
extern NSString *const kDRGKeyForRect;

@interface DRGImage : NSObject <NSCoding>

@property (copy, nonatomic, readonly) NSImage *image;
@property (assign, nonatomic) NSRect rect;
@property (assign, nonatomic) BOOL isSelected;

@property (assign, nonatomic) CGFloat selectedRectX;
@property (assign, nonatomic) CGFloat selectedRectY;
@property (assign, nonatomic) CGFloat selectedRectWidth;
@property (assign, nonatomic) CGFloat selectedRectHeight;

+ (instancetype)imageWithFigure:(DRGFigure *)figure;
- (instancetype)initWithImage:(NSImage *)image atRect:(NSRect)rect;

@end