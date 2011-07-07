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

-(CGRect)rect
{
	CGRect c = CGRectMake(self.mySprite.position.x - (self.mySprite.textureRect.size.width/2) * self.mySprite.scaleX,
						  self.mySprite.position.y - (self.mySprite.textureRect.size.height/2) * self.mySprite.scaleY,
						  self.mySprite.textureRect.size.width * self.mySprite.scaleX,
						  self.mySprite.textureRect.size.height * self.mySprite.scaleY);
	return c;
}

-(void) onEnter
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
	[super onEnter];
}

-(void) onExit
{
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[super onExit];
}

- (BOOL)containsTouchLocation:(UITouch *)touch
{
	return CGRectContainsPoint(self.rect, [self convertTouchToNodeSpaceAR:touch]);
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	if (state != kStateUngrabbed) {
		return NO;
	}
	if (![self containsTouchLocation:touch]) {
		return NO;
	}
	
	CGPoint location = [touch locationInView: [touch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
	
	state = kStateGrabbed;
	
	return YES;
}


- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	NSAssert(state == kStateGrabbed,@"Unexpected state");
	
	CGPoint location = [touch locationInView: [touch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
	
	cpSpaceRemoveBody(theGame.space, myBody);
	cpSpaceRemoveShape(theGame.space, myShape);
	
	cpBodyFree(myBody);
	cpShapeFree(myShape);
	
	[theGame removeChild:mySprite cleanup:YES];
	[theGame removeChild:self cleanup:YES];
	
	[theGame.touchableBlocks removeObject:self];
	
	state = kStateUngrabbed;
	
}


















@end
