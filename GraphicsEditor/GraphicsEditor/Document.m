//
//  Document.m
//  GraphicsEditor
//
//  Created by Светлана Медоева on 8/24/16.
//  Copyright © 2016 Светлана Медоева. All rights reserved.
//

#import "Document.h"
#import "DRGViewModel.h"
#import "AppDelegate.h"

@interface Document ()

@property (assign, nonatomic) IBOutlet DRGCanvasView *canvas;
@property (retain, nonatomic) DRGViewModel *viewModel;

@end

@implementation Document

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _viewModel = [[DRGViewModel alloc] init];
    }
    return self;
}

- (void)windowDidBecomeKey:(NSNotification *)notification
{
    [self.canvas setNeedsDisplay:YES];
}

- (void)windowDidResignKey:(NSNotification *)notification
{
    [self.canvas setNeedsDisplay:YES];
}

- (void)windowDidBecomeMain:(NSNotification *)notification
{
    ((AppDelegate *)[NSApplication sharedApplication].delegate).activeDocument = self;
}

- (void)windowDidResignMain:(NSNotification *)notification
{
    ((AppDelegate *)[NSApplication sharedApplication].delegate).activeDocument = nil;
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (void)awakeFromNib
{
    self.canvas.viewModel = self.viewModel;
    [self.viewModel addObserver:self.canvas forKeyPath:kDRGKeyPathImageRep options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    [self.viewModel addObserver:self.canvas forKeyPath:kDRGKeyPathSelectedImage options: NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    for (DRGImage *image in self.viewModel.imageRep)
    {
        [image addObserver:self.canvas forKeyPath:kDRGKeyPathRect options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    }
}

- (NSString *)windowNibName
{
    return @"Document";
}

- (void)addImage:(NSImage *)image
{
    [self.viewModel addImage:image atPoint:NSMakePoint(self.canvas.visibleRect.size.width/2, self.canvas.visibleRect.size.height/2)];
}

- (NSImage *)getImageRepresentation
{
    NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithData:[[self.viewModel imageRepresentationWithSize:self.canvas.visibleRect.size] TIFFRepresentation]];
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:2.0] forKey:NSImageCompressionFactor];
    NSData *compressedData = [imageRep representationUsingType:NSJPEGFileType properties:options];
    NSImage *image = [[NSImage alloc] initWithData:compressedData];
    [imageRep release];
    return [image autorelease];
}

- (void)exportImage
{
    NSWindow* window = [[[self windowControllers] objectAtIndex:0] window];
    NSString* newName = [[self.displayName stringByDeletingPathExtension]
                         stringByAppendingPathExtension:@"tiff"];
    
    NSSavePanel*    panel = [NSSavePanel savePanel];
    [panel setNameFieldStringValue:newName];
    [panel beginSheetModalForWindow:window completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton)
        {
            NSURL*  theFile = [panel URL];
            NSBitmapImageFileType fileType = NSJPEGFileType;
            NSString *type = [theFile.absoluteString componentsSeparatedByString:@"."][1];
            if ([type isEqualToString:@"png"])
            {
                fileType = NSPNGFileType;
            }
            else if ([type isEqualToString:@"jpg"])
            {
                fileType = NSJPEGFileType;
            }
            else if ([type isEqualToString:@"tiff"])
            {
                fileType = NSTIFFFileType;
            }
            else if ([type isEqualToString:@"bmp"])
            {
                fileType = NSBMPFileType;
            }
            else
            {
                return;
            }
            NSImage *image = [self.viewModel imageRepresentationWithSize:self.canvas.visibleRect.size];
            NSData *imageData = [image TIFFRepresentation];
            NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
            NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
            imageData = [imageRep representationUsingType:fileType properties:imageProps];
            NSError *error = nil;
            [imageData writeToURL:theFile options:NSDataWritingAtomic error:&error];
            if (error)
            {
                NSLog(@"%@", error);
            }
        }
        
    }];

}

- (void)setCursorMode:(DRGCursorModeType)mode
{
    self.canvas.cursoreMode = mode;
    [self.viewModel unselect];
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.viewModel];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"document"];
    return data;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
    self.viewModel  = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    self.canvas.viewModel = self.viewModel;
    return YES;
}

- (void)dealloc
{
    [_viewModel release];
    [super dealloc];
}

@end
