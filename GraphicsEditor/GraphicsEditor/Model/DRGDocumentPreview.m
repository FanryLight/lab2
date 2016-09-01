//
//  DRGDocumentPreview.m
//  GraphicsEditor
//
//  Created by Светлана Медоева on 8/29/16.
//  Copyright © 2016 Светлана Медоева. All rights reserved.
//

#import "DRGDocumentPreview.h"

@implementation DRGDocumentPreview

- (instancetype)initWithImage:(NSString *)imagePath document:(NSString *)documentPath name:(NSString *)name ID:(NSInteger)ID
{
    self = [self init];
    if (self)
    {
       
        _image = [[[NSImage alloc] initWithContentsOfURL:
                  [NSURL URLWithString:[NSString stringWithFormat:@"http://%@",imagePath]]] copy];
        _documentURL = [[NSURL URLWithString:[NSString stringWithFormat:@"http://%@",documentPath]] copy];
        _name = [name copy];
        _ID = ID;
    }
    return self;
}

- (void)dealloc
{
    [_image release];
    [_documentURL release];
    [_name release];
    [super dealloc];
}

@end
