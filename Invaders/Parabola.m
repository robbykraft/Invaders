//
//  Parabola.m
//  Invaders
//
//  Created by Robby on 8/26/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import "Parabola.h"

#define X_VALUE     0
#define Y_VALUE     1
#define Z_VALUE     2

@implementation Parabola

@synthesize sphere;
@synthesize particleTrail;

@synthesize angle;
@synthesize distance;
@synthesize completed;

-(id)init{
    self = [super init];
    sphere = [[Sphere alloc] init:50 slices:50 radius:.05 squash:1.0 textureFile:@"moon.jpg"];
    m_targetPosition[X_VALUE] = m_targetPosition[Y_VALUE] = m_targetPosition[Z_VALUE] = 0.0;
    [sphere setPositionX:0.0 Y:0.0 Z:0.0];

    completed = 1.0;
    particleTrail = [NSMutableArray array];

    return self;
}

-(void)increment
{
    completed-=.002;
    m_targetPosition[Y_VALUE] = -pow(.5*(distance*completed-distance*.5) , 2)+.5*distance;

    m_targetPosition[X_VALUE] = completed*distance*sinf(angle);
    m_targetPosition[Z_VALUE] = completed*distance*cosf(angle);
    
    [sphere setPositionX:m_targetPosition[X_VALUE] Y:m_targetPosition[Y_VALUE] Z:(m_targetPosition[Z_VALUE])];
}

-(void)setPositionX:(CGFloat)x Y:(CGFloat)y Z:(CGFloat)z{
    m_targetPosition[X_VALUE] = x;
    m_targetPosition[Y_VALUE] = y;
    m_targetPosition[Z_VALUE] = z;
}

-(GLfloat)getX{return m_targetPosition[X_VALUE];}
-(GLfloat)getY{return m_targetPosition[Y_VALUE];}
-(GLfloat)getZ{return m_targetPosition[Z_VALUE];}

@end