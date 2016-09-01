//
//  DRGConnectionManager.m
//  GraphicsEditor
//
//  Created by Светлана Медоева on 8/27/16.
//  Copyright © 2016 Светлана Медоева. All rights reserved.
//

#import "DRGConnectionManager.h"

NSString *const kDRGURLPath = @"http://localhost:8000";
NSString *const kDRGPathForUser = @"user";
NSString *const kDRGPathForDocument = @"document";
NSString *const kDRGPOSTMethod = @"POST";
NSString *const kDRGGETMethod = @"GET";
NSString *const kDRGDELETEMethod = @"DELETE";
NSString *const kDRHTTPHeaderField = @"Content-Type";
NSString *const kDRRequestValue = @"application/json";
NSString *const kDRGActionLogin = @"login";
NSString *const kDRGActionRegistration = @"registration";
NSString *const kDRGIdentifierUsername = @"username";
NSString *const kDRGIdentifierPassword = @"password";
NSString *const kDRGIdentifierApikey = @"apikey";
NSString *const kDRGIdentifierName = @"name";
NSString *const kDRGIdentifierID = @"id";

@implementation DRGConnectionManager

- (BOOL)getAppkeyWithUsername:(NSString *)username password:(NSString *)password atAction:(NSString *)action completionHandler:(void (^)(NSString *, NSString *))block
{
    __block NSString *apikey = nil;
    NSError*error = nil;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/%@", kDRGURLPath, kDRGPathForUser, action]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:username, kDRGIdentifierUsername,
                                password, kDRGIdentifierPassword,
                                nil];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    [dictionary release];
    [request setHTTPMethod:kDRGPOSTMethod];
    [request addValue:kDRRequestValue forHTTPHeaderField:kDRHTTPHeaderField];
    [request setHTTPBody:data];
    
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate:nil delegateQueue: [NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [defaultSession dataTaskWithRequest:request completionHandler:^(NSData * data, NSURLResponse * response, NSError * error)
                                  {
                                      NSString *strError = nil;
                                      NSHTTPURLResponse * resp= (NSHTTPURLResponse *)response;
                                      if (error || resp.statusCode != 200)
                                      {
                                          NSLog(@"%s: Error: %@", __FUNCTION__, error);
                                      }
                                      else
                                      {
                                          NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                                                     options:NSJSONReadingMutableContainers
                                                                                                       error:&error];
                                          if ([dictionary isKindOfClass:[NSDictionary class]] && error == nil)
                                          {
                                              if (dictionary[@"error"] == nil)
                                              {
                                                  if (dictionary[@"apikey"] && [dictionary[@"apikey"] isKindOfClass:[NSString class]])
                                                  {
                                                      apikey = dictionary[@"apikey"];
                                                  }
                                              }
                                              else
                                              {
                                                  strError = dictionary[@"error"];
                                              }
                                          }
                                          else NSLog(@"NSJSONSerialization error: %@", error);
                                      }
                                      block(apikey, strError);
                                  }];
    [task resume];
    return true;
}

- (void)uploadDocumentWithImage:(NSImage *)image name:(NSString *)name documentData:(NSURL *)documentData apikey:(NSString *)apikey completionHandler:(void (^)(NSString *))block
{
    NSError *error = nil;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kDRGURLPath, kDRGPathForDocument]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:kDRGPOSTMethod];

    NSString *boundary = @"---------------------------Boundary Line---------------------------";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    NSMutableData *body = [NSMutableData data];
    
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:apikey, kDRGIdentifierApikey,
                                image.name, kDRGIdentifierName,
                                nil];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    if (error)
    {
        NSLog(@"%@", error);
    }
    else
    {
        
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"apikey"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", apikey] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"name"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@", name] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"image\"; filename=\"%@.jpg\"\r\n", image.name] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[NSData dataWithData:image.TIFFRepresentation]];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"document\"; filename=\"%@.drg\"\r\n", image.name] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[NSData dataWithContentsOfURL: documentData]];
        [body appendData:[NSData dataWithData:data]];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [request setHTTPBody:body];
        [request addValue:[NSString stringWithFormat:@"%lu", [body length]] forHTTPHeaderField:@"Content-Length"];
        
        NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate:nil delegateQueue: [NSOperationQueue mainQueue]];
        
        NSURLSessionDataTask *task = [defaultSession dataTaskWithRequest:request completionHandler:^(NSData * data, NSURLResponse * response, NSError * error)
                                      {
                                          NSString *strError = nil;
                                          NSHTTPURLResponse * resp= (NSHTTPURLResponse *)response;
                                          if (error || resp.statusCode != 200)
                                          {
                                              NSLog(@"%@", error);
                                          }
                                          else if (data.length)
                                          {
                                              NSDictionary *respDict = [NSJSONSerialization JSONObjectWithData:data
                                                                                                       options:NSJSONReadingMutableContainers
                                                                                                         error:&error];
                                              
                                              if (respDict && [respDict isKindOfClass:[NSDictionary class]] && error == nil)
                                              {
                                                  if (respDict[@"error"] != nil)
                                                  {
                                                      strError = respDict[@"error"];
                                                  }
                                              }
                                              else if (error)
                                              {
                                                  NSLog(@"NSJSONSerialization error: %@", error);
                                              }
                                              
                                          }
                                          block(strError);
                                      }
                                      ];
        [task resume];

    }
    [dictionary release];
}

- (void)getDocumentsWithApikey:(NSString *)apikey completionHandler:(void (^)(NSArray *, NSString *))block
{
    __block NSArray *array = nil;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kDRGURLPath, kDRGPathForDocument]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:kDRGGETMethod];
    [request addValue:kDRRequestValue forHTTPHeaderField:kDRHTTPHeaderField];
    [request addValue:apikey forHTTPHeaderField:@"apikey"];
    
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate:nil delegateQueue: [NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [defaultSession dataTaskWithRequest:request completionHandler:^(NSData * data, NSURLResponse * response, NSError * error)
                                  {
                                      NSString *strError = nil;
                                      NSHTTPURLResponse * resp= (NSHTTPURLResponse *)response;
                                      if (error || resp.statusCode != 200)
                                      {
                                          NSLog(@"%s: Error: %@", __FUNCTION__, error);
                                      }
                                      else
                                      {
                                          NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                                                     options:NSJSONReadingMutableContainers
                                                                                                       error:&error];
                                          if ([dictionary isKindOfClass:[NSDictionary class]] && error == nil)
                                          {
                                              if (dictionary[@"error"] == nil)
                                              {
                                                  if (dictionary[@"array"] && [dictionary[@"array"] isKindOfClass:[NSArray class]])
                                                  {
                                                      array = dictionary[@"array"];
                                                  }
                                              }
                                              else
                                              {
                                                  strError = dictionary[@"error"];
                                              }
                                          }
                                          else NSLog(@"NSJSONSerialization error: %@", error);
                                      }
                                      block(array, strError);
                                  }];
    [task resume];
}

- (void)downloadByURL:(NSURL *)url apikey:(NSString *)apikey withName:(NSString *)name completionHandler:(void (^)(NSString *))block
{
    if (apikey)
    {
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDownloadTask *task = [session downloadTaskWithURL:url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error)
        {
            NSString *strError = nil;
            NSHTTPURLResponse * resp= (NSHTTPURLResponse *)response;
            if (error || resp.statusCode != 200)
            {
                NSLog(@"Download error: %@", error);
                strError = @"Download failed!";
            }
            else
            {
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSURL *newLocation = [NSURL fileURLWithPathComponents:@[paths[0], name]];
                [[NSFileManager defaultManager] moveItemAtURL:location toURL:newLocation error:&error];
                if (error)
                {
                    strError = @"Download failed!";
                }
                else
                {
                    strError = [NSString stringWithFormat:@"%@ was saved in Document directory", name];
                }
            }
            block(strError);
        }];
        [task resume];
    }
    
}

- (void)deleteFileWithID:(NSInteger)ID apikey:(NSString *)apikey name:(NSString *)name completionHandler:(void (^)(NSString *))block
{
    NSError*error = nil;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kDRGURLPath, kDRGPathForDocument]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:apikey, kDRGIdentifierApikey,
                                [NSNumber numberWithInteger:ID], kDRGIdentifierID,
                                nil];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    if (error)
    {
        NSLog(@"%@", error);
    }
    else
    {
        [request setHTTPMethod:kDRGDELETEMethod];
        [request addValue:kDRRequestValue forHTTPHeaderField:kDRHTTPHeaderField];
        [request setHTTPBody:data];
        
        NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate:nil delegateQueue: [NSOperationQueue mainQueue]];
        
        NSURLSessionDataTask *task = [defaultSession dataTaskWithRequest:request completionHandler:^(NSData * data, NSURLResponse * response, NSError * error)
                                      {
                                          NSString *strError = nil;
                                          NSHTTPURLResponse * resp= (NSHTTPURLResponse *)response;
                                          if (error || resp.statusCode != 200)
                                          {
                                              strError = @"Delete action failed";
                                          }
                                          else
                                          {
                                              strError = [NSString stringWithFormat:@"%@ was successfully removed", name];
                                          }
                                          block(strError);
                                      }];
        [task resume];
    }
    [dictionary release];
}

@end
