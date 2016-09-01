//
//  DRGCanvasView.m
//  GraphicsEditor
//
//  Created by Светлана Медоева on 8/24/16.
//  Copyright © 2016 Светлана Медоева. All rights reserved.
//

#import "DRGCanvasView.h"
#import "DRGPasteboardItem.h"

@interface DRGCanvasView() <NSPasteboardItemDataProvider>

@property (assign, nonatomic) NSPoint startPoint;
@property (assign, nonatomic) NSPoint endPoint;
@property (assign, nonatomic) NSPoint point;

@end

@implementation DRGCanvasView

- (void)drawRect:(NSRect)dirtyRect
{
    for (DRGImage * element in self.viewModel.imageRep)
    {
        [NSGraphicsContext saveGraphicsState];
        if (element.isSelected)
        {
            [self setKeyboardFocusRingNeedsDisplayInRect:[self bounds]];
            [[NSColor keyboardFocusIndicatorColor] setFill];
            NSSetFocusRingStyle(NSFocusRingAbove);
        }
        [element.image drawInRect:element.rect];
        [NSGraphicsContext restoreGraphicsState];
    }
}

- (void)awakeFromNib
{
    [self registerForDraggedTypes:@[(NSString *)kUTTypeItem]];
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
    if ([NSImage canInitWithPasteboard:[sender draggingPasteboard]] &&
        [sender draggingSourceOperationMask] & NSDragOperationCopy)
    {
        return NSDragOperationCopy;
    }
    return NSDragOperationNone;
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender
{
    return YES;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender
{
    if ([NSImage canInitWithPasteboard:[sender draggingPasteboard]])
    {
        NSImage *newImage = [[NSImage alloc] initWithPasteboard:[sender draggingPasteboard]];
        NSPoint startPoint = sender.draggingLocation;
        [self.viewModel addImage:newImage atPoint:startPoint];
        [newImage release];
    }
    return YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:kDRGKeyPathImageRep])
    {
        if (((NSArray *)change[@"old"]).count < ((NSArray *)change[@"new"]).count)
        {
            DRGImage *image = [[change valueForKey:@"new"] lastObject];
            [image addObserver:self forKeyPath:kDRGKeyPathRect options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
            [self setNeedsDisplayInRect:image.rect];
        }
        else if (((NSArray *)change[@"old"]).count > ((NSArray *)change[@"new"]).count)
        {
            [self setNeedsDisplayInRect:self.viewModel.selectedImage.rect];
            [self.viewModel.selectedImage removeObserver:self forKeyPath:kDRGKeyPathRect];
        }
    }
    else if([keyPath isEqualToString:kDRGKeyPathSelectedImage])
    {
        if ([change[@"old"] isKindOfClass:[DRGImage class]])
        {
            DRGImage *image = [change valueForKey:@"old"];
            NSRect rect = NSMakeRect(image.rect.origin.x - 5, image.rect.origin.y - 5, image.rect.size.width + 10, image.rect.size.height + 10);
            [self setNeedsDisplayInRect:rect];
        }
        else if([change[@"new"] isKindOfClass:[DRGImage class]])
        {
            DRGImage *image = [change valueForKey:@"new"];
            NSRect rect = NSMakeRect(image.rect.origin.x - 5, image.rect.origin.y - 5, image.rect.size.width + 10, image.rect.size.height + 10);
            [self setNeedsDisplayInRect:rect];
        }
    }
    else if ([keyPath isEqualToString:kDRGKeyPathRect])
    {
        NSRect oldRect = [change[@"old"] rectValue];
        NSRect newRect = [change[@"new"] rectValue];
        NSRect orect = NSMakeRect(oldRect.origin.x - 5, oldRect.origin.y - 5, oldRect.size.width + 10, oldRect.size.height + 10);
        NSRect nrect = NSMakeRect(newRect.origin.x - 5, newRect.origin.y - 5, newRect.size.width + 10, newRect.size.height + 10);
        [self setNeedsDisplayInRect:orect];
        [self setNeedsDisplayInRect:nrect];
    }
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
}

- (void)mouseUp:(NSEvent *)theEvent
{
    NSPoint location = [self convertPoint:theEvent.locationInWindow toView:nil];
    self.endPoint = location;
    if (self.cursoreMode != kDRGCursorModeDefault)
    {
        [self.viewModel addFigureWithMode:self.cursoreMode from:self.startPoint to:self.endPoint];
    }
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    NSPoint newLocation = [self convertPoint:theEvent.locationInWindow toView:nil];
    NSPoint delta = NSMakePoint((newLocation.x - self.point.x),
                                (self.point.y - newLocation.y));
    self.point = newLocation;
    [self.viewModel changePositionTo:delta];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    NSPoint location = [self convertPoint:theEvent.locationInWindow toView:nil];
    self.startPoint = location;
    self.point = location;
    if (self.cursoreMode == kDRGCursorModeDefault)
    {
        [self.viewModel selectImageAtPoint:location];
    }
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void)keyDown:(NSEvent *)theEvent
{
    NSString* pressedChars = [theEvent characters];
    unichar pressedUnichar = [pressedChars characterAtIndex:0];
    if ( (pressedUnichar == NSDeleteCharacter) ||
        (pressedUnichar == 0xf728) )
    {
        [self.viewModel deleteImage];
    }
    else
    {
        [super keyDown:theEvent];
    }
}

- (void)moveUp:(id)sender
{
    NSPoint delta = NSMakePoint(0, -1);
    [self.viewModel changePositionTo:delta];
}

- (void)moveDown:(id)sender
{
    NSPoint delta = NSMakePoint(0, 1);
    [self.viewModel changePositionTo:delta];
}

- (void)moveLeft:(id)sender
{
    NSPoint delta = NSMakePoint(-1, 0);
    [self.viewModel changePositionTo:delta];
}

- (void)moveRight:(id)sender
{
    NSPoint delta = NSMakePoint(1, 0);
    [self.viewModel changePositionTo:delta];
}

- (void)dealloc
{
    for (DRGImage *image in _viewModel.imageRep)
    {
        [image removeObserver:self forKeyPath:kDRGKeyPathRect];
    }
    [_viewModel removeObserver:self forKeyPath:kDRGKeyPathImageRep];
    [_viewModel removeObserver:self forKeyPath:kDRGKeyPathSelectedImage];
    [_viewModel release];
    [super dealloc];
}

#pragma mark - Copy/Paste

- (NSPasteboardItem *)pasteboardItemForBoard:(NSPasteboard *)aBoard
{
    DRGPasteboardItem *item = nil;
    if (self.viewModel.selectedImage)
    {
        item = [DRGPasteboardItem new];
        item.image = self.viewModel.selectedImage.image;
        NSArray *types = [[NSURL URLWithString:@"file:/"] writableTypesForPasteboard:aBoard];
        types = [types arrayByAddingObjectsFromArray:[NSImage imageTypes]];
        [item setDataProvider:self forTypes:types];
    }
    return [item autorelease];
}

- (void)copy:(id)sender
{
    NSPasteboard *board = [NSPasteboard generalPasteboard];
    NSPasteboardItem *item = [self pasteboardItemForBoard:board];
    if (item)
    {
        [board clearContents];
        [board writeObjects:@[item]];
    }
}

- (BOOL)canReadFromPasteboard:(NSPasteboard *)aBoard
{
    BOOL result = [NSImage canInitWithPasteboard:aBoard];
    if (!result)
    {
        NSURL *url = [NSURL URLFromPasteboard:aBoard];
        if (url)
        {
            NSImage *image = [[NSImage alloc] initWithContentsOfURL:url];
            if (image)
            {
                result = YES;
            }
            [image release];
        }
    }
    return result;
}

- (void)paste:(id)sender
{
    [self pasteFromBoard:[NSPasteboard generalPasteboard]];
}

- (BOOL)pasteFromBoard:(NSPasteboard *)aBoard
{
    NSImage *image = nil;
    NSURL *url = [NSURL URLFromPasteboard:aBoard];
    if (url)
    {
        image = [[NSImage alloc] initWithContentsOfURL:url];
        if (!image)
        {
            image = [[NSImage alloc] initWithPasteboard:aBoard];
        }
    }
    
    if (image)
    {
        [self.viewModel addImage:image atPoint:self.startPoint];
        [self setNeedsDisplay:YES];
    }
    BOOL result = NO;
    if (image)
    {
        result = YES;
    }
    [image release];
    return result;
}

- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)anItem
{
    BOOL result = NO;
    if (anItem.action == @selector(copy:))
    {
        result = self.viewModel.selectedImage != nil;
    }
    else if (anItem.action == @selector(paste:))
    {
        result = [self canReadFromPasteboard:[NSPasteboard generalPasteboard]];
    }
    return result;
}

- (void)pasteboard:(NSPasteboard *)aPasteboard item:(NSPasteboardItem *)anItem provideDataForType:(NSString *)aType
{
    if ([anItem isKindOfClass:[DRGPasteboardItem class]])
    {
        NSImage *image = ((DRGPasteboardItem *)anItem).image;
        id representation = nil;
        if ([[image writableTypesForPasteboard:aPasteboard] containsObject:aType])
        {
            representation = [image pasteboardPropertyListForType:aType];
        }
        
        if (representation)
        {
            [aPasteboard setPropertyList:representation forType:aType];
        }
        else
        {
            NSString *tempPath = NSTemporaryDirectory();
            tempPath = [tempPath stringByAppendingPathComponent:@"temp_image.tiff"];
            if ([image.TIFFRepresentation writeToFile:tempPath atomically:YES])
            {
                NSURL *url = [NSURL fileURLWithPath:tempPath isDirectory:NO];
                if ([[url writableTypesForPasteboard:aPasteboard] containsObject:aType])
                {
                    [url writeToPasteboard:aPasteboard];
                }
            }
        }
    }
}


@end