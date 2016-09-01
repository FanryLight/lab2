//
//  DRGFigure.h
//  CheckpointLab2
//
//  Created by Светлана Медоева on 8/22/16.
//  Copyright © 2016 Светлана Медоева. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSInteger, DRGFigureType)
{
    kDRGFigureTypeRectangle = 1,
    kDRGFigureTypeEllipse = 2,
    kDRGFigureTypeLine = 3
};

@interface DRGFigure : NSObject

@property (nonatomic, assign) NSPoint startPoint;
@property (nonatomic, assign) NSPoint endPoint;
@property (nonatomic, assign) DRGFigureType type;

- (instancetype)initWithType:(NSInteger)type startPoint:(NSPoint)startPoint endPoint:(NSPoint)endPoint;

@end
