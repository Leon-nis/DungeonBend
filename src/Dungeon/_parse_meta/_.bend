import String as String
import Dungeon/game_config as config
import Dungeon/initial_seed as initial_seed
import Dungeon/parse_saved_run as parse_saved_run
import Dungeon as Dungeon
import Dungeon/Deck/counts_pick as M__Dungeon_Deck_counts_pick
import Dungeon/Boosters/inventory as M__Dungeon_Boosters_inventory
import Dungeon/Boosters/reward_nav as M__Dungeon_Boosters_reward_nav
import Dungeon/hero_helpers as M__Dungeon_hero_helpers
import Dungeon/profile_helpers as M__Dungeon_profile_helpers
import Dungeon/Deck/deck_records as M__Dungeon_Deck_deck_records
import Dungeon/Deck/sleeves as M__Dungeon_Deck_sleeves

def _value_or(value_maybe: Maybe(U32), fallback: U32) -> U32:
  match value_maybe:
    case some{v}:
      v
    case none{}:
      fallback

def _initial_decks_for_config(cfg: Dungeon/Config) -> List(Dungeon/DeckRecord):
  match cfg:
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level}:
      [deck_record{Dungeon/Deck/deck_records/initial_deck_id(), Dungeon/Deck/deck_records/initial_deck_name(), Dungeon/Deck/sleeves/default_sleeve(), deck}]

def _prepend_initial(records: List(Dungeon/DeckRecord)) -> List(Dungeon/DeckRecord):
  match _initial_decks_for_config(config()):
    case []:
      records
    case head<>rest:
      head<>records

def _has_initial_match(matched: U32, rest_result: U32) -> U32:
  match matched:
    case 1:
      1
    case _:
      rest_result

def _record_id(record: Dungeon/DeckRecord) -> U32:
  match record:
    case deck_record{id, name, sleeve, entries}:
      id

def _has_initial_deck(records: List(Dungeon/DeckRecord)) -> U32:
  match records:
    case []:
      0
    case current<>rest:
      _has_initial_match(_record_id(current) === Dungeon/Deck/deck_records/initial_deck_id(), _has_initial_deck(rest))

def _ensure_initial_deck(records: List(Dungeon/DeckRecord)) -> List(Dungeon/DeckRecord):
  match _has_initial_deck(records):
    case 1:
      records
    case _:
      _prepend_initial(records)

def _append_one(entries: List(Dungeon/DeckEntry), entry: Dungeon/DeckEntry) -> List(Dungeon/DeckEntry):
  match entries:
    case []:
      [entry]
    case head<>rest:
      head<>_append_one(rest, entry)

def _append_hero_entry(entries: List(Dungeon/DeckEntry), hero_count: U32) -> List(Dungeon/DeckEntry):
  match hero_count:
    case 0:
      entries
    case _:
      _append_one(entries, hero_entry{hero_count})

def _append_bonus(left: List(Dungeon/DeckEntry), right: List(Dungeon/DeckEntry)) -> List(Dungeon/DeckEntry):
  match left:
    case []:
      right
    case entry<>rest:
      entry<>_append_bonus(rest, right)

def _merge_bonus_sections(monsters: List(Dungeon/DeckEntry), swords: List(Dungeon/DeckEntry), potions: List(Dungeon/DeckEntry)) -> List(Dungeon/DeckEntry):
  _append_bonus(monsters, _append_bonus(swords, potions))

def _count_from_maybe(count_maybe: Maybe(U32)) -> U32:
  match count_maybe:
    case some{count}:
      count
    case none{}:
      0

def _count_from_head(parts: List(String)) -> U32:
  match parts:
    case []:
      0
    case head<>rest:
      _count_from_maybe(String/to_u32(head))

def _tail_parts(parts: List(String)) -> List(String):
  match parts:
    case []:
      []
    case head<>rest:
      rest

def _monster_bonus_entry(count: U32, idx: U32, rest: List(Dungeon/DeckEntry)) -> List(Dungeon/DeckEntry):
  match count:
    case 0:
      rest
    case _:
      monster_entry{idx, count}<>rest

def _parse_monster_bonus(monsters: List(Dungeon/MonsterDef), counts: List(String), idx: U32) -> List(Dungeon/DeckEntry):
  match monsters:
    case []:
      []
    case monster_def{name, sprite, gold_drop, hp_levels}<>rest:
      _monster_bonus_entry(
        _count_from_head(counts),
        idx,
        _parse_monster_bonus(rest, _tail_parts(counts), idx + 1)
      )

def _sword_bonus_entry(count: U32, idx: U32, rest: List(Dungeon/DeckEntry)) -> List(Dungeon/DeckEntry):
  match count:
    case 0:
      rest
    case _:
      sword_entry{idx, count}<>rest

def _parse_sword_bonus(swords: List(Dungeon/SwordDef), counts: List(String), idx: U32) -> List(Dungeon/DeckEntry):
  match swords:
    case []:
      []
    case sword_def{name, sprite, dmg}<>rest:
      _sword_bonus_entry(
        _count_from_head(counts),
        idx,
        _parse_sword_bonus(rest, _tail_parts(counts), idx + 1)
      )

def _potion_bonus_entry(count: U32, idx: U32, rest: List(Dungeon/DeckEntry)) -> List(Dungeon/DeckEntry):
  match count:
    case 0:
      rest
    case _:
      potion_entry{idx, count}<>rest

def _parse_potion_bonus(potions: List(Dungeon/PotionDef), counts: List(String), idx: U32) -> List(Dungeon/DeckEntry):
  match potions:
    case []:
      []
    case potion_def{name, sprite, heal}<>rest:
      _potion_bonus_entry(
        _count_from_head(counts),
        idx,
        _parse_potion_bonus(rest, _tail_parts(counts), idx + 1)
      )

def _build_deck_record(monsters: List(Dungeon/MonsterDef), swords: List(Dungeon/SwordDef), potions: List(Dungeon/PotionDef), id_maybe: Maybe(U32), name: String, sleeve: Dungeon/DeckSleeve, mon_counts: List(String), sw_counts: List(String), pot_counts: List(String), hero_maybe: Maybe(U32)) -> Maybe(Dungeon/DeckRecord):
  match id_maybe:
    case some{id}:
      entries = _merge_bonus_sections(
        _parse_monster_bonus(monsters, mon_counts, 0),
        _parse_sword_bonus(swords, sw_counts, 0),
        _parse_potion_bonus(potions, pot_counts, 0)
      );
      with_hero = _append_hero_entry(entries, _value_or(hero_maybe, 0));
      some{deck_record{id, name, sleeve, with_hero}}
    case none{}:
      none{}

def _parse_deck_record(monsters: List(Dungeon/MonsterDef), swords: List(Dungeon/SwordDef), potions: List(Dungeon/PotionDef), segs: List(String)) -> Maybe(Dungeon/DeckRecord):
  match segs:
    case id_str<>rest:
      match rest:
        case name_str<>rest1:
          match rest1:
            case third_str<>rest2:
              match rest2:
                case fourth_str<>rest3:
                  match rest3:
                    case fifth_str<>rest4:
                      match rest4:
                        case sixth_str<>rest5:
                          match rest5:
                            case seventh_str<>rest6:
                              match rest6:
                                case []:
                                  _build_deck_record(
                                    monsters,
                                    swords,
                                    potions,
                                    String/to_u32(id_str),
                                    name_str,
                                    Dungeon/Deck/sleeves/sleeve_from_code(third_str),
                                    String/split(fourth_str, ','),
                                    String/split(fifth_str, ','),
                                    String/split(sixth_str, ','),
                                    String/to_u32(seventh_str)
                                  )
                                case _:
                                  none{}
                            case []:
                              _build_deck_record(
                                monsters,
                                swords,
                                potions,
                                String/to_u32(id_str),
                                name_str,
                                Dungeon/Deck/sleeves/default_sleeve(),
                                String/split(third_str, ','),
                                String/split(fourth_str, ','),
                                String/split(fifth_str, ','),
                                String/to_u32(sixth_str)
                              )
                            case _:
                              none{}
                        case _:
                          none{}
                    case _:
                      none{}
                case _:
                  none{}
            case _:
              none{}
        case _:
          none{}
    case _:
      none{}

def _parse_deck_record_or_skip(monsters: List(Dungeon/MonsterDef), swords: List(Dungeon/SwordDef), potions: List(Dungeon/PotionDef), part: String, rest_records: List(Dungeon/DeckRecord)) -> List(Dungeon/DeckRecord):
  match _parse_deck_record(monsters, swords, potions, String/split(part, '~')):
    case some{record}:
      record<>rest_records
    case none{}:
      rest_records

def _parse_deck_records(monsters: List(Dungeon/MonsterDef), swords: List(Dungeon/SwordDef), potions: List(Dungeon/PotionDef), parts: List(String)) -> List(Dungeon/DeckRecord):
  match parts:
    case []:
      []
    case current<>rest:
      _parse_deck_record_or_skip(monsters, swords, potions, current, _parse_deck_records(monsters, swords, potions, rest))

def _selected_hero_value(config_value: Dungeon/Config, selected_maybe: Maybe(U32)) -> U32:
  match selected_maybe:
    case some{selected_ref}:
      Dungeon/hero_helpers/normalize_hero_ref(config_value, selected_ref)
    case none{}:
      0

def _selection_confirmed_value(confirmed_maybe: Maybe(U32)) -> U32:
  match confirmed_maybe:
    case some{0}:
      0
    case some{confirmed}:
      1
    case none{}:
      0

def _saved_next_seed_value(next_seed_maybe: Maybe(U32)) -> U32:
  match next_seed_maybe:
    case some{0}:
      initial_seed()
    case some{next_seed}:
      next_seed
    case none{}:
      initial_seed()

def _normalized_flag(value: U32) -> U32:
  match value:
    case 0:
      0
    case _:
      1

def _saved_unlock_value(hero_ref: U32, unlocked: U32) -> U32:
  match hero_ref:
    case 0:
      1
    case _:
      _normalized_flag(unlocked)

def _apply_v3_profile_values(hero_ref: U32, unlocked_maybe: Maybe(U32), hero_level_maybe: Maybe(U32), meta_state: Dungeon/Meta) -> Dungeon/Meta:
  match unlocked_maybe hero_level_maybe:
    case some{unlocked} some{hero_level}:
      Dungeon/profile_helpers/update_profile(meta_state, hero_ref, hero_profile{_saved_unlock_value(hero_ref, unlocked), hero_level})
    case _:
      meta_state

def _apply_v3_profile_segment(hero_ref: U32, parts: List(String), meta_state: Dungeon/Meta) -> Dungeon/Meta:
  match parts:
    case unlocked_str<>rest:
      match rest:
        case hero_level_str<>rest1:
          match rest1:
            case []:
              _apply_v3_profile_values(hero_ref, String/to_u32(unlocked_str), String/to_u32(hero_level_str), meta_state)
            case _:
              meta_state
        case _:
          meta_state
    case _:
      meta_state

def _parse_v3_profiles_list(heroes: List(Dungeon/HeroDef), profile_parts: List(String), meta_state: Dungeon/Meta, hero_ref: U32) -> Dungeon/Meta:
  match heroes:
    case []:
      meta_state
    case hero_def{id, name, sprite, base_max_hp, unlock_cost, starts_unlocked, upgrades}<>hero_rest:
      match profile_parts:
        case []:
          meta_state
        case part<>rest:
          _parse_v3_profiles_list(hero_rest, rest, _apply_v3_profile_segment(hero_ref, String/split(part, '~'), meta_state), hero_ref + 1)

def _pack_inventory_entry(count: U32, idx: U32, rest: List(Dungeon/PackInventoryEntry)) -> List(Dungeon/PackInventoryEntry):
  match count:
    case 0:
      rest
    case _:
      pack_inventory_entry{idx, count}<>rest

def _parse_pack_inventory(packs: List(Dungeon/PackDef), counts: List(String), idx: U32) -> List(Dungeon/PackInventoryEntry):
  match packs:
    case []:
      []
    case pack_def{name, price, reveal_count, allow_duplicates, pool}<>rest:
      _pack_inventory_entry(
        _count_from_head(counts),
        idx,
        _parse_pack_inventory(rest, _tail_parts(counts), idx + 1)
      )

def _build_v6(config_value: Dungeon/Config, selected_maybe: Maybe(U32), confirmed_maybe: Maybe(U32), gold_maybe: Maybe(U32), monster_counts: List(String), sword_counts: List(String), potion_counts: List(String), pack_counts: List(String), profile_parts: List(String), next_seed_maybe: Maybe(U32), saved_scene: Dungeon/SavedScene, active_id_maybe: Maybe(U32), next_id_maybe: Maybe(U32), deck_parts: List(String)) -> Dungeon/DungeonEvent:
  match config_value gold_maybe:
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level} some{gold}:
      base : Dungeon/Meta = meta{
        _selected_hero_value(config_value, selected_maybe),
        _selection_confirmed_value(confirmed_maybe),
        gold,
        _merge_bonus_sections(
          _parse_monster_bonus(monsters, monster_counts, 0),
          _parse_sword_bonus(swords, sword_counts, 0),
          _parse_potion_bonus(potions, potion_counts, 0)
        ),
        _parse_pack_inventory(booster_packs, pack_counts, 0),
        Dungeon/profile_helpers/default_hero_profiles(config_value),
        _ensure_initial_deck(_parse_deck_records(monsters, swords, potions, deck_parts)),
        _value_or(active_id_maybe, Dungeon/Deck/deck_records/initial_deck_id()),
        _value_or(next_id_maybe, Dungeon/Deck/deck_records/initial_deck_id() + 1)
      };
      with_profiles = _parse_v3_profiles_list(heroes, profile_parts, base, 0);
      loaded{with_profiles, saved_scene, _saved_next_seed_value(next_seed_maybe)}
    case _:
      no_save{}

def _parse_saved_running(run_core: String, run_weapon: String, run_board: String, run_blueprint: String, run_counts: String) -> Dungeon/SavedScene:
  match parse_saved_run(run_core, run_weapon, run_board, run_blueprint, run_counts):
    case some{run_value}:
      saved_running{run_value}
    case none{}:
      saved_setup{}

def _parse_saved_scene_v4(scene_kind_maybe: Maybe(U32), run_core: String, run_weapon: String, run_board: String, run_blueprint: String, run_counts: String) -> Dungeon/SavedScene:
  match scene_kind_maybe:
    case some{1}:
      _parse_saved_running(run_core, run_weapon, run_board, run_blueprint, run_counts)
    case _:
      saved_setup{}

def _parse_v6_sections(parts: List(String)) -> Dungeon/DungeonEvent:
  match parts:
    case selected_str<>confirmed_str<>gold_str<>monster_str<>sword_str<>potion_str<>pack_str<>profiles_str<>next_seed_str<>scene_kind_str<>run_core_str<>run_weapon_str<>run_board_str<>run_blueprint_str<>run_counts_str<>active_id_str<>next_id_str<>decks_str<>[]:
      _build_v6(
        config(),
        String/to_u32(selected_str),
        String/to_u32(confirmed_str),
        String/to_u32(gold_str),
        String/split(monster_str, ','),
        String/split(sword_str, ','),
        String/split(potion_str, ','),
        String/split(pack_str, ','),
        String/split(profiles_str, ';'),
        String/to_u32(next_seed_str),
        _parse_saved_scene_v4(
          String/to_u32(scene_kind_str),
          run_core_str,
          run_weapon_str,
          run_board_str,
          run_blueprint_str,
          run_counts_str
        ),
        String/to_u32(active_id_str),
        String/to_u32(next_id_str),
        String/split(decks_str, ';')
      )
    case _:
      no_save{}

def _parse_v4(config_value: Dungeon/Config, selected_maybe: Maybe(U32), confirmed_maybe: Maybe(U32), gold_maybe: Maybe(U32), monster_counts: List(String), sword_counts: List(String), potion_counts: List(String), pack_counts: List(String), profile_parts: List(String), next_seed_maybe: Maybe(U32), saved_scene: Dungeon/SavedScene) -> Dungeon/DungeonEvent:
  match config_value gold_maybe:
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level} some{gold}:
      base : Dungeon/Meta = meta{
        _selected_hero_value(config_value, selected_maybe),
        _selection_confirmed_value(confirmed_maybe),
        gold,
        _merge_bonus_sections(
          _parse_monster_bonus(monsters, monster_counts, 0),
          _parse_sword_bonus(swords, sword_counts, 0),
          _parse_potion_bonus(potions, potion_counts, 0)
        ),
        _parse_pack_inventory(booster_packs, pack_counts, 0),
        Dungeon/profile_helpers/default_hero_profiles(config_value),
        _initial_decks_for_config(config_value),
        Dungeon/Deck/deck_records/initial_deck_id(),
        Dungeon/Deck/deck_records/initial_deck_id() + 1
      };
      loaded{
        _parse_v3_profiles_list(heroes, profile_parts, base, 0),
        saved_scene,
        _saved_next_seed_value(next_seed_maybe)
      }
    case _:
      no_save{}

def _parse_v5_sections(parts: List(String)) -> Dungeon/DungeonEvent:
  match parts:
    case selected_str<>confirmed_str<>gold_str<>monster_str<>sword_str<>potion_str<>pack_str<>profiles_str<>next_seed_str<>scene_kind_str<>run_core_str<>run_weapon_str<>run_board_str<>run_blueprint_str<>run_counts_str<>[]:
      _parse_v4(
        config(),
        String/to_u32(selected_str),
        String/to_u32(confirmed_str),
        String/to_u32(gold_str),
        String/split(monster_str, ','),
        String/split(sword_str, ','),
        String/split(potion_str, ','),
        String/split(pack_str, ','),
        String/split(profiles_str, ';'),
        String/to_u32(next_seed_str),
        _parse_saved_scene_v4(
          String/to_u32(scene_kind_str),
          run_core_str,
          run_weapon_str,
          run_board_str,
          run_blueprint_str,
          run_counts_str
        )
      )
    case _:
      no_save{}

def _load_legacy_profile(config_value: Dungeon/Config, hero_level: U32, gold: U32, monster_counts: List(String), sword_counts: List(String), potion_counts: List(String), pack_counts: List(String), saved_scene: Dungeon/SavedScene) -> Dungeon/DungeonEvent:
  match config_value:
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level}:
      base : Dungeon/Meta = meta{
        0,
        1,
        gold,
        _merge_bonus_sections(
          _parse_monster_bonus(monsters, monster_counts, 0),
          _parse_sword_bonus(swords, sword_counts, 0),
          _parse_potion_bonus(potions, potion_counts, 0)
        ),
        _parse_pack_inventory(booster_packs, pack_counts, 0),
        Dungeon/profile_helpers/default_hero_profiles(config_value),
        _initial_decks_for_config(config_value),
        Dungeon/Deck/deck_records/initial_deck_id(),
        Dungeon/Deck/deck_records/initial_deck_id() + 1
      };
      loaded{
        Dungeon/profile_helpers/update_profile(base, 0, hero_profile{1, hero_level}),
        saved_scene,
        initial_seed()
      }

def _parse_legacy_values(hl_maybe: Maybe(U32), gold_maybe: Maybe(U32)) -> Dungeon/DungeonEvent:
  match hl_maybe gold_maybe:
    case some{hl_val} some{g_val}:
      _load_legacy_profile(config(), hl_val, g_val, [], [], [], [], saved_setup{})
    case _:
      no_save{}

def _parse_legacy_parts(parts: List(String)) -> Dungeon/DungeonEvent:
  match parts:
    case hl_str<>rest:
      match rest:
        case gold_str<>rest1:
          match rest1:
            case []:
              _parse_legacy_values(String/to_u32(hl_str), String/to_u32(gold_str))
            case _:
              no_save{}
        case _:
          no_save{}
    case _:
      no_save{}

def _parse_profile(config_value: Dungeon/Config, hl_maybe: Maybe(U32), gold_maybe: Maybe(U32), monster_counts: List(String), sword_counts: List(String), potion_counts: List(String), pack_counts: List(String), saved_scene: Dungeon/SavedScene) -> Dungeon/DungeonEvent:
  match config_value hl_maybe gold_maybe:
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level} some{hl_val} some{g_val}:
      _load_legacy_profile(config_value, hl_val, g_val, monster_counts, sword_counts, potion_counts, pack_counts, saved_scene)
    case _:
      no_save{}

def _reward_from_cards(cards: List(Dungeon/CardRef)) -> Dungeon/PackReward:
  match cards:
    case []:
      no_pack_reward{}
    case card<>rest:
      pack_reward{cards}

def _append_reward_card(card_maybe: Maybe(Dungeon/CardRef), rest: List(Dungeon/CardRef)) -> List(Dungeon/CardRef):
  match card_maybe:
    case some{card}:
      card<>rest
    case none{}:
      rest

def _parse_monster_code(is_monster: U32, code: U32) -> Maybe(Dungeon/CardRef):
  match is_monster:
    case 0:
      none{}
    case _:
      some{monster_card{code - 1000}}

def _parse_sword_code(is_sword: U32, code: U32) -> Maybe(Dungeon/CardRef):
  match is_sword:
    case 0:
      _parse_monster_code(code >= 1000, code)
    case _:
      some{sword_card{code - 2000}}

def _parse_potion_code(is_potion: U32, code: U32) -> Maybe(Dungeon/CardRef):
  match is_potion:
    case 0:
      _parse_sword_code(code >= 2000, code)
    case _:
      some{potion_card{code - 3000}}

def _parse_hero_code(is_hero: U32, code: U32) -> Maybe(Dungeon/CardRef):
  match is_hero:
    case 0:
      _parse_potion_code(code >= 3000, code)
    case _:
      some{hero_card{}}

def _parse_card_code_value(code: U32) -> Maybe(Dungeon/CardRef):
  _parse_hero_code(code === 4000, code)

def _parse_card_code(code_maybe: Maybe(U32)) -> Maybe(Dungeon/CardRef):
  match code_maybe:
    case some{code}:
      _parse_card_code_value(code)
    case none{}:
      none{}

def _parse_saved_reward_cards(parts: List(String)) -> List(Dungeon/CardRef):
  match parts:
    case []:
      []
    case head<>rest:
      _append_reward_card(_parse_card_code(String/to_u32(head)), _parse_saved_reward_cards(rest))

def _parse_saved_reward(parts: List(String)) -> Dungeon/PackReward:
  _reward_from_cards(_parse_saved_reward_cards(parts))

def _saved_reveal_index_match(in_range: U32, idx: U32, count: U32) -> U32:
  match in_range:
    case 0:
      count - 1
    case _:
      idx

def _saved_reveal_index_from_count(count: U32, reveal_index_maybe: Maybe(U32)) -> U32:
  match count reveal_index_maybe:
    case 0 some{idx}:
      0
    case 0 none{}:
      0
    case count some{idx}:
      _saved_reveal_index_match(idx < count, idx, count)
    case count none{}:
      0

def _saved_reveal_index(reward: Dungeon/PackReward, reveal_index_maybe: Maybe(U32)) -> U32:
  _saved_reveal_index_from_count(Dungeon/Boosters/reward_nav/reward_count(reward), reveal_index_maybe)

def _saved_preview_hero(config_value: Dungeon/Config, hero_ref_maybe: Maybe(U32)) -> U32:
  match hero_ref_maybe:
    case some{hero_ref}:
      Dungeon/hero_helpers/normalize_hero_ref(config_value, hero_ref)
    case none{}:
      0

def _parse_saved_scene_kind(config_value: Dungeon/Config, scene_kind: U32, reward_parts: List(String), scene_value_maybe: Maybe(U32)) -> Dungeon/SavedScene:
  match scene_kind:
    case 1:
      reward = _parse_saved_reward(reward_parts);
      saved_boosters{reward, _saved_reveal_index(reward, scene_value_maybe)}
    case 2:
      saved_character_select{_saved_preview_hero(config_value, scene_value_maybe)}
    case _:
      saved_setup{}

def _parse_saved_scene_vx(config_value: Dungeon/Config, scene_kind_maybe: Maybe(U32), reward_parts: List(String), scene_value_maybe: Maybe(U32)) -> Dungeon/SavedScene:
  match scene_kind_maybe:
    case some{scene_kind}:
      _parse_saved_scene_kind(config_value, scene_kind, reward_parts, scene_value_maybe)
    case none{}:
      saved_setup{}

def _parse_saved_scene(scene_kind_maybe: Maybe(U32), reward_parts: List(String), scene_value_maybe: Maybe(U32)) -> Dungeon/SavedScene:
  _parse_saved_scene_vx(config(), scene_kind_maybe, reward_parts, scene_value_maybe)

def _parse_legacy_sections(legacy: String, rest: List(String)) -> Dungeon/DungeonEvent:
  match rest:
    case []:
      _parse_legacy_parts(String/split(legacy, ','))
    case gold_str<>rest1:
      match rest1:
        case monster_str<>rest2:
          match rest2:
            case sword_str<>rest3:
              match rest3:
                case potion_str<>rest4:
                  match rest4:
                    case pack_str<>rest5:
                      match rest5:
                        case []:
                          _parse_profile(
                            config(),
                            String/to_u32(legacy),
                            String/to_u32(gold_str),
                            String/split(monster_str, ','),
                            String/split(sword_str, ','),
                            String/split(potion_str, ','),
                            String/split(pack_str, ','),
                            saved_setup{}
                          )
                        case scene_kind_str<>rest6:
                          match rest6:
                            case reward_str<>rest7:
                              match rest7:
                                case reveal_index_str<>rest8:
                                  match rest8:
                                    case []:
                                      _parse_profile(
                                        config(),
                                        String/to_u32(legacy),
                                        String/to_u32(gold_str),
                                        String/split(monster_str, ','),
                                        String/split(sword_str, ','),
                                        String/split(potion_str, ','),
                                        String/split(pack_str, ','),
                                        _parse_saved_scene(
                                          String/to_u32(scene_kind_str),
                                          String/split(reward_str, ','),
                                          String/to_u32(reveal_index_str)
                                        )
                                      )
                                    case _:
                                      no_save{}
                                case _:
                                  no_save{}
                            case _:
                              no_save{}
                        case _:
                          no_save{}
                    case _:
                      no_save{}
                case _:
                  no_save{}
            case _:
              no_save{}
        case _:
          no_save{}
    case _:
      no_save{}

def _has_level_progress(hero_level: U32) -> U32:
  match hero_level:
    case 0:
      0
    case _:
      1

def _migrated_unlock_selected(is_selected: U32, hero_level: U32) -> U32:
  match is_selected:
    case 0:
      _has_level_progress(hero_level)
    case _:
      1

def _migrated_unlock_first(is_first: U32, hero_ref: U32, selected_ref: U32, hero_level: U32) -> U32:
  match is_first:
    case 0:
      _migrated_unlock_selected(hero_ref === selected_ref, hero_level)
    case _:
      1

def _migrated_unlock_value(hero_ref: U32, selected_ref: U32, hero_level: U32) -> U32:
  _migrated_unlock_first(hero_ref === 0, hero_ref, selected_ref, hero_level)

def _add_pack_count(entries: List(Dungeon/PackInventoryEntry), ref: U32, count: U32) -> List(Dungeon/PackInventoryEntry):
  match count:
    case 0:
      entries
    case _:
      _add_pack_count(Dungeon/Boosters/inventory/add_pack(entries, ref), ref, count - 1)

def _merge_pack_inventories(base: List(Dungeon/PackInventoryEntry), extra: List(Dungeon/PackInventoryEntry)) -> List(Dungeon/PackInventoryEntry):
  match extra:
    case []:
      base
    case pack_inventory_entry{ref, count}<>rest:
      _merge_pack_inventories(_add_pack_count(base, ref, count), rest)

def _migrate_v2_profile_data(monsters: List(Dungeon/MonsterDef), swords: List(Dungeon/SwordDef), potions: List(Dungeon/PotionDef), booster_packs: List(Dungeon/PackDef), selected_ref: U32, hero_ref: U32, hero_level: U32, gold: U32, monster_counts: List(String), sword_counts: List(String), potion_counts: List(String), pack_counts: List(String), meta_state: Dungeon/Meta) -> Dungeon/Meta:
  next_bonus = _merge_bonus_sections(
    _parse_monster_bonus(monsters, monster_counts, 0),
    _parse_sword_bonus(swords, sword_counts, 0),
    _parse_potion_bonus(potions, potion_counts, 0)
  );
  next_inventory = _parse_pack_inventory(booster_packs, pack_counts, 0);
  next_meta = Dungeon/profile_helpers/set_meta_gold(meta_state, Dungeon/profile_helpers/meta_gold(meta_state) + gold);
  next_meta = Dungeon/profile_helpers/set_meta_bonus_deck(next_meta, Dungeon/Deck/counts_pick/merge_deck_entries(Dungeon/profile_helpers/meta_bonus_deck(next_meta), next_bonus));
  next_meta = Dungeon/profile_helpers/set_meta_pack_inventory(next_meta, _merge_pack_inventories(Dungeon/profile_helpers/meta_pack_inventory(next_meta), next_inventory));
  Dungeon/profile_helpers/update_profile(next_meta, hero_ref, hero_profile{_migrated_unlock_value(hero_ref, selected_ref, hero_level), hero_level})

def _apply_v2_profile_values(monsters: List(Dungeon/MonsterDef), swords: List(Dungeon/SwordDef), potions: List(Dungeon/PotionDef), booster_packs: List(Dungeon/PackDef), selected_ref: U32, hero_ref: U32, hero_level_maybe: Maybe(U32), gold_maybe: Maybe(U32), monster_counts: List(String), sword_counts: List(String), potion_counts: List(String), pack_counts: List(String), meta_state: Dungeon/Meta) -> Dungeon/Meta:
  match hero_level_maybe gold_maybe:
    case some{hero_level} some{gold}:
      _migrate_v2_profile_data(
        monsters,
        swords,
        potions,
        booster_packs,
        selected_ref,
        hero_ref,
        hero_level,
        gold,
        monster_counts,
        sword_counts,
        potion_counts,
        pack_counts,
        meta_state
      )
    case _:
      meta_state

def _apply_v2_profile_segment(monsters: List(Dungeon/MonsterDef), swords: List(Dungeon/SwordDef), potions: List(Dungeon/PotionDef), booster_packs: List(Dungeon/PackDef), selected_ref: U32, hero_ref: U32, parts: List(String), meta_state: Dungeon/Meta) -> Dungeon/Meta:
  match parts:
    case hero_level_str<>rest:
      match rest:
        case gold_str<>rest1:
          match rest1:
            case monster_str<>rest2:
              match rest2:
                case sword_str<>rest3:
                  match rest3:
                    case potion_str<>rest4:
                      match rest4:
                        case pack_str<>rest5:
                          match rest5:
                            case []:
                              _apply_v2_profile_values(
                                monsters,
                                swords,
                                potions,
                                booster_packs,
                                selected_ref,
                                hero_ref,
                                String/to_u32(hero_level_str),
                                String/to_u32(gold_str),
                                String/split(monster_str, ','),
                                String/split(sword_str, ','),
                                String/split(potion_str, ','),
                                String/split(pack_str, ','),
                                meta_state
                              )
                            case _:
                              meta_state
                        case _:
                          meta_state
                    case _:
                      meta_state
                case _:
                  meta_state
            case _:
              meta_state
        case _:
          meta_state
    case _:
      meta_state

def _parse_v2_profiles_list(monsters: List(Dungeon/MonsterDef), swords: List(Dungeon/SwordDef), potions: List(Dungeon/PotionDef), booster_packs: List(Dungeon/PackDef), heroes: List(Dungeon/HeroDef), profile_parts: List(String), meta_state: Dungeon/Meta, selected_ref: U32, hero_ref: U32) -> Dungeon/Meta:
  match heroes:
    case []:
      meta_state
    case hero_def{id, name, sprite, base_max_hp, unlock_cost, starts_unlocked, upgrades}<>hero_rest:
      match profile_parts:
        case []:
          meta_state
        case part<>rest:
          _parse_v2_profiles_list(
            monsters,
            swords,
            potions,
            booster_packs,
            hero_rest,
            rest,
            _apply_v2_profile_segment(monsters, swords, potions, booster_packs, selected_ref, hero_ref, String/split(part, '~'), meta_state),
            selected_ref,
            hero_ref + 1
          )

def _parse_v2(config_value: Dungeon/Config, selected_maybe: Maybe(U32), confirmed_maybe: Maybe(U32), profile_parts: List(String), saved_scene: Dungeon/SavedScene) -> Dungeon/DungeonEvent:
  match config_value:
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level}:
      selected_ref = _selected_hero_value(config_value, selected_maybe);
      base : Dungeon/Meta = meta{
        selected_ref,
        _selection_confirmed_value(confirmed_maybe),
        0,
        [],
        [],
        Dungeon/profile_helpers/default_hero_profiles(config_value),
        _initial_decks_for_config(config_value),
        Dungeon/Deck/deck_records/initial_deck_id(),
        Dungeon/Deck/deck_records/initial_deck_id() + 1
      };
      loaded{
        _parse_v2_profiles_list(monsters, swords, potions, booster_packs, heroes, profile_parts, base, selected_ref, 0),
        saved_scene,
        initial_seed()
      }

def _parse_v2_sections(parts: List(String)) -> Dungeon/DungeonEvent:
  match parts:
    case selected_str<>confirmed_str<>profiles_str<>scene_kind_str<>reward_str<>scene_value_str<>[]:
      _parse_v2(
        config(),
        String/to_u32(selected_str),
        String/to_u32(confirmed_str),
        String/split(profiles_str, ';'),
        _parse_saved_scene_vx(
          config(),
          String/to_u32(scene_kind_str),
          String/split(reward_str, ','),
          String/to_u32(scene_value_str)
        )
      )
    case _:
      no_save{}

def _parse_v3(config_value: Dungeon/Config, selected_maybe: Maybe(U32), confirmed_maybe: Maybe(U32), gold_maybe: Maybe(U32), monster_counts: List(String), sword_counts: List(String), potion_counts: List(String), pack_counts: List(String), profile_parts: List(String), saved_scene: Dungeon/SavedScene) -> Dungeon/DungeonEvent:
  match config_value gold_maybe:
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level} some{gold}:
      base : Dungeon/Meta = meta{
        _selected_hero_value(config_value, selected_maybe),
        _selection_confirmed_value(confirmed_maybe),
        gold,
        _merge_bonus_sections(
          _parse_monster_bonus(monsters, monster_counts, 0),
          _parse_sword_bonus(swords, sword_counts, 0),
          _parse_potion_bonus(potions, potion_counts, 0)
        ),
        _parse_pack_inventory(booster_packs, pack_counts, 0),
        Dungeon/profile_helpers/default_hero_profiles(config_value),
        _initial_decks_for_config(config_value),
        Dungeon/Deck/deck_records/initial_deck_id(),
        Dungeon/Deck/deck_records/initial_deck_id() + 1
      };
      loaded{
        _parse_v3_profiles_list(heroes, profile_parts, base, 0),
        saved_scene,
        initial_seed()
      }
    case _:
      no_save{}

def _parse_v3_sections(parts: List(String)) -> Dungeon/DungeonEvent:
  match parts:
    case selected_str<>confirmed_str<>gold_str<>monster_str<>sword_str<>potion_str<>pack_str<>profiles_str<>scene_kind_str<>reward_str<>scene_value_str<>[]:
      _parse_v3(
        config(),
        String/to_u32(selected_str),
        String/to_u32(confirmed_str),
        String/to_u32(gold_str),
        String/split(monster_str, ','),
        String/split(sword_str, ','),
        String/split(potion_str, ','),
        String/split(pack_str, ','),
        String/split(profiles_str, ';'),
        _parse_saved_scene_vx(
          config(),
          String/to_u32(scene_kind_str),
          String/split(reward_str, ','),
          String/to_u32(scene_value_str)
        )
      )
    case _:
      no_save{}

def _parse_sections_head(head: String, rest: List(String)) -> Dungeon/DungeonEvent:
  match String/eq(head, "v7"):
    case true{}:
      _parse_v6_sections(rest)
    case false{}:
      match String/eq(head, "v6"):
        case true{}:
          _parse_v6_sections(rest)
        case false{}:
          match String/eq(head, "v5"):
            case true{}:
              _parse_v5_sections(rest)
            case false{}:
              match String/eq(head, "v4"):
                case true{}:
                  no_save{}
                case false{}:
                  match String/eq(head, "v3"):
                    case true{}:
                      _parse_v3_sections(rest)
                    case false{}:
                      match String/eq(head, "v2"):
                        case true{}:
                          _parse_v2_sections(rest)
                        case false{}:
                          _parse_legacy_sections(head, rest)

def _parse_sections(parts: List(String)) -> Dungeon/DungeonEvent:
  match parts:
    case head<>rest:
      _parse_sections_head(head, rest)
    case _:
      no_save{}

def _parse_meta(s: String) -> Dungeon/DungeonEvent:
  _parse_sections(String/split(s, '|'))
