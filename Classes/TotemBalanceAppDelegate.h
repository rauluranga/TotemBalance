//
//  TotemBalanceAppDelegate.h
//  TotemBalance
//
//  Created by Raúl Uranga on 7/6/11.
//  Copyright GrupoW 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface TotemBalanceAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
