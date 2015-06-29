//
//  FISTableViewController.m
//  slapChat
//
//  Created by Joe Burgess on 6/27/14.
//  Copyright (c) 2014 Joe Burgess. All rights reserved.
//

#import "FISTableViewController.h"
#import "Message.h"

@interface FISTableViewController () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchRC;

@end

@implementation FISTableViewController

//- (id)initWithStyle:(UITableViewStyle)style
//{
//    self = [super initWithStyle:style];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.accessibilityLabel = @"TableView";
    self.tableView.accessibilityIdentifier = @"TableView";
    
    self.store = [FISDataStore sharedDataStore];
    
    NSFetchRequest *messageFetch = [[NSFetchRequest alloc] initWithEntityName:@"Message"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"content" ascending:YES];
    messageFetch.sortDescriptors = @[sortDescriptor];
    
    self.fetchRC = [[NSFetchedResultsController alloc] initWithFetchRequest:messageFetch
                                                       managedObjectContext:self.store.managedObjectContext
                                                         sectionNameKeyPath:nil
                                                                  cacheName:nil];
    self.fetchRC.delegate = self;
    [self.fetchRC performFetch:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.store fetchData];
    [self.tableView reloadData];
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
    return self.fetchRC.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (self.fetchRC.sections.count > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchRC.sections[section];
        return [sectionInfo numberOfObjects];
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"basiccell" forIndexPath:indexPath];
    Message *eachMessage = [self.fetchRC objectAtIndexPath:indexPath];
    cell.textLabel.text = eachMessage.content;
    return cell;
}

- (IBAction)addMessageBarButtonTapped:(id)sender
{
    Message *newMessage = [NSEntityDescription insertNewObjectForEntityForName:@"Message"
                                                        inManagedObjectContext:self.store.managedObjectContext];
    newMessage.content = [NSDate date].description;
}

#pragma mark - NSFetchedResultsControllerDelegate methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {

    UITableView *tableView = self.tableView;

    switch(type) {

        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;

//        case NSFetchedResultsChangeUpdate:
//            [tableView reloadRowsAtIndexPaths:@[indexPath]
//                             withRowAnimation:UITableViewRowAnimationAutomatic];
//            break;
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id )sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {

    switch(type) {

        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
        
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}
@end
