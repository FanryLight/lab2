//
//  Document.h
//  GraphicsEditor
//
//  Created by Светлана Медоева on 8/24/16.
//  Copyright © 2016 Светлана Медоева. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DRGCanvasView.h"

@interface Document : NSDocument <NSWindowDelegate>

- (void)addImage:(NSImage *)image;
- (void)exportImage;
- (NSImage *)getImageRepresentation;
- (void)setCursorMode:(DRGCursorModeType)mode;

@end

