//
//  NSConstants.h
//  NetworkSimple
//
//  Created by Jamie Evans on 2015-01-14.
//  Copyright (c) 2015 Jamie Evans. All rights reserved.
//

#ifndef NetworkSimple_NSConstants_h
#define NetworkSimple_NSConstants_h

static NSString * const kContentLengthKey = @"Content-Length";
static NSString * const kContentTypeKey   = @"Content-Type";

NSString * const kHTTPMethodGet    = @"GET";
NSString * const kHTTPMethodPost   = @"POST";
NSString * const kHTTPMethodPut    = @"PUT";
NSString * const kHTTPMethodDelete = @"DELETE";

NSString * const kContentTypeData      = @"x-www-form-urlencoded";
NSString * const kContentTypeJSON      = @"application/json";
NSString * const kContentTypeMultipart = @"multipart/form-data";

typedef void(^NSResponseCallback)(NSUInteger statusCode, id responseObject, NSError *error);
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
