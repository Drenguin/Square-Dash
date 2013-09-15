//
//  HelloWorldLayer.h
//  Square Dash
//
//  Created by Patrick Mc Gartoll on 7/21/13.
//  Copyright Drenguin 2013. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "DRPlayerSprite.h"

// HelloWorldLayer
@interface GameLayer : CCLayer 
{
    
    CCLabelTTF *scoreLabel;
    CCSprite *ground;
    DRPlayerSprite *player;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
