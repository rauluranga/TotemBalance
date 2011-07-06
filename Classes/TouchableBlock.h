//
//  TouchableBlock.h
//  TotemBalance
//
//  Created by Raúl Uranga on 7/6/11.
//  Copyright 2011 GrupoW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "chipmunk.h"

typedef enum tagState
{
	kStateGrabbed,
	kStateUngrabbed
} touchState;

@class GameLayer;

@interface TouchableBlock : CCNode <CCTargetedTouchDelegate> {
	CCSprite *mySprite;
	cpBody *myBody;
	cpShape *myShape;
	GameLayer *theGame;
	touchState state;
	
}

@property (nonatomic, retain) CCSprite *mySprite;
@property (nonatomic, retain) GameLayer *theGame;
@property (nonatomic, readwrite) cpBody *myBody;
@property (nonatomic, readwrite) cpShape *myShape;
@property (nonatomic, readwrite) touchState state;;


@end
