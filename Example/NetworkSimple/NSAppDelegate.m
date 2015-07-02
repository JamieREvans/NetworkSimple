//
//  NSAppDelegate.m
//  NetworkSimple
//
//  Created by CocoaPods on 01/14/2015.
//  Copyright (c) 2014 Jamie Evans. All rights reserved.
//

#import "NSAppDelegate.h"

@implementation NSAppDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    NSLog(@"%@", [[[NSURL alloc] initWithScheme:@"http" host:@"google.ca" path:@"/api"] URLByAppendingPathComponent:@"?jamie=NO"].absoluteString);
}

@end
