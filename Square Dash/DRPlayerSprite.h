//
//  DRPlayerSprite.h
//  Square Dash
//
//  Created by Patrick Mc Gartoll on 7/30/13.
//  Copyright 2013 Drenguin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface DRPlayerSprite : CCSprite {
    
}

@property (assign) float xVelocity;
@property (assign) float yVelocity;
@property (assign) BOOL isOnGround;
@property (assign) BOOL canDash;
@property (assign) BOOL isDashing;
@property (assign) BOOL isDucking;

@end