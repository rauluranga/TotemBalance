//
//  BlockCircle.m
//  TotemBalance
//
//  Created by Raúl Uranga on 7/6/11.
//  Copyright 2011 GrupoW. All rights reserved.
//

#import "BlockCircle.h"
#import "GameScene.h"

@implementation BlockCircle

-(void) dealloc
{
	[super dealloc];
}

-(id) initWithPosition: (CGPoint)pos theGame:(GameLayer *) game
{
	if ((self = [super init])) {
		self.theGame = game;
		[game addChild:self z:1];
		
		mySprite = [CCSprite spriteWithFile:@"block_circ.png"];
		[mySprite setPosition:pos];
		
		[game addChild:mySprite z:1];
		
		myBody = cpBodyNew(1.0f,cpMomentForCircle(1, 16, 16, CGPointZero));
		myBody->p = pos;
		myBody->data = self;
		
		cpSpaceAddBody(game.space, myBody);
		
		myShape	= cpCircleShapeNew(myBody, 16, CGPointZero);
		myShape->e = 0.5;
		myShape->u = 0.5;
		myShape->data = mySprite;
		myShape->collision_type = 3;
		
		cpSpaceAddShape(game.space, myShape);
		
	}
	
	return self;
}


@end
