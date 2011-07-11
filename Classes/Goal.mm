//
//  Goal.m
//  TotemBalance
//
//  Created by Raúl Uranga on 7/6/11.
//  Copyright 2011 GrupoW. All rights reserved.
//

#import "Goal.h"
#import "GameScene.h"

@implementation Goal

@synthesize mySprite;
@synthesize theGame;
@synthesize myBody;
@synthesize myShape;

-(id) initWithPosition: (CGPoint)pos theGame:(GameLayer *) game
{
	if ((self = [super init])) {
		self.theGame = game;
		[game addChild:self z:1];
		
		mySprite = [CCSprite spriteWithFile:@"goal.png"];
		[mySprite setPosition:pos];
		
		[game addChild:mySprite z:1];
		
		int num = 4;
		CGPoint verts[] = 
		{
			ccp(-55.5,-13.5),
			ccp(-55.5,13.5),
			ccp(55.5,13.5),
			ccp(55.5,-13.5),		
		};
		
		myBody = cpBodyNew(1.0f,cpMomentForPoly(1.0f, num, verts, CGPointZero));
		myBody->p = pos;
		myBody->data = self;
		
		cpSpaceAddBody(game.space, myBody);
		
		myShape	= cpPolyShapeNew(myBody, num, verts, CGPointZero);
		myShape->e = 0.5;
		myShape->u = 0.5;
		myShape->data = mySprite;
		myShape->group = 4;
		myShape->collision_type = 4;
		
		cpSpaceAddShape(game.space, myShape);
		
	}
	
	return self;
}


@end
