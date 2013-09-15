//
//  HelloWorldLayer.m
//  Square Dash
//
//  Created by Patrick Mc Gartoll on 7/21/13.
//  Copyright Drenguin 2013. All rights reserved.
//


// Import the interfaces
#import "GameLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#define SPIKE_GROUND_OBSTACLE 0
#define CIRCLE_GROUND_OBSTACLE 1

#define GRAVITY 0.1f

#define DASH_SPEED 15.0f
#define REGULAR_SPEED 4.0f

#define RUN_ANIMATION_TAG 0
#define DASH_ANIMATION_TAG 1

#pragma mark - GameLayer

// HelloWorldLayer implementation
@implementation GameLayer

CGPoint firstTouch;
CGPoint lastTouch;

float obstacleReloadWaitTime;
float obstacleReloadTimer;

float grassReloadWaitTime;
float grassReloadTimer;

float dashWaitTime;
float dashTimer;

float score;

BOOL gameOver;

NSMutableArray *obstacles;

//Not very descriptive, holds stuff other than obstacles just can't think of the word for it right now
NSMutableArray *otherStuff;

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
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

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        self.touchEnabled = YES;
        
        gameOver = NO;
        
        obstacleReloadWaitTime = 2.0f;
        obstacleReloadTimer = 0.0f;
        
        grassReloadWaitTime = 1.5f;
        grassReloadTimer = 0.0f;
        
        dashWaitTime = 0.5f;
        dashTimer = 0.0f;
        
        score = 0.0f;
        
        obstacles = [[NSMutableArray alloc] init];
        otherStuff  = [[NSMutableArray alloc] init];
        
        CCLayerColor *blueSky = [[CCLayerColor alloc] initWithColor:ccc4(102, 178, 255, 255)];
        
        scoreLabel = [CCLabelTTF labelWithString:@"0" fontName:@"Trebuchet MS" fontSize:15.0f];
        scoreLabel.position = ccp(winSize.width/2,winSize.height-15);
        
		ground = [CCSprite spriteWithFile:@"ground.png"];
        ground.position = ccp(winSize.width/2,30);
        
        player = [DRPlayerSprite spriteWithFile:@"squareHero.png"];
        player.position = ccp(40,60+30);
        player.xVelocity = REGULAR_SPEED;
        player.yVelocity = 0.0f;
        player.isOnGround = YES;
        player.canDash = YES;
        player.isDashing = YES;
        
        [self runRunningAnimation];
        
        [self createGrassAtX:200 andY:40];
        
        [self addChild:blueSky z:-2];
        [self addChild:ground z:-1];
        [self addChild:player];
        [self addChild:scoreLabel z:2];
        
        [self schedule:@selector(tick:)];
	}
	return self;
}

-(void)tick:(ccTime)t
{
    if(!gameOver) {
        score += t*2.0f;
        [scoreLabel setString:[NSString stringWithFormat:@"%.0f",score]];
        
        obstacleReloadTimer+=t;
        grassReloadTimer+=t;
        
        ccTime timeConstant = t*60.0f;
        
        //Time to spawn a new obstacle
        if(obstacleReloadTimer>obstacleReloadWaitTime) {
            int rand = arc4random()%2;
            if(rand==0) {
                [self createObstacleOfType:SPIKE_GROUND_OBSTACLE];
            } else if(rand==1) {
                [self createObstacleOfType:CIRCLE_GROUND_OBSTACLE];
            }
            obstacleReloadTimer = 0.0f;
        }
        
        //Time to create new grass
        if(grassReloadTimer>grassReloadWaitTime) {
            [self createGrassAtX:500 andY:arc4random()%10+20];
            grassReloadTimer = 0.0f;
            grassReloadWaitTime = 0.5+(arc4random()%10)/10.0f;
        }
        
        //Dash logic
        if(player.isDashing) {
            dashTimer+=t;
            if(dashTimer>dashWaitTime) {
                [self stopDashing];
            }
        }
        
        //Apply gravity and stuff
        [self updatePlayer:timeConstant];
        
        //Delete stuff too far off screen and update positions of stuff
        [self updateScreen:timeConstant];
        
        //Check for hits!
        [self checkForCollisions];
    } else {
        [player stopAllActions];
        NSLog(@"Game Over!");
        [self unschedule:@selector(tick:)];
    }
}

-(void) checkForCollisions
{
    for(int i = 0; i < [obstacles count]; i++) {
        CCSprite *o = [obstacles objectAtIndex:i];
        if(CGRectIntersectsRect(CGRectInset(player.boundingBox, 2.0f, 2.0f), o.boundingBox)) {
            if(player.isDashing) {
                if(o.tag==CIRCLE_GROUND_OBSTACLE) {
                    
                } else {
                    gameOver = YES;
                }
            } else {
                gameOver = YES;
            }
        }
    }
}

-(void) createGrassAtX:(int)x andY:(int)y
{
    CCSprite *grass = [CCSprite spriteWithFile:@"grass2.png"];
    grass.position = ccp(x,y);
    [self addChild:grass z:1];
    [otherStuff addObject:grass];
}

-(void) createObstacleOfType:(int)type
{
    if(type == SPIKE_GROUND_OBSTACLE) {
        CCSprite *obstacle = [CCSprite spriteWithFile:@"spike.png"];
        obstacle.position = ccp(480+[obstacle boundingBox].size.width/2, 60+[obstacle boundingBox].size.height/2);
        [self addChild:obstacle];
        obstacle.tag = type;
        [obstacles addObject:obstacle];
    } else if(type == CIRCLE_GROUND_OBSTACLE) {
        CCSprite *obstacle = [CCSprite spriteWithFile:@"circleEnemy.png"];
        obstacle.position = ccp(480+[obstacle boundingBox].size.width/2, 60+[obstacle boundingBox].size.height/2);
        [self addChild:obstacle];
        obstacle.tag = type;
        [obstacles addObject:obstacle];
    } else {
        NSLog(@"Not obstacle of that type!");
    }
}

-(void) runRunningAnimation
{
    CCAnimation *run = [CCAnimation animation];
    [run addSpriteFrameWithFilename:@"squareHero1.png"];
    [run addSpriteFrameWithFilename:@"squareHero2.png"];
    [run addSpriteFrameWithFilename:@"squareHero3.png"];
    run.delayPerUnit = 0.2f;
    
    CCAction *runningAnim = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:run]];
    runningAnim.tag = RUN_ANIMATION_TAG;
    
    [player runAction:runningAnim];
}

//Make that character jump! or float.
-(void) jump
{
    if(player.isOnGround) {
        player.yVelocity = 4.0f;
        player.isOnGround = NO;
    }
}

//duck or squish or plummet to ground
-(void) duck
{
    if(player.isOnGround == NO) {
        [self stopDashing];
        player.yVelocity = -8.0f;
    }
}

-(void) runDuckAnimation
{
    CCAnimation *duck = [CCAnimation animation];
    [duck addSpriteFrameWithFilename:@"squareHeroDuck1.png"];
    duck.delayPerUnit = 0.2f;
    
    CCAction *duckingAnim = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:duck]];
    duckingAnim.tag = DASH_ANIMATION_TAG;
    [player runAction:duckingAnim];
}

-(void) dash
{
    if(player.canDash) {
        player.isDashing = YES;
        player.xVelocity = DASH_SPEED;
        player.canDash = NO;
        
        //Actions should only be for animation, it is possible for a jumping animation so just stop all for now
        [player stopAllActions];
        [self runDashAnimation];
    }
}

-(void) runDashAnimation
{
    CCAnimation *dash = [CCAnimation animation];
    [dash addSpriteFrameWithFilename:@"squareHeroDash.png"];
    dash.delayPerUnit = 0.2f;
    
    CCAction *dashingAnim = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:dash]];
    dashingAnim.tag = DASH_ANIMATION_TAG;
    [player runAction:dashingAnim];
}

-(void) stopDashing
{
    player.isDashing = NO;
    dashTimer = 0.0f;
    player.xVelocity = REGULAR_SPEED;
    
    [player stopActionByTag:DASH_ANIMATION_TAG];
    [self runRunningAnimation];
    
    //Player shouldn't keep moving up after dashing
    player.yVelocity = 0.0f;
}

-(void) updatePlayer:(ccTime)timeConstant
{
    //Currently this only messes with the y so if the player is dashing don't change the players y velocity or position!
    if(!player.isDashing) {
        CGPoint goToPosition = player.position;
        player.yVelocity -= GRAVITY*timeConstant;
        goToPosition.y += player.yVelocity*timeConstant;
        if(goToPosition.y<90) {
            goToPosition.y = 90;
            player.yVelocity = 0.0f;
            player.isOnGround = YES;
            player.canDash = YES;
        }
        
        player.position = goToPosition;
    }
}

-(void) updateScreen:(ccTime) timeConstant
{
    NSMutableArray *toRemove = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < [obstacles count]; i++) {
        CCSprite *o = [obstacles objectAtIndex:i];
        o.position = ccp(o.position.x - player.xVelocity*timeConstant, o.position.y);
        
        //If the position is far enough left remove the object
        if(o.position.x < -100) [toRemove addObject:o];
    }
    
    //Remove all obstacles that need to be removed
    for(int i = 0; i < [toRemove count]; i++) {
        CCSprite *o = [toRemove objectAtIndex:i];
        [obstacles removeObject:o];
        [self removeChild:o cleanup:YES];
    }
    
    
    //Reset the array
    [toRemove removeAllObjects];
    
    for(int i = 0; i < [otherStuff count]; i++) {
        CCSprite *o = [otherStuff objectAtIndex:i];
        o.position = ccp(o.position.x - player.xVelocity*timeConstant, o.position.y);
        
        if(o.position.x < -100) [toRemove addObject:o];
    }
    
    for(int i = 0; i < [toRemove count]; i++) {
        CCSprite *o = [toRemove objectAtIndex:i];
        [otherStuff removeObject:o];
        [self removeChild:o cleanup:YES];
    }
    
    //RELEASE THE KRAKEN (removal array)
    [toRemove release];
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    firstTouch = location;
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    lastTouch = location;
    
    float swipeLength = ccpDistance(firstTouch, lastTouch);
    
    //Check if the swipe is long enough and the user is swiping in y direction
    if(swipeLength>40) {
        if(abs(lastTouch.y-firstTouch.y)>abs(lastTouch.x-firstTouch.x)) {
            if(lastTouch.y>firstTouch.y) {
                [self jump];
            } else if(lastTouch.y<firstTouch.y) {
                [self duck];
            }
        } else if(abs(lastTouch.x-firstTouch.x)>abs(lastTouch.y-firstTouch.y)) {
            if(lastTouch.x>firstTouch.x) {
                [self dash];
            }
        }
    }
}

//Might not need touches ended because of shtuff
/*-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    lastTouch = location;
    
    //Minimum length of the swipe
    float swipeLength = ccpDistance(firstTouch, lastTouch);
    
    //Check if the swipe is long enough and the user is swiping in y direction
    if(swipeLength>30 && (abs(lastTouch.y-firstTouch.y)>abs(lastTouch.x-firstTouch.x))) {
        if(lastTouch.y>firstTouch.y) {
            [self jump];
        } else if(lastTouch.y<firstTouch.y) {
            [self duck];
        }
    }
    
}*/

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
    [obstacles release];
    [otherStuff release];
    
	// don't forget to call "super dealloc"
	[super dealloc];
}

@end
