import Dungeon as Dungeon
import Dungeon/Deck/counts_pick as M__Dungeon_Deck_counts_pick

def card_to_tile(config_value: Dungeon/Config, card: Dungeon/CardRef) -> Dungeon/Tile:
  match config_value card:
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level} monster_card{ref}:
      monster{ref, Dungeon/Deck/counts_pick/_monster_hp(monsters, ref, 1)}
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level} sword_card{ref}:
      sword{ref, Dungeon/Deck/counts_pick/_sword_damage(swords, ref)}
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level} potion_card{ref}:
      potion{ref, Dungeon/Deck/counts_pick/_potion_heal(potions, ref)}
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level} hero_card{}:
      none{}
