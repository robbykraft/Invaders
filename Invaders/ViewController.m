//
//  ViewController.m
//  Invaders
//
//  Created by Robby on 8/27/13.
//  Copyright (c) 2013 Robby. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

@synthesize context = _context;
@synthesize effect = _effect;

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        worldTextures = [NSArray arrayWithObjects:@"narthex.png", nil];
    else
        worldTextures = [NSArray arrayWithObjects:@"park.jpg", @"marsh.jpg", nil];//@"narthex.png", @"cave.jpg", @"station.jpg", @"snow_small.jpg", @"office.jpg", nil];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    
    GLKView *view = (GLKView*)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    [EAGLContext setCurrentContext:self.context];
    
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandler:)];
    [self.view addGestureRecognizer:swipeGesture];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchHandler:)];
    [self.view addGestureRecognizer:pinchGesture];
    lastPinchScale = 1.0;
    
    glController = [[GLController alloc] initWithWorld:[worldTextures objectAtIndex:arc4random()%[worldTextures count]]];
    
    [self initLighting];
    
    ///////////////////////////////////////////////////////////////////////////////
    glMatrixMode(GL_PROJECTION);    // the frustum affects the projection matrix
    glLoadIdentity();               // not the model matrix
    if(self.interfaceOrientation == 3 || self.interfaceOrientation == 4)
        aspectRatio = (float)[[UIScreen mainScreen] bounds].size.height / (float)[[UIScreen mainScreen] bounds].size.width;
    else
        aspectRatio = (float)[[UIScreen mainScreen] bounds].size.width / (float)[[UIScreen mainScreen] bounds].size.height;
    
    [self updateFrustrumWithFOV:60];
    
    glViewport(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    ///////////////////////////////////////////////////////////////////////////////
    glEnable(GL_DEPTH_TEST);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    
    motionManager = [[CMMotionManager alloc] init];
    motionManager.deviceMotionUpdateInterval = 1.0/15.0;
    if(motionManager.isDeviceMotionAvailable){
        [motionManager startDeviceMotionUpdates];
        [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler: ^(CMDeviceMotion *deviceMotion, NSError *error){
            CMAttitude *attitude = deviceMotion.attitude;
            [glController setEyeRotationX:(attitude.roll+M_PI/2.0)*180/M_PI Y:(-attitude.yaw)*180/M_PI Z:attitude.pitch*180/M_PI];
            //            [glController buildEyeInterpolationVectorFromNewX:(attitude.roll+M_PI/2.0)*360/M_PI Y:(-attitude.yaw)*360/M_PI Z:attitude.pitch*360/M_PI];
            clock++;
            if(clock >= 15){
                clock = 0;
                NSLog(@"++++++++++++++++++++++++++++++++++++++++");
                NSLog(@"(PITCH:%.2f   ROLL:%.2f   YAW:%.2f)",(attitude.roll+M_PI/2.0)*180/M_PI, attitude.pitch*180/M_PI, (-attitude.yaw)*180/M_PI);
                NSLog(@"----------------------------------------");
            }
        }];
    }
    
    [glController performSelector:@selector(parabolaIncoming) withObject:Nil afterDelay:3.0];
    [glController performSelector:@selector(parabolaIncoming) withObject:Nil afterDelay:15.0];
    [glController performSelector:@selector(parabolaIncoming) withObject:Nil afterDelay:30.0];
    [glController performSelector:@selector(parabolaIncoming) withObject:Nil afterDelay:45.0];
    [glController performSelector:@selector(parabolaIncoming) withObject:Nil afterDelay:60.0];
    [glController performSelector:@selector(parabolaIncoming) withObject:Nil afterDelay:75.0];
    [glController performSelector:@selector(parabolaIncoming) withObject:Nil afterDelay:90.0];
    [glController performSelector:@selector(parabolaIncoming) withObject:Nil afterDelay:105.0];
    
    
    [glController performSelector:@selector(lineIncoming) withObject:Nil afterDelay:3.0];
    [glController performSelector:@selector(lineIncoming) withObject:Nil afterDelay:10.0];
    [glController performSelector:@selector(lineIncoming) withObject:Nil afterDelay:17.0];
    [glController performSelector:@selector(lineIncoming) withObject:Nil afterDelay:24.0];
    [glController performSelector:@selector(lineIncoming) withObject:Nil afterDelay:31.0];
    [glController performSelector:@selector(lineIncoming) withObject:Nil afterDelay:38.0];
    [glController performSelector:@selector(lineIncoming) withObject:Nil afterDelay:45.0];
    [glController performSelector:@selector(lineIncoming) withObject:Nil afterDelay:52.0];
}

-(void) initLighting
{
    GLfloat shinyness = 25.0;
    
    GLfloat posSun[] = {0.0,0.0,0.0,1.0};
    GLfloat posFill1[] = {-15.0,15.0,0.0,1.0};
    GLfloat posFill2[] = {-10.0,-4.0,1.0,1.0};
    
    GLfloat white[] = {1.0,1.0,1.0,1.0};
    GLfloat dim[] = {0.2, 0.2, 0.2, 1.0};
    GLfloat yellow[] = {1.0,1.0,0.0,1.0};
    
    glLightfv(SS_SUNLIGHT, GL_POSITION, posSun);
    glLightfv(SS_SUNLIGHT,GL_DIFFUSE,white);
    glLightfv(SS_SUNLIGHT, GL_SPECULAR, yellow);
    
    glLightfv(SS_FILLLIGHT1, GL_POSITION, posFill1);
    glLightfv(SS_FILLLIGHT1,GL_DIFFUSE,dim);
    glLightfv(SS_FILLLIGHT1, GL_SPECULAR, dim);
    
    glLightfv(SS_FILLLIGHT2, GL_POSITION, posFill2);
    glLightfv(SS_FILLLIGHT2,GL_DIFFUSE,white);
    glLightfv(SS_FILLLIGHT2, GL_SPECULAR, yellow);
    
    glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, white);
    glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, white);
    
    glLightf(SS_SUNLIGHT,GL_QUADRATIC_ATTENUATION,.001);
    
    glMaterialfv(GL_FRONT_AND_BACK,GL_SHININESS, &shinyness);
    
    glShadeModel(GL_SMOOTH);
    glLightModelf(GL_LIGHT_MODEL_TWO_SIDE,0.0);
    
    glEnable(GL_LIGHTING);
    glEnable(SS_SUNLIGHT);
    glEnable(SS_FILLLIGHT1);
    glEnable(SS_FILLLIGHT2);
}

-(void) glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    [glController execute];
}

-(void)swipeHandler:(UISwipeGestureRecognizer*)sender{
//    glController = [[GLController alloc] initWithWorld:[textures objectAtIndex:arc4random()%[textures count]]];
}

-(void) updateFrustrumWithFOV:(GLfloat)fov{
    float zNear = 0.1;
    float zFar = 1000;
    GLfloat frustum = zNear * tanf(GLKMathDegreesToRadians(fov) / 2.0);
    glFrustumf(-frustum, frustum, -frustum/aspectRatio, frustum/aspectRatio, zNear, zFar);
}

-(void)pinchHandler:(UIPinchGestureRecognizer*)sender{
    if([sender state] == 2){
        glMatrixMode(GL_PROJECTION);
        glPushMatrix();
        glLoadIdentity();
        GLfloat fov = 60 /( lastPinchScale * [sender scale]);
        if(fov < 45) fov = 45;
        if(fov > 120) fov = 120;
        [self updateFrustrumWithFOV:fov];
        glMatrixMode(GL_MODELVIEW);
        glPopMatrix();
    }
    else if([sender state] == 3){
        lastPinchScale *= [sender scale];
        if(lastPinchScale < .5) lastPinchScale = .5;
        if(lastPinchScale > 1.333333) lastPinchScale = 1.333333;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end