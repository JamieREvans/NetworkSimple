//
//  NSClientTests.m
//  NetworkSimple
//
//  Created by Jamie Evans on 2015-01-14.
//  Copyright (c) 2015 Jamie Evans. All rights reserved.
//

#import <Kiwi.h>
#import <OCMock.h>
#import "NSClient+Parsing.h"
#import "NSClient+Request.h"

SPEC_BEGIN(NSClientSpec)

void (^stubSynchronousRequestWithStatusCodeAndURL)(NSUInteger statusCode, NSString *url) = ^(NSUInteger statusCode, NSString *url)
{
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:url]
                                                              statusCode:statusCode
                                                             HTTPVersion:@"HTTP/1.1"
                                                            headerFields:@{}];
    
    id connectionMock = OCMClassMock([NSURLConnection class]);
    OCMStub([connectionMock sendSynchronousRequest:[OCMArg any] returningResponse:(NSURLResponse * __autoreleasing *)[OCMArg setTo:response] error:(NSError * __autoreleasing *)[OCMArg anyPointer]]);
};

void (^stubSynchronousRequestWithStatusCodeAndURLAndResponseData)(NSUInteger statusCode, NSString *url, NSData *responseData) = ^(NSUInteger statusCode, NSString *url, NSData *responseData)
{
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:url]
                                                              statusCode:statusCode
                                                             HTTPVersion:@"HTTP/1.1"
                                                            headerFields:@{}];
    
    id connectionMock = OCMClassMock([NSURLConnection class]);
    OCMStub([connectionMock sendSynchronousRequest:[OCMArg any] returningResponse:(NSURLResponse * __autoreleasing *)[OCMArg setTo:response] error:(NSError * __autoreleasing *)[OCMArg anyPointer]])
    .andReturn(responseData);
};

describe(@"When allocating the client", ^{
    
    __block NSClient *client = nil;
    __block NSString *baseURL = nil;
    
    void (^sendRequestWithEndpointAndCallback)(NSString *endpoint, NSResponseCallback callback) = ^(NSString *endpoint, NSResponseCallback callback)
    {
        [client sendRequestWithEndpoint:endpoint
                         httpMethodType:NSHTTPMethodTypeGet
                            requestType:NSRequestTypeJSON
                             dataObject:nil
                   requestMutationBlock:nil
                            andCallback:callback];
    };
    
    beforeEach(^{
        
        client = [NSClient clientWithScheme:@"http" andHost:@"api.randomuser.me"];
        baseURL = [client urlWithEndpoint:@""].absoluteString;
    });
    
    it(@"the host and scheme should be set", ^{
        
        [[client.scheme should] equal:@"http"];
        [[client.host should] equal:@"api.randomuser.me"];
    });
    
    describe(@"and firing off a basic request", ^{
        
        __block id responseObject = nil;
        __block NSNumber *statusCode = nil;
        
        beforeEach(^{
            
            stubSynchronousRequestWithStatusCodeAndURLAndResponseData(200, baseURL, [NSJSONSerialization dataWithJSONObject:@{}
                                                                                                                    options:0
                                                                                                                      error:nil]);
            
            // Client request
            [client sendRequestWithEndpoint:[NSClient stringFromParameters:@{@"results" : @20}]
                             httpMethodType:NSHTTPMethodTypeGet
                                requestType:NSRequestTypeURL
                                 dataObject:nil
                       requestMutationBlock:nil
                                andCallback:^(NSUInteger _statusCode, id _responseObject, NSError *error)
             {
                 responseObject = _responseObject;
                 statusCode = @(_statusCode);
             }];
        });
        
        it(@"should return data and a status code", ^{
            
            [[expectFutureValue(responseObject) shouldEventuallyBeforeTimingOutAfter(0.5f)] beNonNil];
            [[expectFutureValue(statusCode) shouldEventuallyBeforeTimingOutAfter(0.5f)] beGreaterThan:@0];
        });
    });
    
    describe(@"and firing a request that gets redirected, but returns a 200 status code - potentially misconfigured firewall", ^{
        
        __block NSNumber *statusCode;
        
        beforeEach(^{
            
            stubSynchronousRequestWithStatusCodeAndURL(200, @"http://not-the-same-url.com");
            
            sendRequestWithEndpointAndCallback(@"", ^(NSUInteger responseStatusCode, id responseObject, NSError *error)
             {
                 
                 statusCode = @(responseStatusCode);
             });
        });
        
        it(@"should set the status code to 303", ^{
            
            [[expectFutureValue(statusCode) shouldEventuallyBeforeTimingOutAfter(0.5f)] equal:@(303)];
        });
    });
    
    describe(@"and setting an authentication handler that can handle authentication challenges", ^{
        
        __block NSNumber *authenticationBlockCalled;
        
        beforeEach(^{
            
            authenticationBlockCalled = @NO;
            
            [client setAuthenticationFailureHandler:^BOOL (NSUInteger statusCode, id responseObject, NSURLRequest *originalRequest, NSResponseCallback originalCallback, NSError *error)
             {
                 authenticationBlockCalled = @YES;
                 
                 return YES;
             }];
        });
        
        describe(@"when a request returns 401", ^{
            
            __block NSNumber *statusCode;
            __block NSNumber *callbackCalled;
            
            beforeEach(^{
                
                callbackCalled = @NO;
                
                stubSynchronousRequestWithStatusCodeAndURL(401, @"http://someurl.com");
                
                sendRequestWithEndpointAndCallback(@"", ^(NSUInteger responseStatusCode, id responseObject, NSError *error)
                 {
                     callbackCalled = @YES;
                     statusCode = @(responseStatusCode);
                 });
            });
            
            it(@"should not call the callback", ^{
                
                [[expectFutureValue(callbackCalled) shouldEventuallyBeforeTimingOutAfter(0.5f)] equal:@NO];
            });
            
            it(@"should have called the authentication handler", ^{
                
                [[expectFutureValue(authenticationBlockCalled) shouldEventuallyBeforeTimingOutAfter(0.5f)] equal:@YES];
            });
        });
        
        describe(@"when a request returns 200", ^{
            
            __block NSNumber *statusCode;
            __block NSNumber *callbackCalled;
            
            beforeEach(^{
                
                callbackCalled = @NO;
                
                stubSynchronousRequestWithStatusCodeAndURL(200, baseURL);
                
                sendRequestWithEndpointAndCallback(@"", ^(NSUInteger responseStatusCode, id responseObject, NSError *error)
                                                   {
                                                       callbackCalled = @YES;
                                                       statusCode = @(responseStatusCode);
                                                   });
            });
            
            it(@"should have called the callback", ^{
                
                [[expectFutureValue(callbackCalled) shouldEventuallyBeforeTimingOutAfter(0.5f)] equal:@YES];
            });
            
            it(@"should not have called the authentication handler", ^{
                
                [[expectFutureValue(authenticationBlockCalled) shouldEventuallyBeforeTimingOutAfter(0.5f)] equal:@NO];
            });
        });
    });
});

SPEC_END