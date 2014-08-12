//
//  PADDungeonTrackerTableViewController.m
//  PADTracker
//
//  Created by Carl Lam on 2014-08-09.
//
//

#import "PADDungeonTrackerTableViewController.h"
#import "PADGroupSettingsViewController.h"
#import "PADDungeonDetailsViewController.h"
#import "PADDungeonEvent.h"
#import "TFHpple.h"

@interface PADDungeonTrackerTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *detail;
- (IBAction)clockButton:(UIButton *)sender;

@property NSMutableArray *dungeonEvents;
@property PADDungeonEvent *eventToSend;
@property NSString *utcDifference;

@end

@implementation PADDungeonTrackerTableViewController

-(IBAction)unwindToList:(UIStoryboardSegue *)segue
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.starter = [userDefaults integerForKey:@"key1"];
    self.group = [userDefaults integerForKey:@"key2"];
    self.utcDifference = [userDefaults objectForKey:@"key3"];
    
    [self updateDungeons];
    [self.tableView reloadData];
    
}

-(void)fetchNewDataWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"Fetching new data");
    [self updateDungeons];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.starter = [userDefaults integerForKey:@"key1"];
    self.group = [userDefaults integerForKey:@"key2"];
    self.utcDifference = [userDefaults objectForKey:@"key3"];
    self.dungeonEvents = [[NSMutableArray alloc] init];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshDungeons) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    [self updateDungeons];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)refreshDungeons {
    [self updateDungeons];
    [self.refreshControl endRefreshing];
}

- (void)updateDungeons {
    //Create the request
    NSString *urlString = [NSString stringWithFormat:@"http://puzzledragonx.com/?utc=%@",self.utcDifference];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL
    URLWithString:[NSString stringWithFormat:urlString]]];
    
    //Create url connection and fire request
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    conn = nil;
}

- (void)loadInitialData {
    PADDungeonEvent *dungeon1 = [[PADDungeonEvent alloc] init];
    dungeon1.dungeonName = @"Alert! Metal Dragons";
    dungeon1.dungeonTime = @"4 pm";
    [self.dungeonEvents addObject:dungeon1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    //The request is complete and data has been received
    //You can parse the stuff in your instance variable now

    TFHpple *dungeonParser = [TFHpple hppleWithHTMLData:_responseData];
    
    NSString *dungeonTodayXpathQueryString = @"//div[@id='metal1a']/span/table";
    NSArray *dungeonNodes = [dungeonParser searchWithXPathQuery:dungeonTodayXpathQueryString];
    NSArray *dungeonTodayNodes = [[dungeonNodes firstObject] children];

    
    NSMutableArray *newDungeonEvents = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray *newDungeonSection = [[NSMutableArray alloc] initWithCapacity:0];
    NSUInteger i = 0;
    NSUInteger j = 1;
    for (i = 0; i < ([dungeonTodayNodes count] - 1) / 2; i++) {
        PADDungeonEvent *dungeonEvent = [[PADDungeonEvent alloc] init];
        TFHppleElement *element = [dungeonTodayNodes objectAtIndex:j];
        TFHppleElement *elementChild = [element firstChildWithClassName:@"monstericon2"];
                                        
        if ([elementChild hasChildren]){
            PADDungeonEvent *dungeonEvent2 = [[PADDungeonEvent alloc] init];
            
            TFHppleElement *elementChild2 = [[element firstChildWithClassName:@"monstericon1"] firstChild];
            TFHppleElement *elementChild1 = [elementChild firstChild];
            
            dungeonEvent.dungeonLink = [elementChild1 objectForKey:@"href"];
            dungeonEvent2.dungeonLink = [elementChild2 objectForKey:@"href"];
            
            NSString *dungeonNameLink1XpathQueryString =
            [NSString stringWithFormat:@"//a[@href='%@']", dungeonEvent.dungeonLink];
            NSString *dungeonNameLink2XpathQueryString =
            [NSString stringWithFormat:@"//a[@href='%@']", dungeonEvent2.dungeonLink];
            
            TFHppleElement *elementChild1Name = [[dungeonParser searchWithXPathQuery:dungeonNameLink1XpathQueryString] lastObject];
            TFHppleElement *elementChild2Name = [[dungeonParser searchWithXPathQuery:dungeonNameLink2XpathQueryString] lastObject];
            
            dungeonEvent.dungeonName = [[[elementChild1Name firstChild] content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            dungeonEvent2.dungeonName = [[[elementChild2Name firstChild] content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            j++;
            TFHppleElement *timeElement = [[[dungeonTodayNodes objectAtIndex:j] childrenWithClassName:@"metaltime"] objectAtIndex:(self.group)];
            dungeonEvent.dungeonTime = [[timeElement firstChild] content];
            dungeonEvent2.dungeonTime = [[timeElement firstChild] content];
            j++;
            
            dungeonEvent2.clockClicked = NO;
            dungeonEvent2.clockImage = [UIImage imageNamed:@"clock34.png"];
            
            [newDungeonSection addObject:dungeonEvent2];

            
        } else {
            TFHppleElement *elementChild0 = [[element firstChildWithClassName:@"monstericon0"] firstChild];
            NSString *dungeonNameLink0XpathQueryString =
            [NSString stringWithFormat:@"//a[@href='%@']", [elementChild0 objectForKey:@"href"]];
            TFHppleElement *elementChild0Name = [[dungeonParser searchWithXPathQuery:dungeonNameLink0XpathQueryString] lastObject];
            dungeonEvent.dungeonName = [[[elementChild0Name firstChild] content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            j++;
            TFHppleElement *timeElement = [[[dungeonTodayNodes objectAtIndex:j] childrenWithClassName:@"metaltime"] objectAtIndex:(self.group)];
            dungeonEvent.dungeonTime = [[timeElement firstChild] content];
            j++;
        }
        
        dungeonEvent.clockClicked = NO;
        dungeonEvent.clockImage = [UIImage imageNamed:@"clock34.png"];
        [newDungeonSection addObject:dungeonEvent];
        
    }
    [newDungeonEvents addObject:newDungeonSection];
    
    
    NSString *dungeonTomorrowXpathQueryString = @"//div[@id='metal1b']/span/table";
    NSArray *dungeonNodes2 = [dungeonParser searchWithXPathQuery:dungeonTomorrowXpathQueryString];
    NSArray *dungeonTomorrowNodes = [[dungeonNodes2 firstObject] children];
    
    
    NSMutableArray *newDungeonSection2 = [[NSMutableArray alloc] initWithCapacity:0];
    i = 0;
    j = 1;
    for (i = 0; i < ([dungeonTomorrowNodes count] - 1) / 2; i++) {
        PADDungeonEvent *dungeonEvent = [[PADDungeonEvent alloc] init];
        TFHppleElement *element = [dungeonTomorrowNodes objectAtIndex:j];
        TFHppleElement *elementChild = [element firstChildWithClassName:@"monstericon2"];
        
        if ([elementChild hasChildren]){
            PADDungeonEvent *dungeonEvent2 = [[PADDungeonEvent alloc] init];
            
            TFHppleElement *elementChild2 = [[element firstChildWithClassName:@"monstericon1"] firstChild];
            TFHppleElement *elementChild1 = [elementChild firstChild];
            
            dungeonEvent.dungeonLink = [elementChild1 objectForKey:@"href"];
            dungeonEvent2.dungeonLink = [elementChild2 objectForKey:@"href"];
            
            NSString *dungeonNameLink1XpathQueryString =
            [NSString stringWithFormat:@"//a[@href='%@']", dungeonEvent.dungeonLink];
            NSString *dungeonNameLink2XpathQueryString =
            [NSString stringWithFormat:@"//a[@href='%@']", dungeonEvent2.dungeonLink];
            
            TFHppleElement *elementChild1Name = [[dungeonParser searchWithXPathQuery:dungeonNameLink1XpathQueryString] lastObject];
            TFHppleElement *elementChild2Name = [[dungeonParser searchWithXPathQuery:dungeonNameLink2XpathQueryString] lastObject];
            
            dungeonEvent.dungeonName = [[[elementChild1Name firstChild] content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            dungeonEvent2.dungeonName = [[[elementChild2Name firstChild] content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            j++;
            TFHppleElement *timeElement = [[[dungeonTomorrowNodes objectAtIndex:j] childrenWithClassName:@"metaltime"] objectAtIndex:(self.group)];
            dungeonEvent.dungeonTime = [[timeElement firstChild] content];
            dungeonEvent2.dungeonTime = [[timeElement firstChild] content];
            j++;
            
            [newDungeonSection2 addObject:dungeonEvent2];

            
        } else {
            TFHppleElement *elementChild0 = [[element firstChildWithClassName:@"monstericon0"] firstChild];
            NSString *dungeonNameLink0XpathQueryString =
            [NSString stringWithFormat:@"//a[@href='%@']", [elementChild0 objectForKey:@"href"]];
            TFHppleElement *elementChild0Name = [[dungeonParser searchWithXPathQuery:dungeonNameLink0XpathQueryString] lastObject];
            dungeonEvent.dungeonName = [[[elementChild0Name firstChild] content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            j++;
            TFHppleElement *timeElement = [[[dungeonTomorrowNodes objectAtIndex:j] childrenWithClassName:@"metaltime"] objectAtIndex:(self.group)];
            dungeonEvent.dungeonTime = [[timeElement firstChild] content];
            j++;
        }
        
        [newDungeonSection2 addObject:dungeonEvent];
        
    }
    [newDungeonEvents addObject:newDungeonSection2];
   
    
    self.dungeonEvents = newDungeonEvents;

    [self.tableView reloadData];
    
    
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    //Request failed for some reason!
    //Check the error var
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.dungeonEvents count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [[self.dungeonEvents objectAtIndex:section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DungeonEventsCell" forIndexPath:indexPath];
    
    UILabel *label;
    
    // Configure the cell...
    
    NSArray *dungeonSection = [self.dungeonEvents objectAtIndex:indexPath.section];
    PADDungeonEvent *dungeonEvent = [dungeonSection objectAtIndex:indexPath.row];
    
    

        UIButton *clockButton = (UIButton *)[cell viewWithTag:1];
    
    if (indexPath.section == 0){
        [clockButton setTitle:[NSString stringWithFormat:@"%ld",(long)indexPath.row] forState:UIControlStateNormal];
        [clockButton setImage:dungeonEvent.clockImage forState:UIControlStateNormal];
    
    } else{
        [clockButton setTitle:@" " forState:UIControlStateNormal];
    }
    
    label = (UILabel *)[cell viewWithTag:100];
    label.text = dungeonEvent.dungeonTime;
    
    label = (UILabel *)[cell viewWithTag:200];
    label.text = dungeonEvent.dungeonName;
    
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return @"Tomorrow's Metal Dungeon Schedule";
    }
    return @"Today's Metal Dungeon Schedule";
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0){
        self.eventToSend = [[self.dungeonEvents objectAtIndex:0] objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"detailSegue" sender:self.eventToSend];
        
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([[segue identifier] isEqualToString:@"detailSegue"]){
        PADDungeonDetailsViewController *vc = [segue destinationViewController];
        
        [vc setDungeonEvent:self.eventToSend];
        
        
        
        
    }
}



- (IBAction)clockButton:(UIButton *)sender {
    
    if (![sender.currentTitle isEqualToString:@" "]){
    
        NSUInteger number = [sender.currentTitle integerValue];
        NSArray *dungeonSection = [self.dungeonEvents objectAtIndex:0];
        PADDungeonEvent *touchDungeon = [dungeonSection objectAtIndex:number];
        if (touchDungeon.clockClicked == NO) {
            touchDungeon.clockImage = [UIImage imageNamed:@"clock37.png"];
            touchDungeon.clockClicked = YES;
        } else {
            touchDungeon.clockImage = [UIImage imageNamed:@"clock34.png"];
            touchDungeon.clockClicked = NO;
        }
    [self.tableView reloadData];
    }
    
}
@end
