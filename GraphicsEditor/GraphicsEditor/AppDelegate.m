//
//  AppDelegate.m
//  GraphicsEditor
//
//  Created by Светлана Медоева on 8/24/16.
//  Copyright © 2016 Светлана Медоева. All rights reserved.
//

#import "AppDelegate.h"


@interface AppDelegate ()

@end

@implementation AppDelegate

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _connectionManager = [[DRGConnectionManager alloc] init];
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self.activeDocument setCursorMode:kDRGCursorModeDefault];
    NSArray *array = [[NSArray alloc] init];
    self.standartLibrary = array;
    [array release];
    NSArray* myImages = [[NSBundle mainBundle] pathsForResourcesOfType:@"jpg"
                                                           inDirectory:nil];
    myImages = [myImages arrayByAddingObjectsFromArray:[[NSBundle mainBundle] pathsForResourcesOfType:@"png"
                                                                                          inDirectory:nil]];
    for (NSString *imagePath in myImages)
    {
        NSImage *image = [[[NSImage alloc] initWithContentsOfFile:imagePath] autorelease];
        NSString * name = [[imagePath componentsSeparatedByString:@"/"] lastObject];
        name = [name componentsSeparatedByString:@"."][0];
        image.name = name;
        self.standartLibrary = [self.standartLibrary arrayByAddingObject:image];
    }
}

- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(nonnull NSIndexSet *)rowIndexes toPasteboard:(nonnull NSPasteboard *)pboard
{
    NSData *data = [self.standartLibrary[[rowIndexes firstIndex]] TIFFRepresentation];
    [pboard declareTypes:[NSArray arrayWithObject:NSTIFFPboardType] owner:self];
    [pboard setData:data forType:NSTIFFPboardType];
    return YES;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

-(IBAction)cursorDefault:(NSButton *)sender
{
    [self.activeDocument setCursorMode:kDRGCursorModeDefault];
}

-(IBAction)cursorRectangle:(id)sender
{
    [self.activeDocument setCursorMode:kDRGCursorModeRectangle];;
}

-(IBAction)cursorEllipse:(id)sender
{
    [self.activeDocument setCursorMode:kDRGCursorModeEllipse];;
}

-(IBAction)cursorLine:(id)sender
{
    [self.activeDocument setCursorMode:kDRGCursorModeLine];
}

- (IBAction)exportImage:(id)sender
{
    [self.activeDocument exportImage];
}

- (IBAction)doubleClickAtLibraryImage:(NSTableView *)sender
{
    NSImage *selectedImage = self.standartLibrary[sender.selectedRow];
    [self.activeDocument addImage:selectedImage];
}

- (void)dealloc
{
    [_connectionManager release];
    [_activeDocument release];
    [_standartLibrary release];
    [super dealloc];
}

@end
