//
//  DRGFigure.m
//  CheckpointLab2
//
//  Created by Светлана Медоева on 8/22/16.
//  Copyright © 2016 Светлана Медоева. All rights reserved.
//

#import "DRGFigure.h"

@implementation DRGFigure

- (instancetype)initWithType:(NSInteger)type startPoint:(NSPoint)startPoint endPoint:(NSPoint)endPoint
{
    self = [self init];
    if (self)
    {
        _startPoint = startPoint;
        _endPoint = endPoint;
        _type = type;
    }
    return self;
}

@end