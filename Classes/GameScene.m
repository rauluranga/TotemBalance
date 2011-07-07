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

enum {
	kTagBatchNode = 1,
};

static void
eachShape(void *ptr, void* unused)
{
	cpShape *shape = (cpShape*) ptr;
	CCSprite *sprite = shape->data;
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
	
	Totem *t = (Totem *) a->body->data;
	
	GameLayer *game = (GameLayer *) data;
	
	CCScene *gs = [GameLayer scene];
	[[CCDirector sharedDirector] replaceScene:gs];
	
	return 0;
}


// HelloWorld implementation
@implementation GameLayer


@synthesize goal;
@synthesize totem;
@synthesize space;
@synthesize touchableBlocks;

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

/*/
-(void) addNewSpriteX: (float)x y:(float)y
{
	int posx, posy;
	
	CCSpriteBatchNode *batch = (CCSpriteBatchNode*) [self getChildByTag:kTagBatchNode];
	
	posx = (CCRANDOM_0_1() * 200);
	posy = (CCRANDOM_0_1() * 200);
	
	posx = (posx % 4) * 85;
	posy = (posy % 3) * 121;
	
	CCSprite *sprite = [CCSprite spriteWithBatchNode:batch rect:CGRectMake(posx, posy, 85, 121)];
	[batch addChild: sprite];
	
	sprite.position = ccp(x,y);
	
	int num = 4;
	CGPoint verts[] = {
		ccp(-24,-54),
		ccp(-24, 54),
		ccp( 24, 54),
		ccp( 24,-54),
	};
	
	cpBody *body = cpBodyNew(1.0f, cpMomentForPoly(1.0f, num, verts, CGPointZero));
	
	// TIP:
	// since v0.7.1 you can assign CGPoint to chipmunk instead of cpVect.
	// cpVect == CGPoint
	body->p = ccp(x, y);
	cpSpaceAddBody(space, body);
	
	cpShape* shape = cpPolyShapeNew(body, num, verts, CGPointZero);
	shape->e = 0.5f; shape->u = 0.5f;
	shape->data = sprite;
	cpSpaceAddShape(space, shape);
	
}
//*/

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
		
		/*/
		// top
		shape = cpSegmentShapeNew(staticBody, ccp(0,wins.height), ccp(wins.width,wins.height), 0.0f);
		shape->e = 1.0f; shape->u = 1.0f;
		cpSpaceAddStaticShape(space, shape);
		
		// left
		shape = cpSegmentShapeNew(staticBody, ccp(0,0), ccp(0,wins.height), 0.0f);
		shape->e = 1.0f; shape->u = 1.0f;
		cpSpaceAddStaticShape(space, shape);
		
		// right
		shape = cpSegmentShapeNew(staticBody, ccp(wins.width,0), ccp(wins.width,wins.height), 0.0f);
		shape->e = 1.0f; shape->u = 1.0f;
		cpSpaceAddStaticShape(space, shape);
		//*/
		
		//CCSpriteBatchNode *batch = [CCSpriteBatchNode batchNodeWithFile:@"grossini_dance_atlas.png" capacity:100];
		//[self addChild:batch z:0 tag:kTagBatchNode];
		
		//[self addNewSpriteX: 200 y:200];
		
		
		cpSpaceAddCollisionHandler(space, 1, 2, NULL, loseGame, NULL, NULL, self);
		
		
		[self schedule: @selector(step:)];
	}
	
	return self;
}

-(void) onEnter
{
	[super onEnter];
	
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / 60)];
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


- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	/*/
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		
		location = [[CCDirector sharedDirector] convertToGL: location];
		
		[self addNewSpriteX: location.x y:location.y];
	}
	//*/
}

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{	
	/*/
	static float prevX=0, prevY=0;
	
#define kFilterFactor 0.05f
	
	float accelX = (float) acceleration.x * kFilterFactor + (1- kFilterFactor)*prevX;
	float accelY = (float) acceleration.y * kFilterFactor + (1- kFilterFactor)*prevY;
	
	prevX = accelX;
	prevY = accelY;
	
	CGPoint v = ccp( accelX, accelY);
	
	space->gravity = ccpMult(v, 200);
	//*/
}
@end
