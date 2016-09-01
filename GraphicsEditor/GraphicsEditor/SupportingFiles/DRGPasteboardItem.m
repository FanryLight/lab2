//
//  DRGPasteboardItem.m
//  GraphicsEditor
//
//  Created by Светлана Медоева on 8/26/16.
//  Copyright © 2016 Светлана Медоева. All rights reserved.
//

#import "DRGPasteboardItem.h"

@implementation DRGPasteboardItem

- (void)dealloc
{
    [_image release];
    [super dealloc];
}

@end
