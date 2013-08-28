//
//  Square.h
//  Invaders
//
//  Created by Robby on 8/25/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface Square : NSObject

-(id) initWithSize:(GLfloat)s;
-(void)execute;

-(void) getPositionX:(GLfloat *)x Y:(GLfloat *)y Z:(GLfloat *)z;
-(void) setPositionX:(GLfloat)x Y:(GLfloat)y Z:(GLfloat)z;
-(void) setAlpha:(NSInteger)a;
-(NSInteger) getAlpha;

-(void)swapTexture:(NSString*)textureFile;
-(GLKTextureInfo *)loadTexture:(NSString*)fileName;

@end
