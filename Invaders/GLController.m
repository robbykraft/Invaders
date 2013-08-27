//
//  GLController.m
//  360 Panorama
//
//  Created by Robby Kraft on 8/24/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import "GLController.h"
#import "gluLookAt.h"

@implementation GLController

-(id) initWithWorld:(NSString*)textureFile{
    [self initGeometry];
    m_CelestialSphere = [[Sphere alloc] init:50 slices:50 radius:100.0 squash:1.0 textureFile:textureFile];
    [m_CelestialSphere setPositionX:0.0 Y:0.0 Z:0.0];

    parabolae = [NSMutableArray array];
    lines = [NSMutableArray array];
    return self;
}

-(id) init{
    return [self initWithWorld:@"park.jpg"];
}

-(void)swapWorldTexture:(NSString*)textureFile{
    NSLog(@"Now Entering %@",textureFile);
    [m_CelestialSphere swapTexture:textureFile];
}

-(void)initGeometry{
    m_Eyeposition[X_VALUE] = 0.0;
    m_Eyeposition[Y_VALUE] = 0.0;
    m_Eyeposition[Z_VALUE] = 0.0;
    
    m_Eyerotation[X_VALUE] = 0.0;
    m_Eyerotation[Y_VALUE] = 0.0;
    m_Eyerotation[Z_VALUE] = 0.0;
}

-(void)execute
{
    [self interpolateEye];
    GLfloat white[] = {1.0,1.0,1.0,1.0};
    GLfloat black[] = {0.0,0.0,0.0,0.0};
    
    double yawrad = (M_PI*m_Eyerotation[Y_VALUE])/180;
    double pitchrad = (M_PI*m_Eyerotation[X_VALUE])/180;
    double rollrad = M_PI*m_Eyerotation[Z_VALUE]/180;
    
    double tanpitchrad;
    if(pitchrad>M_PI*2)
        pitchrad-=M_PI*2;
    if(pitchrad<0)
        pitchrad+=M_PI*2;
    if(pitchrad > M_PI*.5 && pitchrad < M_PI*3/2.0){
        tanpitchrad = tanf(pitchrad);
        yawrad -= M_PI;
    }
    else
        tanpitchrad = -tanf(pitchrad);
    
    GLfloat origin[4] = {0.0,0.0,0.0,1.0};

    glMatrixMode(GL_PROJECTION);
    glPushMatrix();

    gluLookAt(m_Eyeposition[X_VALUE], m_Eyeposition[Y_VALUE], m_Eyeposition[Z_VALUE],
              -sinf(yawrad), tanpitchrad, cosf(yawrad),
              cosf(yawrad)*( -sinf(rollrad)/fabsf(1/cosf(pitchrad)) ),cosf(rollrad)*1/cosf(pitchrad), sinf(yawrad)*( -sinf(rollrad)/fabsf(1/cosf(pitchrad)) ) );
    //              -sinf(rollrad),cosf(rollrad)*1/cosf(pitchrad),0);   // FIRST moment I was doing this right, only rolls if pointed along the +x axis instead of the z, or -x.
    //              -sinf(rollrad),-1*((switchFlag*2)-1)*cosf(rollrad),0);
    //              sinf(rollrad)*sinf(yawrad),1*cosf(rollrad),sinf(rollrad)*cosf(yawrad));
    //              -sinf(rollrad)*sinf(pitchrad), cosf(rollrad), -sinf(rollrad)*cosf(pitchrad));
    
//    glTranslatef(-m_Eyeposition[X_VALUE], -m_Eyeposition[Y_VALUE], -m_Eyeposition[Z_VALUE]);
    glMaterialfv(GL_FRONT_AND_BACK, GL_EMISSION, white);
    
    [self executeSphere:m_CelestialSphere inverted:YES];
    glPopMatrix();
    
    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();
    glMaterialfv(GL_FRONT_AND_BACK, GL_EMISSION, black);
    glLightfv(GL_LIGHT0, GL_POSITION, origin);
    glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, white);
    glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, white);  //Still effects things after glPushMatrix
    
    for(Parabola *parabola in parabolae){
        [self executeSphere:[parabola sphere] inverted:NO];
        for(Square *dust in [parabola particleTrail])
            [self executeSquare:dust];
    }
    for(Line *line in lines){
        [self executeSquare:[line square]];
    }
    glMatrixMode(GL_PROJECTION);
    glPopMatrix();
}

#pragma mark- target objects

-(void) rainbowIncoming{
    NSLog(@"Rainbow Ship Incoming");
}

-(void) parabolaIncoming{
    Parabola *parabola = [[Parabola alloc] init];
    [parabola setDistance:8];
    [parabola setAngle:arc4random()%628318/100000.0];
    NSLog(@"Parabola Incoming ANGLE: %f",[parabola angle]);
    [parabola setPositionX:[parabola distance]*sinf([parabola angle]) Y:0 Z:[parabola distance]*cosf([parabola angle])];
    [parabolae addObject:parabola];

    [self incrementTarget:@0];
}

-(void)incrementTarget:(NSNumber*)count{ 
    BOOL alive = false;
    for(Parabola *parabola in parabolae){
        if([parabola completed] > 0){
            if([count integerValue]%4 == 0)
                [[parabola particleTrail] addObject:[self targetMakeCloudX:[parabola getX] Y:[parabola getY] Z:[parabola getZ]]];
            [parabola increment];
            alive = true;
        }
    }
    if(alive)
        [self performSelector:@selector(incrementTarget:) withObject:[NSNumber numberWithInteger:[count integerValue]+1] afterDelay:1.0/60];

}

-(void) lineIncoming{
    Line *line = [[Line alloc] init];
    [line setDistance:8];
    [line setAngle:arc4random()%628318/100000.0];
    NSLog(@"Line Incoming ANGLE: %f",[line angle]);
    [line setPositionX:[line distance]*sinf([line angle]) Y:0 Z:[line distance]*cosf([line angle])];
    [lines addObject:line];
    
    [self incrementLine:@0];
}

-(void)incrementLine:(NSNumber*)count{
    BOOL alive = false;
    for(Line *line in lines){
        if([line completed] > 0){
            if([count integerValue]%1 == 0)
                [[line square] swapTexture:@"4-spiral-large-1.png"];
//            if([count integerValue]%4 == 0)
//                [[line particleTrail] addObject:[self targetMakeCloudX:[parabola getX] Y:[parabola getY] Z:[parabola getZ]]];
            [line increment];
            alive = true;
        }
    }
    if(alive)
        [self performSelector:@selector(incrementLine:) withObject:[NSNumber numberWithInteger:[count integerValue]+1] afterDelay:1.0/60];
}


-(Square*)targetMakeCloudX:(GLfloat)x Y:(GLfloat)y Z:(GLfloat)z{
    Square *dust = [[Square alloc] initWithSize:0.03];
    [dust setPositionX:x+arc4random()%100/1000.0-.05 Y:y+arc4random()%100/1000.0-.05 Z:z+arc4random()%100/1000.0-.05];
    return dust;
}

-(void)executeSphere:(Sphere *)sphere inverted:(BOOL)inverted{
    GLfloat posX, posY, posZ;
    glPushMatrix();
    [sphere getPositionX:&posX Y:&posY Z:&posZ];
    glTranslatef(posX, posY, posZ);
    if(inverted)
        [sphere executeInverted];
    else
        [sphere execute];
    glPopMatrix();
}

-(void)executeSquare:(Square *)square{
    GLfloat posX, posY, posZ;
    glPushMatrix();
    [square getPositionX:&posX Y:&posY Z:&posZ];
    glTranslatef(posX, posY, posZ);
    [square execute];
    glPopMatrix();
}

-(void) buildEyeInterpolationVectorFromNewX:(GLfloat)x Y:(GLfloat)y Z:(GLfloat)z{
    m_EyeInterpolationVector[X_VALUE] = (m_Eyerotation[X_VALUE]-x);
    m_EyeInterpolationVector[Y_VALUE] = (m_Eyerotation[Y_VALUE]-y);
    m_EyeInterpolationVector[Z_VALUE] = (m_Eyerotation[Z_VALUE]-z);
}
-(void) setEyeX:(GLfloat)x Y:(GLfloat)y Z:(GLfloat)z{
    m_Eyeposition[X_VALUE] = x;
    m_Eyeposition[Y_VALUE] = y;
    m_Eyeposition[Z_VALUE] = z;
}
-(void) setEyeRotationX:(GLfloat)x Y:(GLfloat)y Z:(GLfloat)z{
    m_EyeInterpolationVector[X_VALUE] = (x-m_Eyerotation[X_VALUE])/2.0;
    m_EyeInterpolationVector[Y_VALUE] = (y-m_Eyerotation[Y_VALUE])/2.0;
    m_EyeInterpolationVector[Z_VALUE] = (z-m_Eyerotation[Z_VALUE])/2.0;
}
-(void)interpolateEye{
    m_Eyerotation[X_VALUE] += m_EyeInterpolationVector[X_VALUE];
    m_Eyerotation[Y_VALUE] += m_EyeInterpolationVector[Y_VALUE];
    m_Eyerotation[Z_VALUE] += m_EyeInterpolationVector[Z_VALUE];
}

@end