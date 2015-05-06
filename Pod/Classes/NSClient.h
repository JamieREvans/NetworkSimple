//
//  NSClient.h
//  NetworkSimple
//
//  Created by Jamie Evans on 2015-01-14.
//  Copyright (c) 2015 Jamie Evans. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSConstants.h"

@interface NSClient : NSObject

@property (nonatomic) NSString *scheme, *host;
@property (nonatomic) NSURLRequestCachePolicy cachingPolicy;
@property (nonatomic) NSTimeInterval requestTimeout;
@property (nonatomic) NSString *boundaryString;

// This block is called when the request returns a 401
// The block should return YES if it would like to handle the response itself
// The block should return NO if it would like the original callback to fire normally with a 401
// The block will be fired on the background thread
@property (nonatomic, copy) NSResponseChallengeHandler authenticationFailureHandler;

+ (instancetype)clientWithScheme:(NSString *)scheme andHost:(NSString *)host;

- (void)sendRequest:(NSMutableURLRequest *)request withResponseCallback:(NSResponseCallback)callback;

// All in one method
- (void)sendRequestWithEndpoint:(NSString *)endpoint
                 httpMethodType:(NSHTTPMethodType)httpMethodType
                    requestType:(NSRequestType)requestType
                     dataObject:(id <NSObject>)dataObject
           requestMutationBlock:(NSURLRequestMutationBlock)requestMutationBlock
                    andCallback:(NSResponseCallback)callback;

@end