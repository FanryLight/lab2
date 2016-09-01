//
//  DRGViewModel.m
//  GraphicsEditor
//
//  Created by Светлана Медоева on 8/24/16.
//  Copyright © 2016 Светлана Медоева. All rights reserved.
//

#import "DRGViewModel.h"

NSString *const kDRGKeyPathImageRep = @"imageRep";
NSString *const kDRGKeyPathRect = @"rect";
NSString *const kDRGKeyPathSelectedImage = @"selectedImage";

NSInteger const kDRGDefaultWidth = 150;
NSInteger const kDRGDefaultHeight = 150;
NSString *const kDRGKeyForImageRep = @"imageRep";

@interface DRGViewModel()

@property (retain, nonatomic, readwrite) NSArray<DRGImage *> *imageRep;
@property (retain, nonatomic, readwrite) DRGImage *selectedImage;

@end

@implementation DRGViewModel

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.imageRep forKey:kDRGKeyForImageRep];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    if (self)
    {
        _imageRep = [[aDecoder decodeObjectForKey:kDRGKeyForImageRep] retain];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _imageRep = [[NSArray alloc] init];
    }
    return self;
}

+ (BOOL)automaticallyNotifiesObserversOfImageRep
{
    return YES;
}

- (void)unselect
{
    self.selectedImage.isSelected = NO;
    self.selectedImage = nil;
}

- (void)addFigureWithMode:(NSInteger)mode from:(NSPoint)startPoint to:(NSPoint)endPoint
{
    DRGFigure *figure = [[DRGFigure alloc] initWithType:mode startPoint:startPoint endPoint:endPoint];
    DRGImage *newImageRep = [DRGImage imageWithFigure:figure];
    self.imageRep = [self.imageRep arrayByAddingObject:newImageRep];
    [figure release];
}

- (void)addImage:(NSImage *)image atPoint:(NSPoint)point
{
    CGFloat x = point.x - kDRGDefaultWidth/2;
    CGFloat y = point.y - kDRGDefaultHeight/2;
    NSRect rect = NSMakeRect(x, y, kDRGDefaultWidth, kDRGDefaultHeight);
    DRGImage *newImageRep = [[DRGImage alloc] initWithImage:image atRect:rect];
    self.imageRep = [self.imageRep arrayByAddingObject:newImageRep];
    [newImageRep release];
}

- (void)changePositionTo:(NSPoint)delta
{
    if (self.selectedImage)
    {
        CGFloat newX = self.selectedImage.rect.origin.x + delta.x;
        CGFloat newY = self.selectedImage.rect.origin.y - delta.y;
        NSRect newRect = NSMakeRect(newX, newY, self.selectedImage.rect.size.width, self.selectedImage.rect.size.height);
        self.selectedImage.rect = newRect;
    }
}

- (void)selectImageAtPoint:(NSPoint)point
{
    self.selectedImage.isSelected = NO;
    self.selectedImage = nil;
    for (NSInteger i = self.imageRep.count - 1; i >= 0; i--)
    {
        if (NSPointInRect(point, self.imageRep[i].rect))
        {
            self.selectedImage = self.imageRep[i];
            self.selectedImage.isSelected = YES;
            break;
        }
    }
}

- (NSImage *)imageRepresentationWithSize:(NSSize)size
{
    NSImage *imageR = [NSImage imageWithSize:size flipped:NO drawingHandler:^BOOL(NSRect dstRect) {
        for (DRGImage *element in self.imageRep)
        {
            [element.image drawInRect:element.rect];
        }
        return YES;
    }];
    return imageR;
}

- (void)deleteImage
{
    if (self.selectedImage != nil)
    {
        self.imageRep = [self.imageRep filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != %@", self.selectedImage]];
        self.selectedImage = nil;
    }
}

- (void)dealloc
{
    [_selectedImage release];
    [_imageRep release];
    [super dealloc];
}



@end


