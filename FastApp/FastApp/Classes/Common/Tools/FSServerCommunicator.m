//
//  FSServerCommunicator.m
//  FastApp
//
//  Created by tangkunyin on 16/3/7.
//  Copyright © 2016年 www.shuoit.net. All rights reserved.
//

#import "FSServerCommunicator.h"
#import "AFNetworking.h"

@interface FSServerCommunicator ()
@property (nonatomic, strong) AFHTTPSessionManager *manager;
@end

@implementation FSServerCommunicator

- (void)doGetWithUrl:(NSString *)url
             respObj:(Class)obj
          completion:(void (^)(BOOL success,id respData))completion;
{
    if (url) {
        [self.manager GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self handleResponse:responseObject Resp:obj completion:completion];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [MBProgressHUD loadding:NO];
            [MBProgressHUD handleErrorWithCode:@(error.code) additional:task.response];
        }];
    }
}

- (void)doPostWithUrl:(NSString *)url
                param:(NSDictionary *)param
              respObj:(Class)obj
           completion:(void (^)(BOOL success,id respData))completion;
{
    if (url) {
        [self.manager POST:url parameters:param progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self handleResponse:responseObject Resp:obj completion:completion];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [MBProgressHUD loadding:NO];
            [MBProgressHUD handleErrorWithCode:@(error.code) additional:task.response];
        }];
    }
}

- (void)doGetWithUri:(NSString *)uri
               param:(id)param
             respObj:(Class)obj
             useSign:(BOOL)sign
          completion:(void (^)(BOOL success,id respData))completion;
{
    NSString *url = [self urlWithUri:uri params:param];
    if (url) {
        if (sign) {
            //加密规则...
            
        }
        [self doGetWithUrl:url respObj:obj completion:completion];
    }
}

- (void)doPostWithUri:(NSString *)uri
                param:(id)param
              respObj:(Class)obj
              useSign:(BOOL)sign
           completion:(void (^)(BOOL success,id respData))completion;
{
    NSString *url = [self urlWithUri:uri params:param];
    if (url) {
        if (sign) {
            //加密规则...
            
        }
        [self doPostWithUrl:url param:param respObj:obj completion:completion];
    }
}

- (void)uploadFileWithUrl:(NSString *)url
                     file:(NSData *)fileData
                     name:(NSString *)fileName
                  respObj:(Class)obj
               completion:(void (^)(BOOL success,id respData))completion
{
    NSString *finalUrl = [self urlWithUri:url params:nil];
    if (finalUrl) {
        [self.manager POST:finalUrl parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            [formData appendPartWithFileData:fileData name:fileName fileName:fileName mimeType:@"image/jpg"];
        } progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self handleResponse:responseObject Resp:obj completion:completion];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [MBProgressHUD loadding:NO];
            [MBProgressHUD handleErrorWithCode:@(error.code) additional:task.response];
        }];
    }
}

#pragma mark - response handler
- (void)handleResponse:(id)responseObject
                  Resp:(Class)ObjType
            completion:(void (^)(BOOL success,id respData))completion;
{
    [MBProgressHUD loadding:NO];
    @try{
        id resultData;
        if ([responseObject isKindOfClass:[NSString class]]) {
            resultData = responseObject;
        }
        if([responseObject isKindOfClass:[NSData class]]){
            NSString *originString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            if (originString && [NSJSONSerialization isValidJSONObject:originString]) {
                resultData = [NSJSONSerialization JSONObjectWithData:[originString dataUsingEncoding:NSUTF8StringEncoding]
                                                             options:NSJSONReadingMutableLeaves
                                                               error:nil];
            }else{
                resultData = originString;
            }
        }
        if (resultData) {
            id data = (nil == ObjType) ? resultData : [ObjType mj_objectWithKeyValues:resultData];
            completion((nil == data) ? NO : YES,data);
            return;
        }
        [MBProgressHUD handleErrorWithCode:@(HttpStatusReturnNullCode) additional:nil];
    }@catch(NSException *excep){
        [MBProgressHUD showError:@"数据解析异常"];
        log(excep.reason)
    }
}

- (NSString *)urlWithUri:(NSString *)uri params:(id)params
{
    NSString *urlPrefix = [GlobalCache sharedInstance].appServerUrl;
    NSString *url = [NSString stringWithFormat:@"%@%@",urlPrefix,uri];
    
    NSMutableString *mUrl = [NSMutableString stringWithString:url];
    if ([params isKindOfClass:[NSString class]]) {
        [mUrl appendString:params];
    }
    if ([params isKindOfClass:[NSDictionary class]]) {
        [mUrl appendString:[StringTools paramStringFromDict:params]];
    }
    log(mUrl)
    
    return mUrl;
}

#pragma mark - getter
- (AFHTTPSessionManager *)manager
{
    if (!_manager) {
        _manager = [AFHTTPSessionManager manager];
        _manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _manager.requestSerializer.timeoutInterval = SERVER_CONNECT_TIMEOUT;
    }
    return _manager;
}


@end
