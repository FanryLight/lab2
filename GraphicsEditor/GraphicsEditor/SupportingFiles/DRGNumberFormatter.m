//
//  DRGNumberFormatter.m
//  GraphicsEditor
//
//  Created by Светлана Медоева on 8/26/16.
//  Copyright © 2016 Светлана Медоева. All rights reserved.
//

#import "DRGNumberFormatter.h"

@implementation DRGNumberFormatter

- (BOOL)isPartialStringValid:(NSString*)partialString newEditingString:(NSString**)newString errorDescription:(NSString**)error
{
    if([partialString length] == 0)
    {
        return YES;
    }
    NSScanner* scanner = [NSScanner scannerWithString:partialString];
    
    if(!([scanner scanInt:0] && [scanner isAtEnd]))
    {
        return NO;
    }
    return YES;
}

@end
