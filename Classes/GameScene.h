//
//  HelloWorldScene.m
//  TotemBalance
//
//  Created by Raúl Uranga on 7/6/11.
//  Copyright GrupoW 2011. All rights reserved.
//

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// Importing Chipmunk headers
#import "chipmunk.h"
#import "Totem.h"
#import "Goal.h"

// HelloWorld Layer
@interface GameLayer : CCLayer
{
	cpSpace *space;
	Totem *totem;
	Goal *goal;
}

@property (nonatomic, retain) Goal *goal;
@property (nonatomic, retain) Totem *totem;
@property (nonatomic, readwrite) cpSpace *space;




// returns a Scene that contains the HelloWorld as the only child
+(id) scene;
-(void) step: (ccTime) dt;
//-(void) addNewSpriteX:(float)x y:(float)y;

@end
