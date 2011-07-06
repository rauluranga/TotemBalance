//
//  Totem.h
//  TotemBalance
//
//  Created by Raúl Uranga on 7/6/11.
//  Copyright 2011 GrupoW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "chipmunk.h"

@class GameLayer;


@interface Totem : CCNode {
	CCSprite *mySprite;
	cpBody *myBody;
	cpShape *myShape;
	GameLayer *theGame;
}

@property (nonatomic, retain) CCSprite *mySprite;
@property (nonatomic, retain) GameLayer *theGame;
@property (nonatomic, readwrite) cpBody *myBody;
@property (nonatomic, readwrite) cpShape *myShape;


-(id) initWithPosition: (CGPoint)pos theGame:(GameLayer *) game;

@end
