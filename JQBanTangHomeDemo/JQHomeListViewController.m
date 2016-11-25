//
//  JQHomeListViewController.m
//  JQBanTangHomeDemo
//
//  Created by jianquan on 2016/11/25.
//  Copyright © 2016年 JoySeeDog. All rights reserved.
//

#import "JQHomeListViewController.h"
#import "DAPagesContainer.h"
#import "JQTableViewController.h"
#import "UIImage+JQImage.h"

@interface JQHomeListViewController ()<DAPagesContainerDelegate>

@property (nonatomic, strong) DAPagesContainer *pageContainer;
@property (nonatomic, strong) NSArray *pageArray;

@end

@implementation JQHomeListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUppageContainer];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUppageContainer
{
   
        self.pageContainer  = [[DAPagesContainer alloc] init];
        self.pageContainer .delegate = self;
       
        
        self.pageArray = @[@"昨日",@"上周",@"上月",@"总榜"];
        
        NSMutableArray *viewControllers = [[NSMutableArray alloc] init];
        for (int i = 0; i < (int)[self.pageArray count]; i++) {
            
            JQTableViewController *tableViewController = [[JQTableViewController alloc] init];
//            viewController.delegate = self;
//            viewController.title =  self.pageArray[i];
//            viewController.categoryArray = [self currentCategory:self.selectedSegmentIndex tagIndex:i];
            [viewControllers addObject:tableViewController];
        }
        self.pageContainer .viewControllers = viewControllers;
        
        [self.pageContainer  willMoveToParentViewController:self];
        self.pageContainer .view.frame = self.view.bounds;
        self.pageContainer .view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:self.pageContainer .view];
        self.pageContainer .topBarHeight = 30.f;
        self.pageContainer .topBarBackgroundColor = [UIColor whiteColor];
        self.pageContainer .pageItemsTitleColor = [UIColor redColor];
        self.pageContainer .selectedPageItemTitleColor = [UIColor redColor];
        self.pageContainer .pageIndicatorImage = [UIImage imageWithColor:[UIColor blueColor] size:CGSizeMake(self.view.frame.size.width/4.f, 2.f)];
      
        [self addChildViewController:self.pageContainer ];
        
        [self.view addSubview:self.pageContainer .view];
        
        [self.pageContainer  didMoveToParentViewController:self];
    
    
    
}


@end
