# NetworkSimple

[![CI Status](https://travis-ci.org/JamieREvans/NetworkSimple.svg?style=flat)](https://travis-ci.org/JamieREvans/NetworkSimple)
[![Version](https://img.shields.io/cocoapods/v/NetworkSimple.svg?style=flat)](http://cocoadocs.org/docsets/NetworkSimple)
[![License](https://img.shields.io/cocoapods/l/NetworkSimple.svg?style=flat)](http://cocoadocs.org/docsets/NetworkSimple)
[![Platform](https://img.shields.io/cocoapods/p/NetworkSimple.svg?style=flat)](http://cocoadocs.org/docsets/NetworkSimple)
[![Coverage Status](https://coveralls.io/repos/JamieREvans/NetworkSimple/badge.svg)](https://coveralls.io/r/JamieREvans/NetworkSimple)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

NetworkSimple is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

	pod "NetworkSimple"

##How to Use

To use the library, start by importing the client

```objective-c
#import <NetworkSimple/NSClient.h>
```

To use the client, you'll have to start out with an instance

```objective-c
NSClient *client = [NSClient clientWithScheme:@"http" andHost:@"randomuser.me"];
```

To make a simple URL request, you can perform the following

```objective-c
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
```

For a more complicated request, lets send a POST request with JSON body data. We'll also set an HTTP header in the requestMutationBlock - this is always fired last in the request generation.

```objective-c
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
```

We can also update the default timeout intervals for our requests

```objective-c
[client setRequestTimeout:10.0f];
```

Or set the request caching policy

```objective-c
[client setCachingPolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
```

And if you're using multipart requests, you'll want to set the boundary string

```objective-c
[client setBoundaryString:@"myBoundaryStringForThisApplication"];
```

All of these properties can be overridden in the requestMutationBlock.

## Author

Jamie Evans, jamie.riley.evans@gmail.com

## License

NetworkSimple is available under the MIT license. See the LICENSE file for more info.

