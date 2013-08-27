//
//  Line.h
//  Invaders
//
//  Created by Robby on 8/27/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sphere.h"
#import "Square.h"

@interface Line : NSObject{
    GLfloat m_targetPosition[3];
}

@property Square *square;
@property NSMutableArray *particleTrail;
@property GLfloat completed;

@property GLfloat angle;
@property GLfloat distance;

-(void)setPositionX:(CGFloat)x Y:(CGFloat)y Z:(CGFloat)z;
-(GLfloat)getX;
-(GLfloat)getY;
-(GLfloat)getZ;
-(void)increment;

@end
