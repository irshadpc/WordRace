//
//  wordraceAppDelegate_iPhone.m
//  wordrace
//
//  Created by Taha Selim Bebek on 7/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "wordraceAppDelegate_iPhone.h"
#import "WelcomeViewController_iPhone.h"
#import "Constants.h"
#import "DatabaseBuilderTVC.h"

@implementation wordraceAppDelegate_iPhone


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [super application:application didFinishLaunchingWithOptions:launchOptions];
    
    if (BUILDDATABASEMODE) 
    {
        DatabaseBuilderTVC* dtvc = [[DatabaseBuilderTVC alloc] initWithNibName:@"DatabaseBuilderTVC" bundle:nil];
        dtvc.managedObjectContext = self.managedObjectContext;
        dtvc.language = [LANGUAGE lowercaseString];
        UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:dtvc];
        self.window.rootViewController = navController;

    }
    else
    {
        application.statusBarHidden = YES;
        WelcomeViewController_iPhone* welcomeView = [[WelcomeViewController_iPhone alloc] initWithNibName:@"WelcomeViewController_iPhone" bundle:nil];
        welcomeView.managedObjectContext = self.managedObjectContext;
        UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:welcomeView];
        navController.navigationBarHidden = YES;
        self.window.rootViewController = navController;
    }
        
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)dealloc
{
	[super dealloc];
}

@end
