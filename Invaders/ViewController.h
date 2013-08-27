//
//  ViewController.h
//  Invaders
//
//  Created by Robby on 8/27/13.
//  Copyright (c) 2013 Robby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <OpenGLES/ES1/gl.h>
#import <CoreMotion/CoreMotion.h>
#import "GLController.h"

#define SS_SUNLIGHT GL_LIGHT0
#define SS_FILLLIGHT1 GL_LIGHT1
#define SS_FILLLIGHT2 GL_LIGHT2

@interface ViewController : GLKViewController{
    GLController *glController;
    CMMotionManager *motionManager;
    NSArray *textures;
    CADisplayLink *displayLink;
    NSInteger clock;
    CGFloat aspectRatio;
    CGFloat lastPinchScale;
}
@property (strong,nonatomic) EAGLContext *context;
@property (strong,nonatomic) GLKBaseEffect *effect;

@end
