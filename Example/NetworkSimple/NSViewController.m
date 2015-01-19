//
//  NSViewController.m
//  NetworkSimple
//
//  Created by Jamie Evans on 01/14/2015.
//  Copyright (c) 2014 Jamie Evans. All rights reserved.
//

#import "NSViewController.h"
#import <NetworkSimple/NSClient.h>

@interface NSViewController ()

@end

@implementation NSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSClient *client = [NSClient clientWithScheme:@"http" andHost:@"randomuser.me"];
    
    [client setRequestTimeout:10.0f];
    
    [client setCachingPolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
    
    [client setBoundaryString:@"myBoundaryStringForThisApplication"];
    
    [client sendRequestWithEndpoint:@""
                     httpMethodType:NSHTTPMethodTypeGet
                        requestType:NSRequestTypeURL
                         dataObject:nil
               requestMutationBlock:nil
                        andCallback:^(NSUInteger statusCode, id responseObject, NSError *error)
     {
         if(statusCode == 200)
         {
             // Received users!
             // responseObject should contain an NSArray of user objects
         }
         else if(error)
         {
             // Display alert with error message
         }
     }];
    
    [client sendRequestWithEndpoint:@""
                     httpMethodType:NSHTTPMethodTypePost
                        requestType:NSRequestTypeJSON
                         dataObject:@{@"firstName"   : @"Jamie",
                                      @"lastName"    : @"Evans",
                                      @"phoneNumber" : @"555-555-5555"}
               requestMutationBlock:^(NSMutableURLRequest *request)
     {
         [request setValue:@"cbeiqu829fPamfr12adkjln" forHTTPHeaderField:@"client_token"];
         [request setTimeoutInterval:10.0f];
     }
                        andCallback:^(NSUInteger statusCode, id responseObject, NSError *error)
     {
         if(statusCode == 200)
         {
             // Created a user successfully!
         }
         else if(error)
         {
             // Failed to create a user :(
         }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
