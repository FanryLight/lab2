//
//  DRGImage.m
//  GraphicsEditor
//
//  Created by Светлана Медоева on 8/24/16.
//  Copyright © 2016 Светлана Медоева. All rights reserved.
//

#import "DRGImage.h"

NSString *const kDRGKeyForImage = @"image";
NSString *const kDRGKeyForRect = @"rect";

@interface DRGImage()
{
    CGFloat _selectedRectX;
    CGFloat _selectedRectY;
    CGFloat _selectedRectWidth;
    CGFloat _selectedRectHeight;
}

@property (copy, nonatomic, readwrite) NSImage *image;

@end

@implementation DRGImage

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    NSImage *image = [aDecoder decodeObjectForKey:kDRGKeyForImage];
    NSRect rect = [aDecoder decodeRectForKey:kDRGKeyForRect];
    self = [self initWithImage:image atRect:rect];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.image forKey:kDRGKeyForImage];
    [aCoder encodeRect:self.rect forKey:kDRGKeyForRect];
}

- (instancetype)initWithImage:(NSImage *)image atRect:(NSRect)rect
{
    self = [super init];
    if (self)
    {
        _image = [[NSImage imageWithSize:image.size flipped:NO drawingHandler:^BOOL(NSRect dstRect)
                                          {
                                              [image drawInRect:dstRect];
                                              return YES;
                                          }] copy];
        _rect = rect;
    }
    return self;
}

+ (NSImage *)lineWithFigure:(DRGFigure *)figure size:(NSSize)imageSize
{
    NSImage *image = nil;
    NSBezierPath *path = [[NSBezierPath alloc] init];
    if (figure.startPoint.x < figure.endPoint.x && figure.startPoint.y < figure.endPoint.y)
    {
        image = [NSImage imageWithSize:imageSize flipped:NO drawingHandler:^BOOL(NSRect dstRect)
                 {
                     NSPoint first = dstRect.origin;
                     NSPoint second = NSMakePoint(dstRect.origin.x + dstRect.size.width, dstRect.origin.y + dstRect.size.height);
                     [path moveToPoint:first];
                     [path lineToPoint:second];
                     [path stroke];
                     return YES;
                 }];
    }
    else if (figure.startPoint.x > figure.endPoint.x && figure.startPoint.y < figure.endPoint.y)
    {
        image = [NSImage imageWithSize:imageSize flipped:NO drawingHandler:^BOOL(NSRect dstRect)
                 {
                     NSPoint first = NSMakePoint(dstRect.origin.x + dstRect.size.width, dstRect.origin.y);
                     NSPoint second = NSMakePoint(dstRect.origin.x, dstRect.origin.y + dstRect.size.height);
                     [path moveToPoint:first];
                     [path lineToPoint:second];
                     [path stroke];
                     return YES;
                 }];
    }
    else if (figure.startPoint.x > figure.endPoint.x && figure.startPoint.y > figure.endPoint.y)
    {
        image = [NSImage imageWithSize:imageSize flipped:NO drawingHandler:^BOOL(NSRect dstRect)
                 {
                     NSPoint first = NSMakePoint(dstRect.origin.x + dstRect.size.width, dstRect.origin.y + dstRect.size.height);
                     NSPoint second = NSMakePoint(dstRect.origin.x, dstRect.origin.y);
                     [path moveToPoint:first];
                     [path lineToPoint:second];
                     [path stroke];
                     return YES;
                 }];
    }
    else if (figure.startPoint.x < figure.endPoint.x && figure.startPoint.y > figure.endPoint.y)
    {
        image = [NSImage imageWithSize:imageSize flipped:NO drawingHandler:^BOOL(NSRect dstRect)
                 {
                     NSPoint first = NSMakePoint(dstRect.origin.x, dstRect.origin.y + dstRect.size.height);
                     NSPoint second = NSMakePoint(dstRect.origin.x + dstRect.size.width, dstRect.origin.y);
                     [path moveToPoint:first];
                     [path lineToPoint:second];
                     [path stroke];
                     return YES;
                 }];
    }
    [path release];
    return image;
}

+ (NSImage *)ellipseWithFigure:(DRGFigure *)figure size:(NSSize)imageSize
{
    NSImage *image = nil;
    NSBezierPath *path = [[NSBezierPath alloc] init];
    image = [NSImage imageWithSize:imageSize flipped:NO drawingHandler:^BOOL(NSRect dstRect)
     {
         [path appendBezierPathWithOvalInRect:NSMakeRect(dstRect.origin.x, dstRect.origin.y, dstRect.size.width, dstRect.size.height)];
         [path stroke];
         return YES;
     }];
    [path release];
    return image;
}

+ (NSImage *)rectangleWithFigure:(DRGFigure *)figure size:(NSSize)imageSize
{
    NSImage *image = nil;
    NSBezierPath *path = [[NSBezierPath alloc] init];
        image = [NSImage imageWithSize:imageSize flipped:NO drawingHandler:^BOOL(NSRect dstRect)
                 {
                     [path setLineWidth:2.5];
                     [path appendBezierPathWithRect:NSMakeRect(dstRect.origin.x, dstRect.origin.y, dstRect.size.width, dstRect.size.height)];
                     [path stroke];
                     return YES;
                 }];
    [path release];
    return image;
}

+ (NSRect)rectForFigure:(DRGFigure *)figure
{
    NSRect rect;
    NSSize imageSize = NSMakeSize(figure.endPoint.x - figure.startPoint.x, figure.endPoint.y - figure.startPoint.y);
    if (imageSize.width == 0 || imageSize.height == 0)
    {
        rect = NSMakeRect(figure.startPoint.x - 75, figure.startPoint.y - 75, 150, 150);
    }
    else if (imageSize.width > 0 && imageSize.height > 0)
    {
        rect = NSMakeRect(figure.startPoint.x, figure.startPoint.y, imageSize.width, imageSize.height);
    }
    else if (imageSize.width < 0 && imageSize.height > 0)
    {
        rect = NSMakeRect(figure.endPoint.x, figure.startPoint.y, -imageSize.width, imageSize.height);
    }
    else if (imageSize.width < 0 && imageSize.height < 0)
    {
        rect = NSMakeRect(figure.endPoint.x, figure.endPoint.y, -imageSize.width, -imageSize.height);

    }
    else if (imageSize.width > 0 && imageSize.height < 0)
    {
        rect = NSMakeRect(figure.startPoint.x, figure.endPoint.y, imageSize.width, -imageSize.height);
    }
    return rect;
}

+ (DRGImage *)imageWithFigure:(DRGFigure *)figure
{
    DRGImage *drgImage = [[DRGImage alloc] init];
    NSSize imageSize = NSMakeSize(fabs(figure.startPoint.x - figure.endPoint.x), fabs(figure.startPoint.y - figure.endPoint.y));
    if (imageSize.width == 0 || imageSize.height == 0)
    {
        imageSize = NSMakeSize(150, 150);
    }
    switch (figure.type)
    {
        case kDRGFigureTypeLine:
            drgImage.image = [self lineWithFigure:figure size:imageSize];
            drgImage.rect = [self rectForFigure:figure];
            break;
        case kDRGFigureTypeEllipse:
            drgImage.image = [self ellipseWithFigure:figure size:imageSize];
            drgImage.rect = [self rectForFigure:figure];
            break;
        case kDRGFigureTypeRectangle:
            drgImage.image = [self rectangleWithFigure:figure size:imageSize];
            drgImage.rect = [self rectForFigure:figure];
            break;
        default:
            break;
    }
    return drgImage;
}

+ (NSSet *)keyPathsForValuesAffectingSelectedRectX
{
    return [NSSet setWithObject:@"rect"];
}

+ (NSSet *)keyPathsForValuesAffectingSelectedRectY
{
    return [NSSet setWithObject:@"rect"];
}

+ (NSSet *)keyPathsForValuesAffectingSelectedRectWidth
{
    return [NSSet setWithObject:@"rect"];
}

+ (NSSet *)keyPathsForValuesAffectingSelectedRectHeight
{
    return [NSSet setWithObject:@"rect"];
}

- (CGFloat)selectedRectX
{
    return _rect.origin.x;
}

- (void)setNilValueForKey:(NSString *)key
{
    if ([key isEqualToString:@"selectedRectX"])
    {
        self.selectedRectX = 0;
    }
    else if ([key isEqualToString:@"selectedRectY"])
    {
        self.selectedRectY = 0;
    }
    else if ([key isEqualToString:@"selectedRectWidth"])
    {
        self.selectedRectWidth = 150;
    }
    else if ([key isEqualToString:@"selectedRectHeight"])
    {
        self.selectedRectHeight = 150;
    }
}

- (void)setSelectedRectX:(CGFloat)selectedRectX
{
    if (self.isSelected)
    {
        _selectedRectX = selectedRectX;
        self.rect = NSMakeRect(selectedRectX, self.selectedRectY, self.selectedRectWidth, self.selectedRectHeight);;
    }
}

- (CGFloat)selectedRectY
{
    return _rect.origin.y;
}

- (void)setSelectedRectY:(CGFloat)selectedRectY
{
    if (self.isSelected)
    {
        _selectedRectY = selectedRectY;
        self.rect = NSMakeRect(self.selectedRectX, selectedRectY, self.selectedRectWidth, self.selectedRectHeight);;
    }
}

- (CGFloat)selectedRectWidth
{
    return _rect.size.width;
}

- (void)setSelectedRectWidth:(CGFloat)selectedRectWidth
{
    if (self.isSelected)
    {
        _selectedRectWidth = selectedRectWidth;
        self.rect = NSMakeRect(self.selectedRectX, self.selectedRectY, selectedRectWidth, self.selectedRectHeight);;
    }
}

- (CGFloat)selectedRectHeight
{
    return _rect.size.height;
}

- (void)setSelectedRectHeight:(CGFloat)selectedRectHeight
{
    if (self.isSelected)
    {
        _selectedRectHeight = selectedRectHeight;
        self.rect = NSMakeRect(self.selectedRectX, self.selectedRectY, self.selectedRectWidth, selectedRectHeight);;
    }
}

- (void)dealloc
{
    [_image release];
    [super dealloc];
}

@end