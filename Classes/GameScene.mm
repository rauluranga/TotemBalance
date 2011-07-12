//
//  HelloWorldScene.m
//  TotemBalance
//
//  Created by Raúl Uranga on 7/6/11.
//  Copyright GrupoW 2011. All rights reserved.
//


// Import the interfaces
#import "GameScene.h"
#import "BlockRectangle.h"
#import "BlockTriangle.h"
#import "BlockCircle.h"
#import "OFHighScoreService.h"
#import "OFAchievement.h"

enum {
	kTagBatchNode = 1,
};

static void
eachShape(void *ptr, void* unused)
{
	cpShape *shape = (cpShape*) ptr;
	CCSprite *sprite = (CCSprite *) shape->data;
	if( sprite ) {
		cpBody *body = shape->body;
		
		// TIP: cocos2d and chipmunk uses the same struct to store it's position
		// chipmunk uses: cpVect, and cocos2d uses CGPoint but in reality the are the same
		// since v0.7.1 you can mix them if you want.		
		[sprite setPosition: body->p];
		
		[sprite setRotation: (float) CC_RADIANS_TO_DEGREES( -body->a )];
	}
}


static int
loseGame(cpArbiter *arb, cpSpace *space, void *data)
{
	CP_ARBITER_GET_SHAPES(arb,a,b);
	
	//The above macro "generates" 2 structs for us (a and b) which are the 2 shapes that collided.
	//We can retrieve their bodies from them and then their "data"	
	//property which we set to be the actual instance of the class.
	
	//Totem *t = (Totem *) a->body->data;
	
	//GameLayer *game = (GameLayer *) data;
	
	//We know the "a" struct will always represent the Totem
	//and the struct "b" will always represent the Goal
	//because that is the order we pass those 2 object's groups
	//in the cpSpaceCollisionHandler function.
	
	CCScene *gs = [GameLayer scene];
	[[CCDirector sharedDirector] replaceScene:gs];
	
	return 0;
}

static int
startCounting(cpArbiter *arb, cpSpace *space, void *data)
{
	CP_ARBITER_GET_SHAPES(arb,a,b);
	
	GameLayer *game = (GameLayer *) data;
	
	[game schedule:@selector(winCount) interval:1];
	
	return 1;
}

static void
stopCounting(cpArbiter *arb, cpSpace *space, void *data)
{
	
	CP_ARBITER_GET_SHAPES(arb,a,b);
	
	GameLayer *game = (GameLayer *) data;
	
	[game unschedule:@selector(winCount)];
	
	game.secondsForGoal = 0;
	
	NSLog(@"SEPARATED");
	
}


// HelloWorld implementation
@implementation GameLayer


@synthesize goal;
@synthesize totem;
@synthesize space;
@synthesize touchableBlocks;
@synthesize secondsForGoal;

-(void) dealloc
{
	[touchableBlocks release];
	[super dealloc];
}

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameLayer *layer = [GameLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id) init
{
	if( (self=[super init])) {
		
		self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = YES;
		
		CGSize wins = [[CCDirector sharedDirector] winSize];
		
		cpInitChipmunk();
		
		cpBody *staticBody = cpBodyNew(INFINITY, INFINITY);
		space = cpSpaceNew();
		cpSpaceResizeStaticHash(space, 400.0f, 40);
		cpSpaceResizeActiveHash(space, 100, 600);
		
		space->gravity = ccp(0, -200);
		space->elasticIterations = space->iterations;
		
		cpShape *shape;
		
		// bottom
		shape = cpSegmentShapeNew(staticBody, ccp(0,0), ccp(wins.width,0), 0.0f);
		shape->e = 1.0f; shape->u = 1.0f;
		shape->collision_type = 2;
		cpSpaceAddStaticShape(space, shape);
		
		// left
        shape = cpSegmentShapeNew(staticBody, ccp(0,0), ccp(0,wins.height), 0.0f);
        shape->e = 1.0f; shape->u = 1.0f;
        cpSpaceAddStaticShape(space, shape);
		
        // right
        shape = cpSegmentShapeNew(staticBody, ccp(wins.width,0), ccp(wins.width,wins.height), 0.0f);
        shape->e = 1.0f; shape->u = 1.0f;
        cpSpaceAddStaticShape(space, shape);
		
		
		totem = [[Totem alloc] initWithPosition:ccp(160,340) theGame:self];
		
		goal = [[Goal alloc] initWithPosition:ccp(160,25) theGame:self];
		
		touchableBlocks = [[NSMutableArray alloc] init];
		for (int i = 0; i<5; i++) {
			BlockRectangle * b = [[BlockRectangle alloc] initWithPosition:ccp(160,50 + 50 * i) theGame:self];
			[touchableBlocks addObject:b];
			[b release];
		}
		
		for (int i = 0; i<5; i++) {
			BlockTriangle * b = [[BlockTriangle alloc] initWithPosition:ccp(80,50 + 50 * i) theGame:self];
			[touchableBlocks addObject:b];
			[b release];
		}
		
		for (int i = 0; i<5; i++) {
			BlockCircle * b = [[BlockCircle alloc] initWithPosition:ccp(240 + 10 * i,50 + 50 * i) theGame:self];
			[touchableBlocks addObject:b];
			[b release];
		}
		
		
		cpSpaceAddCollisionHandler(space, 1, 2, NULL, loseGame, NULL, NULL, self);
		
		cpSpaceAddCollisionHandler(space, 1, 4, startCounting, NULL, NULL, stopCounting, self);
		
		
		[self schedule: @selector(step:)];

		[self initializeOpenfeint];
		
		[self schedule:@selector(countTimePassed) interval:1];
		
		
		CCMenuItemFont *newgame_item = [CCMenuItemFont itemFromString: @"SCORES" target:self selector:@selector(gameScores)];
		
		CCMenu *menu = [CCMenu menuWithItems:newgame_item,nil];
		[menu setPosition:ccp(50,450)];
		
		[self addChild:menu];
		
		
	}
	
	return self;
}

-(void) onEnter
{
	[super onEnter];
}

-(void) step: (ccTime) delta
{
	int steps = 2;
	CGFloat dt = delta/(CGFloat)steps;
	
	for(int i=0; i<steps; i++){
		cpSpaceStep(space, dt);
	}
	cpSpaceHashEach(space->activeShapes, &eachShape, nil);
	cpSpaceHashEach(space->staticShapes, &eachShape, nil);
}

-(void) winCount
{
	secondsForGoal ++;
	
	NSLog(@"Seconds passed: %d", secondsForGoal);
	
	if (secondsForGoal > 5) {
		
		NSLog(@"WON!!!");
		
		[self unschedule:@selector(winCount)];
		
		secondsForGoal = 0;
		
		[OFHighScoreService setHighScore:timePassed forLeaderboard:@"823036" onSuccess:OFDelegate() onFailure:OFDelegate()];
		
		[self unschedule:@selector(countTimePassed)];
		
	}
}


-(void) countTimePassed
{
	timePassed++;
}

-(void) checkRemainingBlocks
{
	if ([touchableBlocks count] == 0) {
		
		//deprecated
		//[OFAchievementService uunlockAchievement:@"1084202"];
		
		NSLog(@"unlocked Janitor Achievement!!!");
		
		//With OpenFeint SDK 2.7+ try:
		//The following example shows how to unlock an achievement completely in one step without bothering to show a notification
		[[OFAchievement achievement: @"1084202"] updateProgressionComplete: 100.0f andShowNotification: YES];
		

	}
}

-(void) gameScores
{
	[OpenFeint launchDashboardWithHighscorePage:(NSString*)@"823036"];
}

#pragma mark-
#pragma mark Openfeint handlers

-(void) initializeOpenfeint
{
	NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:UIInterfaceOrientationPortrait], OpenFeintSettingDashboardOrientation,
							  @"Totem",OpenFeintSettingShortDisplayName,
							  [NSNumber numberWithBool:YES], OpenFeintSettingEnablePushNotifications,
							  [NSNumber numberWithBool:YES], OpenFeintSettingDisableUserGeneratedContent, nil];
	
	
	[OpenFeint initializeWithProductKey:@"8LvOxAOfgry5CEUrOvxuIg" andSecret:@"9OOQgb6W4p5TNbX36Z6DQvjahdo4qYzju9rcciQmhs" andDisplayName:@"Totem" andSettings:settings andDelegates:
	[OFDelegatesContainer containerWithOpenFeintDelegate:self andChallengeDelegate:nil andNotificationDelegate:self]];
	
	//[OpenFeint launchDashboard];
	//[OpenFeint launchDashboardWithListLeaderboardsPage];
	//OpenFeint.LaunchDashboard(OpenFeint.eDashboardPage.Leaderboards);
	//[OpenFeint launchDashboardWithHighscorePage:(NSString*)@"823036"];

}


-(void) dashboardWillAppear
{
	[[CCDirector sharedDirector] pause];
}


-(void) dashboardDidDisappear
{
	[[CCDirector sharedDirector] resume];
}










@end
