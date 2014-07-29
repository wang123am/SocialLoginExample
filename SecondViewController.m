//
//  SecondViewController.m
//  SocialLogin
//
//  Created by wang yan on 14-7-29.
//  Copyright (c) 2014年 AiXiang. All rights reserved.
//

#import "SecondViewController.h"
#import "FirstViewController.h"

static NSString *cellIndetifier=@"cellIndetifier";

@interface SecondViewController ()
{
    NSArray *_dataSourceArray;
}

@end

@implementation SecondViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    _dataSourceArray=@[@"QQ",@"新浪微博"];
    [self.tableView registerClass: [UITableViewCell class] forCellReuseIdentifier:cellIndetifier];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_dataSourceArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndetifier forIndexPath:indexPath];
    
    if (!cell) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndetifier];
    }
    cell.textLabel.text=[_dataSourceArray objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FirstViewController *fvc = [self.navigationController.viewControllers objectAtIndex:0];
    SocialType type=-1;
    
    switch (indexPath.row) {
        case 0:
            type=SocialType_QQ;
            break;
        case 1:
            type=SocialType_SINA;
            break;
        default:
            break;
    }
    
    [fvc loginSocial:type];
    [self.navigationController popViewControllerAnimated:YES];
}



@end
