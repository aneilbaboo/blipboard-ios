//
//  LoginViewController.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 3/26/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "LoginViewController.h"

const NSString *kGalleryPage1 = @"map";
const NSString *kGalleryPage2 = @"matty";
const NSString *kLoginPage = @"login";

@implementation LoginViewController {
    NSArray *_pageSequence;
    NSDictionary *_pages;
    NSString *_loginPageText;
}

@dynamic haveSeenGallery;

+(instancetype)loginViewController {
    return [self loginViewController:nil];
}

+(instancetype)loginViewController:(NSString *)loginPageText {
    LoginViewController *obj = [[self alloc] initWithNibName:nil bundle:nil];
    return obj;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupStyle];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //self.pageControl.ry = self.view.height - self.pageControl.height*2.5;
    
    if (!self.haveSeenGallery) {
        [Flurry logEvent:kFlurryGalleryStart];
        BBLog(@"started with gallery");
        
        [self setupPages:@[kGalleryPage1, kGalleryPage2, kLoginPage]];
    }
    else {
        [Flurry logEvent:kFlurryGalleryLogin];
        BBLog(@"started with loginView only");
        [self setupPages:@[kLoginPage]];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupStyle {
    self.pageControl.backgroundColor = [UIColor bbOrange];
    self.pageControl.layer.cornerRadius = self.pageControl.height/2;
    self.pageControl.layer.masksToBounds = YES;
    self.pageControl.hidesForSinglePage = YES;
}

- (void)setupPages:(NSArray *)pageSequence {
    self.gallery_page1.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.gallery_page2.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.loginView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    _pages = @{kGalleryPage1: self.gallery_page1,
               kGalleryPage2: self.gallery_page2,
               kLoginPage: self.loginView};
    
    [Heatmaps track:self.gallery_page1 withKey:@"92e49bf7098d3dd4-5b71d0d1"];
    [Heatmaps track:self.gallery_page2 withKey:@"92e49bf7098d3dd4-3c4605b5"];
    [Heatmaps track:self.loginView withKey:@"92e49bf7098d3dd4-f6a8ce7e"];
    
    // setup scrollView
    _pageSequence = pageSequence;
    CGFloat xPos = 0;
    for (NSString *pageName in pageSequence) {
        UIView *page = _pages[pageName];
        [self.scrollView addSubview:page];
        page.rx = xPos;
        xPos += page.width;
    }
    self.scrollView.contentSize = CGSizeMake(xPos,self.view.height);
    
    // setup page control
    self.pageControl.numberOfPages = pageSequence.count;
    self.pageControl.currentPage = 0;
    
    [self updatePageControl];
}

#pragma mark -
#pragma mark Page management
-(NSInteger)currentPage {
    CGFloat pageWidth = self.scrollView.width;
    NSInteger pageNumber = (NSInteger)(self.scrollView.contentOffset.x / pageWidth); // 0-based page number
    return pageNumber;
}

// Updates the Page Control and reports changes to Flurry!
-(void)updatePageControl {
    static NSInteger lastPage = -1;
    NSInteger pageNumber = self.currentPage;
    
    if (pageNumber != lastPage) {
        NSString *pageName = _pageSequence[pageNumber];
        BBLog(@"%d: %@",pageNumber,pageName);
        self.pageControl.currentPage = pageNumber;
        [Flurry logEvent:[NSString stringWithFormat:@"%@-%d-%@",
                          kFlurryGalleryPageSelected, pageNumber, pageName]];
        lastPage = pageNumber;
        if ([pageName isEqualToString:(NSString *)kGalleryPage2]) {
            // we're showing the notifications page - this is the first time we request push nots from the user
            [[BBRemoteNotificationManager sharedManager] requestDeviceToken];
        }
    }
    
}

-(void)showPage:(NSInteger)page {
    NSString *pageName = _pageSequence[page];
    UIView *view = _pages[pageName];
    [self.scrollView scrollRectToVisible:view.frame animated:YES];
}

#pragma mark -
#pragma mark Actions
-(IBAction)handleGalleryTap:(id)sender {
    NSInteger currentPage =[self currentPage];
    NSInteger nextPage = currentPage+1;
    BBLog(@"currentPage=%d",currentPage);
    if (nextPage < _pageSequence.count) {
        [self showPage:nextPage];
    }
}

-(IBAction)facebookLoginPressed:(id)sender {
    BBTrace();
    [self.delegate facebookLogin:self];
    self.haveSeenGallery = YES;
}

#pragma mark -
#pragma mark Properties
-(BOOL)haveSeenGallery {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:@"haveSeenGallery"];
}

-(void)setHaveSeenGallery:(BOOL)seen {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:seen forKey:@"haveSeenGallery"];
    [defaults synchronize];
}

#pragma mark -
#pragma mark UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updatePageControl];
}
         
@end
