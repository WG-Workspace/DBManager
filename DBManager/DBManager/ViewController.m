//
//  ViewController.m
//  DBManager
//
//  Created by A.B.T. on 16/6/22.
//  Copyright © 2016年 A.B.T. All rights reserved.
//

#import "ViewController.h"
#import "DBManager.h"
#import "Person.h"
#import "Student.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    Person *p = [[Person alloc]init];
    p.name = @"晚安";
    p.isSucceed = NO;
    p.age = 50;
    
    Student *stu = [Student new];
    
    stu.name = @"学生";
    stu.age = 23;
    
    
//    [[DBManager shareManager] creatTableWithTableName:@"T_person" andModel:[Person class]];
//    [[DBManager shareManager] insertDataForTableName:@"T_person" WithModel:p];
//        [[DBManager shareManager] insertDataForTableName:@"T_person" WithModel:stu];
    
//    [[DBManager shareManager] deleteDataForTable:@"T_person"];
    
    
//    NSArray * array = [[DBManager shareManager] queryDataOfTableName:@"T_person"];
    
    
//    [[DBManager shareManager] deleteForRowOfTable:@"T_person" flagDictionary:@{@"age":@49} ];
    
//    [[DBManager shareManager]updateDataForTable:@"T_person" updateDictionary:@{@"name":@"早安"} flagDictionary:@{@"name":@"晚安"}];
    
    [[DBManager shareManager]deleteTable:@"T_person"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
