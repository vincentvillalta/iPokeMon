//
//  GameWildPokemon.m
//  Pokemon
//
//  Created by Kaijie Yu on 2/27/12.
//  Copyright 2012 Kjuly. All rights reserved.
//

#import "GameWildPokemon.h"

#import "GameStatus.h"
#import "GlobalNotificationConstants.h"
#import "WildPokemon+DataController.h"
#import "Pokemon.h"
#import "Move.h"


@interface GameWildPokemon () {
 @private
  WildPokemon * wildPokemon_;
}

@property (nonatomic, retain) WildPokemon * wildPokemon;

@end

@implementation GameWildPokemon

static int attackDelayTime = 300;

@synthesize wildPokemon = wildPokemon_;

- (void)dealloc
{
  [super dealloc];
}

- (id)initWithPokemonID:(NSInteger)pokemonID keyName:(NSString *)keyName
{
  if (self = [super init]) {
    // Base Setting
    self.pokemonBattleStatus = kPokemonBattleStatusNormal;
    
    // Data Setting
    self.wildPokemon = [WildPokemon queryPokemonDataWithID:pokemonID];
    self.pokemonSprite = [CCSprite spriteWithCGImage:((UIImage *)self.wildPokemon.pokemon.image).CGImage key:keyName];
    [self.pokemonSprite setPosition:ccp(-90, 380)];
    [self addChild:self.pokemonSprite];
    
    // Set HP
    self.hpMax = [[self.wildPokemon.maxStats objectAtIndex:0] intValue];
    self.hp    = self.hpMax;
    
    // Create Hp Bar
    hpBar_ = [[GamePokemonHPBar alloc] initWithHP:self.hp hpMax:self.hpMax];
    [hpBar_ setPosition:ccp(10, 380)];
    [self addChild:hpBar_];
  }
  return self;
}

- (void)update:(ccTime)dt
{
  [super update:dt];
  
  // Acation
  // If it's Wild Pokemon's Turn, it'll use Move to Attack
  [self attack:dt];
}

#pragma mark - Wild Pokemon's Move Attack

- (void)attack:(ccTime)dt
{
  if ([[GameStatus sharedInstance] isWildPokemonTurn]) {
    NSLog(@"Wild Pokemon's Turn:");
    attackDelayTime -= 100 * dt;
    if (attackDelayTime > 0)
      return;
    
    // Do Move Attack
    Move * move = [[self.wildPokemon.fourMoves allObjects] objectAtIndex:0];
    
    // Send parameter to Move Effect Controller
    NSDictionary * userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
                               @"WildPokemon", @"MoveOwner",
                               move.baseDamage, @"damage",
                               nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kPMNMoveEffect object:nil userInfo:userInfo];
    [userInfo release];
    
    [[GameStatus sharedInstance] wildPokemonTurnEnd];
    attackDelayTime = 300;
  }
}

@end