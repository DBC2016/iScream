//
//  AppDelegate.m
//  iScream
//
//  Created by Thomas Crawford on 6/7/15.
//  Copyright (c) 2015 VizNetwork. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

NSString *const kModelDB = @"iScream.sqlite";
NSString *const kModelDBWAL = @"iScream.sqlite-wal";
NSString *const kModelDBSHM = @"iScream.sqlite-shm";
NSString *const kModelDBResource = @"iScream";
NSString *const kModelDBType     = @"sqlite";
NSString *const kModelDBWALType  = @"sqlite-wal";
NSString *const kModelDBSHMType  = @"sqlite-shm";

#pragma mark - Database Methods

- (NSString *) dbPath {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    path = [[NSString pathWithComponents: [NSArray arrayWithObjects: path, kModelDB, nil]] stringByStandardizingPath];
    return path;
}

- (BOOL) doesDBExistAtPath: (NSString *) path {
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath: path];
    return fileExists;
}

- (void) copyDBToPath: (NSString *) path {
    NSError *error = nil;
    NSString *dbBundlePath	= [[NSBundle mainBundle] pathForResource: kModelDBResource ofType: kModelDBType];
    NSString *dbWALBundlePath = [[NSBundle mainBundle] pathForResource: kModelDBResource ofType: kModelDBWALType];
    NSString *dbSHMBundlePath = [[NSBundle mainBundle] pathForResource: kModelDBResource ofType: kModelDBSHMType];
    if (dbBundlePath) {
        [[NSFileManager defaultManager] copyItemAtPath: dbBundlePath toPath: path error: &error];
        
        NSString *destPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *destPathWAL = [[NSString pathWithComponents: [NSArray arrayWithObjects: destPath, kModelDBWAL, nil]] stringByStandardizingPath];
        [[NSFileManager defaultManager] copyItemAtPath: dbWALBundlePath toPath: destPathWAL error: &error];
        
        NSString *destPathSHM = [[NSString pathWithComponents: [NSArray arrayWithObjects: destPath, kModelDBSHM, nil]] stringByStandardizingPath];
        [[NSFileManager defaultManager] copyItemAtPath: dbSHMBundlePath toPath: destPathSHM error: &error];
    }
}

#pragma mark - App Life Cycle Methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if (![self doesDBExistAtPath: self.dbPath]) {
        NSLog(@"Copying");
        [self copyDBToPath: self.dbPath];
    }
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
//    NSLog(@"%@",[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory  inDomains:NSUserDomainMask] lastObject]);
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"iScream" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"iScream.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
