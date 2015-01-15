//
//  NSConstants.h
//  NetworkSimple
//
//  Created by Jamie Evans on 2015-01-14.
//  Copyright (c) 2015 Jamie Evans. All rights reserved.
//

#ifndef NetworkSimple_NSConstants_h
#define NetworkSimple_NSConstants_h

NSString * const kContentLengthKey;
NSString * const kContentTypeKey;

NSString * const kHTTPMethodGet;
NSString * const kHTTPMethodPost;
NSString * const kHTTPMethodPut;
NSString * const kHTTPMethodDelete;

NSString * const kContentTypeData;
NSString * const kContentTypeJSON;
NSString * const kContentTypeMultipart;

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
