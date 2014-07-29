//
//  FirstViewController.m
//  SocialLogin
//
//  Created by wang yan on 14-7-29.
//  Copyright (c) 2014年 AiXiang. All rights reserved.
//

#import "FirstViewController.h"
#import "SecondViewController.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title=@"第三方登录集合";
    UIBarButtonItem *bi=[[UIBarButtonItem alloc]initWithTitle:@"登录" style:UIBarButtonItemStyleBordered target:self action:@selector(login)];
    self.navigationItem.rightBarButtonItem=bi;
}

-(void)login
{
    SecondViewController *sVC=[[SecondViewController alloc]initWithStyle:UITableViewStylePlain];
    [self.navigationController pushViewController:sVC animated:YES];
}

-(void)loginSocial:(SocialType)type
{
    NSLog(@"index:%d",type);
    switch (type) {
        case SocialType_SINA:
            [[XXCNSocialLogin sharedManager] loginSinaWeiBo];
            break;
        case SocialType_QQ:
            [[XXCNSocialLogin sharedManager] loginQQ];
            break;
    
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
