//
//  NSConstants.h
//  NetworkSimple
//
//  Created by Jamie Evans on 2015-01-14.
//  Copyright (c) 2015 Jamie Evans. All rights reserved.
//

#ifndef NetworkSimple_NSConstants_h
#define NetworkSimple_NSConstants_h

extern NSString * const kContentLengthKey;
extern NSString * const kContentTypeKey;

extern NSString * const kHTTPMethodGet;
extern NSString * const kHTTPMethodPost;
extern NSString * const kHTTPMethodPut;
extern NSString * const kHTTPMethodDelete;

extern NSString * const kContentTypeData;
extern NSString * const kContentTypeJSON;
extern NSString * const kContentTypeMultipart;

extern NSString * const kResponseHeadersKey;
extern NSString * const kResponseHeadersNotification;

typedef void(^NSResponseCallback)(NSUInteger statusCode, id responseObject, NSError *error);
typedef BOOL(^NSResponseChallengeHandler)(NSUInteger statusCode, id responseObject, NSMutableURLRequest *originalRequest, NSResponseCallback originalCallback, NSError *error);
// Used for mutating NSMutableURLRequest before firing
typedef void(^NSURLRequestMutationBlock)(NSMutableURLRequest *request);

typedef NS_ENUM(NSUInteger, NSRequestType)
{
    NSRequestTypeURL = 0,
    NSRequestTypeData,
    NSRequestTypeJSON,
    NSRequestTypeMultipart
};

typedef NS_ENUM(NSUInteger, NSHTTPMethodType)
{
    NSHTTPMethodTypeGet = 0,
    NSHTTPMethodTypePost,
    NSHTTPMethodTypePut,
    NSHTTPMethodTypeDelete
};

#endif
