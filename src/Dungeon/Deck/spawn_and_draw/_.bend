def spawn_and_draw() -> Unit:
  unit{}

import Dungeon as Dungeon
import Dungeon/Deck/counts_pick as M__Dungeon_Deck_counts_pick
import Dungeon/rules as M__Dungeon_rules

def _spawn_tile(config_value: Dungeon/Config, entry: Dungeon/DeckEntry, level: U32) -> Dungeon/Tile:
  match config_value entry:
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level} monster_entry{ref, count}:
      monster{ref, Dungeon/Deck/counts_pick/_monster_hp(monsters, ref, level)}
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level} sword_entry{ref, count}:
      sword{ref, Dungeon/Deck/counts_pick/_sword_damage(swords, ref)}
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level} potion_entry{ref, count}:
      potion{ref, Dungeon/Deck/counts_pick/_potion_heal(potions, ref)}
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level} hero_entry{count}:
      none{}

def _draw_from_pick(config_value: Dungeon/Config, remaining: U32, next_seed_value: U32, level: U32, entry: Dungeon/DeckEntry, counts: List(Dungeon/DeckEntry)) -> Dungeon/DrawResult:
  draw_result{_spawn_tile(config_value, entry, level), counts, remaining - 1, next_seed_value, level}

def _pick_result_to_draw(config_value: Dungeon/Config, remaining: U32, next_seed_value: U32, level: U32, result: Dungeon/_PickResult) -> Dungeon/DrawResult:
  match result:
    case no_pick{counts}:
      draw_result{none{}, counts, remaining, next_seed_value, level}
    case picked_entry{entry, counts}:
      _draw_from_pick(config_value, remaining, next_seed_value, level, entry, counts)

def _draw_from_counts(config_value: Dungeon/Config, draw_counts: List(Dungeon/DeckEntry), remaining: U32, seed: U32, level: U32) -> Dungeon/DrawResult:
  match remaining:
    case 0:
      draw_result{none{}, draw_counts, 0, Dungeon/Deck/counts_pick/next_seed(seed), level}
    case _:
      idx = seed % remaining;
      next = Dungeon/Deck/counts_pick/next_seed(seed);
      _pick_result_to_draw(config_value, remaining, next, level, Dungeon/Deck/counts_pick/_pick_entry(draw_counts, idx))

def draw_tile(config_value: Dungeon/Config, deck_blueprint: List(Dungeon/DeckEntry), draw_counts: List(Dungeon/DeckEntry), remaining: U32, seed: U32, level: U32) -> Dungeon/DrawResult:
  match remaining:
    case 0:
      refill = Dungeon/Deck/counts_pick/sum_counts(deck_blueprint);
      _draw_from_counts(config_value, deck_blueprint, refill, seed, level + Dungeon/rules/dungeon_level_increment_per_refill())
    case _:
      _draw_from_counts(config_value, draw_counts, remaining, seed, level)
