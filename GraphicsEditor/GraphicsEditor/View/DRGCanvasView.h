//
//  DRGCanvasView.h
//  GraphicsEditor
//
//  Created by Светлана Медоева on 8/24/16.
//  Copyright © 2016 Светлана Медоева. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DRGViewModel.h"

typedef NS_ENUM(NSInteger, DRGCursorModeType)
{
    kDRGCursorModeDefault = 0,
    kDRGCursorModeRectangle = 1,
    kDRGCursorModeEllipse = 2,
    kDRGCursorModeLine = 3
};

@interface DRGCanvasView : NSView <NSDraggingDestination>

@property (retain, nonatomic) DRGViewModel *viewModel;
@property (assign, nonatomic) DRGCursorModeType cursoreMode;

@end


