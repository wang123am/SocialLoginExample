//
//  XXCNSocialLogin.m
//  SocialLogin
//
//  Created by wang yan on 14-7-29.
//  Copyright (c) 2014年 AiXiang. All rights reserved.
//

#import "XXCNSocialLogin.h"

//新浪微博sdk的AppKey和RedirectURI
#define kAppKey         @"3949199214"
#define kRedirectURI    @"http://bizhi.sogou.com"

#define kWeiBoGetFansList       @"https://api.weibo.com/2/friendships/followers/active.json"
#define kWeiBoGetFocusList      @"https://api.weibo.com/2/friendships/friends.json"
#define kWeiBoGetUserInfo       @"https://api.weibo.com/2/users/show.json"

//QQ sdk的AppKey
#define QQAppKey        @"1101847253"

static XXCNSocialLogin *sharedManager=nil;

@implementation XXCNSocialLogin
{
    TencentOAuth *_tencentOAuth;
    NSArray *_permissions;
    
    //验证类型
    SocialType _type;
    
    //验证信息
    NSString *_token;
    NSString *_userID;
    NSDate *_expirationDate;
    
    //用户信息
    
}

+(XXCNSocialLogin *)sharedManager{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedManager=[[XXCNSocialLogin alloc] init];
    });
    return sharedManager;
}

-(id)init
{
    self=[super init];
    if (self) {
        [self initSinaWeiBo];
        [self initTencent];
    }
    return self;
}

- (void)loginSinaWeiBo
{
    _type=SocialType_SINA;
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = kRedirectURI;
    request.scope = @"all";
    request.userInfo = @{@"SSO_From": @"SendMessageToWeiboViewController",
                         @"Other_Info_1": [NSNumber numberWithInt:123],
                         @"Other_Info_2": @[@"obj1", @"obj2"],
                         @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};
    [WeiboSDK sendRequest:request];
}

- (void)loginQQ
{
    _type=SocialType_QQ;
    [_tencentOAuth authorize:_permissions inSafari:NO];
}

#pragma mark - 新浪微博接口请求
//请求用户信息
-(void)sinaWeiBoGetUseInfo
{
    NSString *urlStr=kWeiBoGetUserInfo;
    NSDictionary *param=[[NSDictionary alloc]initWithObjectsAndKeys:kAppKey,@"source",_token,@"access_token",_userID,@"uid" , nil];
    [WBHttpRequest requestWithAccessToken:_token url:urlStr httpMethod:@"GET" params:param delegate:self withTag:@"1"];
}
//请求优质粉丝列表
-(void)sinaWeiBoGetFansList
{
    NSString *urlStr=kWeiBoGetFansList;
    NSDictionary *param=[[NSDictionary alloc]initWithObjectsAndKeys:kAppKey,@"source",_token,@"access_token",_userID,@"uid" , nil];
    [WBHttpRequest requestWithAccessToken:_token url:urlStr httpMethod:@"GET" params:param delegate:self withTag:@"1"];
}
//请求关注列表
-(void)sinaWeiBoGetFocusList
{
    NSString *urlStr=kWeiBoGetFocusList;
    NSDictionary *param=[[NSDictionary alloc]initWithObjectsAndKeys:kAppKey,@"source",_token,@"access_token",_userID,@"uid" , nil];
    [WBHttpRequest requestWithAccessToken:_token url:urlStr httpMethod:@"GET" params:param delegate:self withTag:@"1"];
}


#pragma mark - WeiboDataParse

-(NSDictionary *)FocusParseDataFromJsonStr:(NSString *)jsonStr
{
    NSData *data=[jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *dataDic=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    NSNumber *total_number=[dataDic objectForKey:@"total_number"];
    NSArray *userList=[dataDic objectForKey:@"users"];
    NSMutableArray *userListResult=[[NSMutableArray alloc]init];
    for(NSDictionary *user in userList)
    {
        NSString *uid=[user objectForKey:@"id"];
        NSString *uname=[user objectForKey:@"name"];
        NSString *uscreenname=[user objectForKey:@"screen_name"];
        NSDictionary *dict=[[NSDictionary alloc]initWithObjectsAndKeys:uid,@"id",uname,@"name",uscreenname,@"uscreenname", nil];
        [userListResult addObject:dict];
    }
    NSDictionary *resultData=[[NSDictionary alloc]initWithObjectsAndKeys:total_number,@"total_number",userListResult,@"list", nil];
    return resultData;
}

-(NSDictionary *)FansParseDataFromJsonStr:(NSString *)jsonStr
{
    NSData *data=[jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *dataDict=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    NSArray *userList=[dataDict objectForKey:@"users"];
    NSNumber *total_number=[NSNumber numberWithInt:[userList count]];
    NSLog(@"total_number:%@",dataDict);
    NSMutableArray *userListResult=[[NSMutableArray alloc]init];
    for(NSDictionary *user in userList)
    {
        NSString *uid=[user objectForKey:@"id"];
        NSString *uname=[user objectForKey:@"name"];
        NSDictionary *dict=[[NSDictionary alloc]initWithObjectsAndKeys:uid,@"id",uname,@"name", nil];
        [userListResult addObject:dict];
    }
    NSDictionary *resultData=[[NSDictionary alloc]initWithObjectsAndKeys:total_number,@"total_number",userListResult,@"list", nil];
    return resultData;
}

-(NSDictionary *)UserInfoParseDataFromJsonStr:(NSString *)jsonStr
{
    NSData *data=[jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *dataDict=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    NSString *screen_name=[dataDict objectForKey:@"screen_name"];
    NSString *uname=[dataDict objectForKey:@"name"];
    //小头像
    //NSString *profile_image_url=[dataDict objectForKey:@"profile_image_url"];
    //大头像
    NSString *avatar_large=[dataDict objectForKey:@"avatar_large"];
    NSString *gender=[dataDict objectForKey:@"gender"];
    NSDictionary *resultData=[[NSDictionary alloc]initWithObjectsAndKeys:screen_name,@"screen_name",uname,@"uname",avatar_large,@"avatar_large",gender,@"gender", nil];
    return resultData;
}

#pragma mark - WeiboSDKDelegate

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    if ([request isKindOfClass:WBProvideMessageForWeiboRequest.class])
    {
        NSLog(@"didReceiveWeiboRequest:%@",request);
    }
}
- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if ([response isKindOfClass:WBSendMessageToWeiboResponse.class])
    {
        NSString *message = [NSString stringWithFormat:@"响应状态: %d\n响应UserInfo数据: %@\n原请求UserInfo数据: %@",(int)response.statusCode, response.userInfo, response.requestUserInfo];
        NSLog(@"message:%@",message);
        
    }
    else if ([response isKindOfClass:WBAuthorizeResponse.class])
    {
        /*
        NSString *message = [NSString stringWithFormat:@"响应状态: %d\nresponse.userId: %@\nresponse.accessToken: %@\n响应UserInfo数据: %@\n原请求UserInfo数据: %@",(int)response.statusCode,[(WBAuthorizeResponse *)response userID], [(WBAuthorizeResponse *)response accessToken], response.userInfo, response.requestUserInfo];
        NSLog(@"message:%@",message);
        */
        _token=[(WBAuthorizeResponse *)response accessToken];
        _userID=[(WBAuthorizeResponse *)response userID];
        _expirationDate=[(WBAuthorizeResponse *)response expirationDate];
        NSLog(@"token:%@\n userID:%@\n expirationDate:%@\n",_token,_userID,_expirationDate);
        //[self sinaWeiBoGetFansList];
        [self sinaWeiBoGetFocusList];
        [self sinaWeiBoGetUseInfo];
        
    }
}

#pragma mark - WBHttpRequestDelegate

- (void)request:(WBHttpRequest *)request didFinishLoadingWithResult:(NSString *)result
{
    NSLog(@"didFinishLoadingWithResult");
    NSString *url=request.url;
    if ([url isEqualToString:kWeiBoGetFocusList]) {
       NSDictionary *dict=[self FocusParseDataFromJsonStr:result];
        NSLog(@"%@",dict);
        NSLog(@"--------------------------\n");
    }else if([url isEqualToString:kWeiBoGetFansList])
    {
        NSDictionary *dict=[self FansParseDataFromJsonStr:result];
        NSLog(@"%@",dict);
        NSLog(@"--------------------------\n");
    }else if([url isEqualToString:kWeiBoGetUserInfo])
    {
        NSDictionary *dict=[self UserInfoParseDataFromJsonStr:result];
        NSLog(@"%@",dict);
        NSLog(@"--------------------------\n");
    }
}
- (void)request:(WBHttpRequest *)request didFailWithError:(NSError *)error;
{
    NSLog(@"error:%@",error.description);
}



#pragma mark - Tenctent

- (void)tencentDidLogin {
    if (_tencentOAuth.accessToken && 0 != [_tencentOAuth.accessToken length])
    {
        NSString *str=[@"accessToken:" stringByAppendingFormat:@"%@\n", _tencentOAuth.accessToken];
        str=[str stringByAppendingFormat:@"openid:%@\n",_tencentOAuth.openId];
        str=[str stringByAppendingFormat:@"expirationDate:%@\n",_tencentOAuth.expirationDate];
        NSLog(@"QQ登录成功");
        NSLog(@"%@",str);
        NSLog(@"-------------------");
        
        _userID=_tencentOAuth.openId;
        _token=_tencentOAuth.accessToken;
        _expirationDate=_tencentOAuth.expirationDate;
        
        [self getUserInfo];
        
    }
    else
    {
        NSLog(@"登录不成功 没有获取accesstoken");
    }
}

- (void)tencentDidNotLogin:(BOOL)cancelled
{
	if (cancelled){
		NSLog(@"用户取消登录");
	}
	else {
		NSLog(@"登录失败");
	}
	
}
-(void)tencentDidNotNetWork
{
	NSLog(@"无网络连接，请设置网络");
}


#pragma mark - Tencent method
-(void)getUserInfo
{
    if(![_tencentOAuth getUserInfo]){
        NSLog(@"获取用户信息失败");
    }
}

/**
 * Called when the get_user_info has response.
 */
- (void)getUserInfoResponse:(APIResponse*) response {
    
    NSLog(@"获取个人信息完成");
	if (response.retCode == URLREQUEST_SUCCEED)
	{
		NSMutableString *str=[NSMutableString stringWithFormat:@""];
        /*
		for (id key in response.jsonResponse) {
			[str appendString: [NSString stringWithFormat:@"%@:%@\n",key,[response.jsonResponse objectForKey:key]]];
		}
         */
        [str appendString: [NSString stringWithFormat:@"%@:%@\n",@"昵称",[response.jsonResponse objectForKey:@"nickname"]]];
        [str appendString: [NSString stringWithFormat:@"%@:%@\n",@"性别",[response.jsonResponse objectForKey:@"gender"]]];
        [str appendString: [NSString stringWithFormat:@"%@:%@\n",@"头像",[response.jsonResponse objectForKey:@"figureurl_2"]]];//头像有30,40,50,100四个尺寸
		NSLog(@"获取成功:%@",str);
        NSLog(@"-------------------");
	}
	else
    {
        NSLog(@"获取失败");
	}
	
}



#pragma mark - handleOpenURL

-(BOOL)handleOpenURL:(NSURL *)url
{
    BOOL returnValue;
    if (_type==SocialType_SINA) {
        returnValue=[WeiboSDK handleOpenURL:url delegate:self];
    }else if(_type==SocialType_QQ)
    {
        returnValue=[TencentOAuth HandleOpenURL:url];
    }
    return returnValue;
}



#pragma  mark - init 第三方 data
-(void)initSinaWeiBo
{
    [WeiboSDK enableDebugMode:YES];
    [WeiboSDK registerApp:kAppKey];
}

-(void)initTencent
{
    _permissions = [NSArray arrayWithObjects:
                    kOPEN_PERMISSION_GET_USER_INFO,
                    //kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                    //kOPEN_PERMISSION_ADD_ALBUM,
                    //kOPEN_PERMISSION_ADD_IDOL,
                    //kOPEN_PERMISSION_ADD_ONE_BLOG,
                    //kOPEN_PERMISSION_ADD_PIC_T,
                    kOPEN_PERMISSION_ADD_SHARE,
                    //kOPEN_PERMISSION_ADD_TOPIC,
                    //kOPEN_PERMISSION_CHECK_PAGE_FANS,
                    //kOPEN_PERMISSION_DEL_IDOL,
                    //kOPEN_PERMISSION_DEL_T,
                    //kOPEN_PERMISSION_GET_FANSLIST,
                    kOPEN_PERMISSION_GET_IDOLLIST,
                    //kOPEN_PERMISSION_GET_INFO,
                    //kOPEN_PERMISSION_GET_OTHER_INFO,
                    //kOPEN_PERMISSION_GET_REPOST_LIST,
                    //kOPEN_PERMISSION_LIST_ALBUM,
                    //kOPEN_PERMISSION_UPLOAD_PIC,
                    //kOPEN_PERMISSION_GET_VIP_INFO,
                    //kOPEN_PERMISSION_GET_VIP_RICH_INFO,
                    kOPEN_PERMISSION_GET_INTIMATE_FRIENDS_WEIBO,
                    //kOPEN_PERMISSION_MATCH_NICK_TIPS_WEIBO,
                    nil];
    
    
    
    
    _tencentOAuth = [[TencentOAuth alloc] initWithAppId:QQAppKey andDelegate:self];
}


@end
