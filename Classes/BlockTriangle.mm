//
//  BlockTriangle.m
//  TotemBalance
//
//  Created by Raúl Uranga on 7/6/11.
//  Copyright 2011 GrupoW. All rights reserved.
//

#import "BlockTriangle.h"
#import "GameScene.h"

@implementation BlockTriangle

-(void) dealloc
{
	[super dealloc];
}

-(id) initWithPosition: (CGPoint)pos theGame:(GameLayer *) game
{
	if ((self = [super init])) {
		self.theGame = game;
		[game addChild:self z:1];
		
		mySprite = [CCSprite spriteWithFile:@"block_tri.png"];
		[mySprite setPosition:pos];
		
		[game addChild:mySprite z:1];
		
		int num = 3;
		CGPoint verts[] = 
		{
			ccp(0,15),
			ccp(16,-15),
			ccp(-16,-15),
		};
		
		myBody = cpBodyNew(1.0f,cpMomentForPoly(1.0f, num, verts, CGPointZero));
		myBody->p = pos;
		myBody->data = self;
		
		cpSpaceAddBody(game.space, myBody);
		
		myShape	= cpPolyShapeNew(myBody, num, verts, CGPointZero);
		myShape->e = 0.5;
		myShape->u = 0.5;
		myShape->data = mySprite;
		myShape->collision_type = 3;
		
		cpSpaceAddShape(game.space, myShape);
		
	}
	
	return self;
}

@end
