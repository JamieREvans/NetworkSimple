//
//  NSClientTests.m
//  NetworkSimple
//
//  Created by Jamie Evans on 2015-01-14.
//  Copyright (c) 2015 Jamie Evans. All rights reserved.
//

#import "Kiwi.h"
#import "NSClient+Request.h"

SPEC_BEGIN(NSClientRequestSpec)

describe(@"When creating a request for the root", ^
{
    __block NSClient *client = [NSClient clientWithScheme:@"http" andHost:@"randomuser.me"];
    __block NSURL *requestURL = nil;
    __block NSMutableURLRequest *request = nil;
    
    beforeEach(^
               {
                   requestURL = [client urlWithEndpoint:@""];
                   request = [client requestWithURL:requestURL httpMethod:@"GET"];
               });
    
    it(@"the request url should have the suffix '/'", ^
       {
           [[requestURL.absoluteString should] endWithString:@"/"];
       });
    
    it(@"the request should have the correct setup", ^
       {
           [[request.URL.absoluteString should] endWithString:@"/"];
           [[request.HTTPMethod should] equal:@"GET"];
       });
    
    it(@"the request should be mutable", ^
       {
           [[request should] beKindOfClass:[NSMutableURLRequest class]];
       });
});

describe(@"When creating a test with parameters", ^
{
    __block NSClient *client = [NSClient clientWithScheme:@"http" andHost:@"randomuser.me"];
    __block NSURL *requestURL = nil;
    __block NSMutableURLRequest *request = nil;
    
    beforeEach(^
               {
                   requestURL = [client urlWithEndpoint:@"" andParameters:@{@"results" : @"20",
                                                                            @"seed"    : @"NS"}];
                   request = [client requestWithURL:requestURL httpMethod:@"GET"];
               });
    
    it(@"the request url should have the suffix '/?results=20&seed=NS'", ^
       {
           [[requestURL.absoluteString should] endWithString:@"/?results=20&seed=NS"];
       });
});

SPEC_END