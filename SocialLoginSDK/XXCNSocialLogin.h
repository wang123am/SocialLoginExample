//
//  XXCNSocialLogin.h
//  SocialLogin
//
//  Created by wang yan on 14-7-29.
//  Copyright (c) 2014年 AiXiang. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WeiboSDK.h"
#import <TencentOpenAPI/TencentOAuth.h>

typedef enum
{
    SocialType_QQ,
    SocialType_SINA
} SocialType;

@interface XXCNSocialLogin : NSObject<WeiboSDKDelegate,WBHttpRequestDelegate,TencentSessionDelegate>

+(XXCNSocialLogin *)sharedManager;

-(void)loginSinaWeiBo;
- (void)loginQQ;

-(BOOL)handleOpenURL:(NSURL *)url;

@end
