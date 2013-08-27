//
//  Square.m
//  Invaders
//
//  Created by Robby on 8/25/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import "Square.h"

@interface Square (){
    GLfloat m_Pos[3];
    NSInteger alpha;
    GLfloat length;
}

@end

@implementation Square

-(id) initWithSize:(GLfloat)s{
    self = [super init];
    m_Pos[0] = 0.0;
    m_Pos[1] = 0.0;
    m_Pos[2] = 0.0;
    length = s;
    return self;
}

-(void)setAlpha:(NSInteger)a{
    alpha = a;
}
-(NSInteger)getAlpha{
    return alpha;
}
-(void) execute
{
    GLfloat squareVertices[8] = {
        -length, -length,
        length, -length,
        -length, length,
        length, length};
    GLubyte squareColors[16] = {
        255, 255,   0, 255,
          0, 255, 255, 255,
          0,   0,   0,   0,
        255,   0, 255, 255};
    
    squareColors[3] = squareColors[7] = squareColors[15] = alpha;

    glMatrixMode(GL_MODELVIEW);
    glDisable(GL_CULL_FACE);
    
    glEnableClientState(GL_NORMAL_ARRAY);
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
    
    glEnable(GL_TEXTURE_2D);
    
    
    glVertexPointer(2, GL_FLOAT, 0, squareVertices);
    glEnableClientState(GL_VERTEX_ARRAY);
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, squareColors);
    
    glPushMatrix();
    glRotatef(atan2f(m_Pos[2], m_Pos[0]), 0, 1, 0);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glPopMatrix();
    glDisable(GL_BLEND);
    glDisable(GL_TEXTURE_2D);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);

}


-(void)swapTexture:(NSString*)textureFile{
//    GLuint name = m_TextureInfo.name;
//    glDeleteTextures(1, &name);
//    m_TextureInfo = [self loadTexture:textureFile];
}

-(void) getPositionX:(GLfloat *)x Y:(GLfloat *)y Z:(GLfloat *)z
{
    *x = m_Pos[0];
    *y = m_Pos[1];
    *z = m_Pos[2];
}

-(void) setPositionX:(GLfloat)x Y:(GLfloat)y Z:(GLfloat)z
{
    m_Pos[0] = x;
    m_Pos[1] = y;
    m_Pos[2] = z;
}

@end