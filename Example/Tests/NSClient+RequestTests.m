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

describe(@"When creating a request with parameters", ^
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

describe(@"When getting content types", ^{
    
    it(@"should return x-www-form-urlencoded for NSRequestTypeData", ^{
        
        [[[[NSClient new] contentTypeWithRequestType:NSRequestTypeData] should] equal:kContentTypeData];
    });
    
    it(@"should return application/json for NSRequestTypeJSON", ^{
        
        [[[[NSClient new] contentTypeWithRequestType:NSRequestTypeJSON] should] equal:kContentTypeJSON];
    });
    
    it(@"should return a multitype boundary for NSRequestTypeMultipart", ^{
        
        NSClient *client = [NSClient new];
        [[[client contentTypeWithRequestType:NSRequestTypeMultipart] should] equal:[NSString stringWithFormat:@"%@; boundary=%@", kContentTypeMultipart, client.boundaryString]];
    });
    
    it(@"should return nil for an invalid NSRequestType", ^{
        
        [[[[NSClient new] contentTypeWithRequestType:100] should] beNil];
    });
});

describe(@"When getting http methods", ^{
    
    it(@"should return GET for NSHTTPMethodGet", ^{
        
        [[[[NSClient new] httpMethodFromType:NSHTTPMethodTypeGet] should] equal:kHTTPMethodGet];
    });
    
    it(@"should return POST for NSHTTPMethodTypePost", ^{
        
        [[[[NSClient new] httpMethodFromType:NSHTTPMethodTypePost] should] equal:kHTTPMethodPost];
    });
    
    it(@"should return PUT for NSHTTPMethodTypePut", ^{
        
        [[[[NSClient new] httpMethodFromType:NSHTTPMethodTypePut] should] equal:kHTTPMethodPut];
    });
    
    it(@"should return DELETE for NSHTTPMethodDelete", ^{
        
        [[[[NSClient new] httpMethodFromType:NSHTTPMethodTypeDelete] should] equal:kHTTPMethodDelete];
    });
    
    it(@"should return nil for an invalid NSHTTPMethodType", ^{
        
        [[[[NSClient new] httpMethodFromType:100] should] beNil];
    });
});

SPEC_END