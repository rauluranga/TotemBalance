//
//  TouchableBlock.m
//  TotemBalance
//
//  Created by Raúl Uranga on 7/6/11.
//  Copyright 2011 GrupoW. All rights reserved.
//

#import "TouchableBlock.h"
#import "GameScene.h"


@implementation TouchableBlock

@synthesize mySprite;
@synthesize theGame;
@synthesize myBody;
@synthesize myShape;
@synthesize state;

-(void) dealloc
{
	[super dealloc];
}

-(id) init 
{
	if ((self=[super init])) {
		self.state = kStateUngrabbed;
	}
	return self;
}

@end
