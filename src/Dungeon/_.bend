type Upgrade {
  upgrade{cost: U32, max_hp: U32}
}

type HeroDef {
  hero_def{
    id: String,
    name: String,
    sprite: String,
    base_max_hp: U32,
    unlock_cost: U32,
    starts_unlocked: U32,
    upgrades: List(Upgrade),
    ultimate_kind: UltimateKind,
    ultimate_charge_required: U32,
    passive: PassiveDef
  }
}

type PassiveDef {
  passive_none{}
  passive_weapon_accumulator_same_class{}
}

type UltimateKind {
  ultimate_refill{}
  ultimate_shadow_step{}
  ultimate_shadow_clone{}
}

type PresentationAlign {
  presentation_left{}
  presentation_center{}
  presentation_right{}
}

type HeroPresentation {
  hero_presentation{
    hero_id: String,
    name_align: PresentationAlign,
    lore: String,
    ultimate_title: String,
    ultimate_icon: String,
    ultimate_description: String,
    passive_visible: U32,
    passive_title: String,
    passive_description: String
  }
}

type MonsterClass {
  monster_normal{}
  monster_champion{}
  monster_boss{}
}

type LootRarity {
  loot_common{}
  loot_uncommon{}
  loot_rare{}
  loot_epic{}
}

type WeaponClass {
  weapon_sword{}
  weapon_axe{}
  weapon_bow{}
}

type CardRarity {
  card_rarity_monster{}
  card_rarity_consumable{loot_rarity: LootRarity}
  card_rarity_equipment{loot_rarity: LootRarity}
}

type MonsterDef {
  monster_def{name: String, sprite: String, class_kind: MonsterClass, tier: U32, rarity: CardRarity, gold_levels: List(U32), hp_levels: List(U32)}
}

type SwordDef {
  sword_def{name: String, sprite: String, rarity: CardRarity, class_kind: WeaponClass, dmg: U32}
}

type PotionDef {
  potion_def{name: String, sprite: String, rarity: CardRarity, heal: U32}
}

type DeckEntry {
  monster_entry{ref: U32, count: U32}
  sword_entry{ref: U32, count: U32}
  potion_entry{ref: U32, count: U32}
  hero_entry{count: U32}
}

type CardRef {
  monster_card{ref: U32}
  sword_card{ref: U32}
  potion_card{ref: U32}
  hero_card{}
}

type PackPoolEntry {
  pack_pool_entry{card: CardRef, weight: U32}
}

type PackDef {
  pack_def{
    name: String,
    price: U32,
    reveal_count: U32,
    allow_duplicates: U32,
    pool: List(PackPoolEntry)
  }
}

type PackReward {
  no_pack_reward{}
  pack_reward{cards: List(CardRef)}
}

type PackOpenResult {
  pack_open_result{reward: PackReward, seed: U32}
}

type PackInventoryEntry {
  pack_inventory_entry{ref: U32, count: U32}
}

type Direction {
  up{}
  down{}
  left{}
  right{}
}

type Weapon {
  no_weapon{}
  weapon{class_kind: WeaponClass, dmg: U32}
}

type Tile {
  none{}
  shadow{}
  monster{ref: U32, hp: U32, spawn_level: U32}
  sword{ref: U32, dmg: U32}
  potion{ref: U32, heal: U32}
  gold{amount: U32}
}

type UltimateState {
  ultimate_state_idle{}
  ultimate_state_projection_armed{}
  ultimate_state_shadow_step_live{}
  ultimate_state_shadow_clone_live{}
}

type Board {
  board{cells: Nat/V2/Map(Tile)}
}

type BoardDraw {
  board_draw{
    board: Board,
    counts: List(DeckEntry),
    remaining: U32,
    seed: U32,
    level: U32
  }
}

type DrawResult {
  draw_result{
    tile: Tile,
    counts: List(DeckEntry),
    remaining: U32,
    seed: U32,
    level: U32
  }
}

type CombatOutcome {
  combat_continue{}
  combat_game_over{}
}

type CombatResult {
  combat_result{
    hero_hp: U32,
    weapon: Weapon,
    board: Board,
    outcome: CombatOutcome
  }
}

type HeroProfile {
  hero_profile{
    unlocked: U32,
    hero_level: U32
  }
}

type RunStats {
  run_stats{
    gold_collected: U32,
    items_collected: U32,
    weapon_damage_gained: U32,
    potion_heal_effective: U32,
    monsters_defeated: U32,
    damage_dealt: U32,
    monster_level_sum: U32,
    monster_level_count: U32,
    path_center: U32,
    path_edge: U32,
    path_corner: U32
  }
}

type Meta {
  meta{
    selected_hero: U32,
    selection_confirmed: U32,
    gold: U32,
    bonus_deck: List(DeckEntry),
    selected_deck: List(DeckEntry),
    pack_inventory: List(PackInventoryEntry),
    hero_profiles: List(HeroProfile)
  }
}

type Config {
  config{
    heroes: List(HeroDef),
    monsters: List(MonsterDef),
    swords: List(SwordDef),
    potions: List(PotionDef),
    deck: List(DeckEntry),
    booster_packs: List(PackDef),
    starting_dungeon_level: U32
  }
}

type Run {
  run{
    dungeon_level: U32,
    hero_hp: U32,
    hero_max_hp: U32,
    hero_index: U32,
    weapon: Weapon,
    board: Board,
    deck_blueprint: List(DeckEntry),
    draw_counts: List(DeckEntry),
    remaining: U32,
    capacity: U32,
    seed: U32,
    ult_charge: U32,
    hero_ref: U32,
    ultimate_state: UltimateState,
    stats: RunStats
  }
}

type RunAdvance {
  keep_running{run: Run}
  end_run{run: Run}
}

type SwipeResult {
  swipe_result{meta: Meta, next: RunAdvance}
}

type BoosterReturn {
  booster_return_setup{}
  booster_return_character_select{preview_hero: U32}
}

type DeckbuilderSelection {
  no_deckbuilder_selection{}
  deckbuilder_selection{card: CardRef}
}

type DeckbuilderNotice {
  no_deckbuilder_notice{}
  deckbuilder_notice{text: String}
}

type Scene {
  setup{}
  character_select{preview_hero: U32}
  deckbuilder{
    draft_deck: List(DeckEntry),
    deck_selection: DeckbuilderSelection,
    stash_selection: DeckbuilderSelection,
    deck_scroll: U32,
    stash_scroll: U32,
    action_notice: DeckbuilderNotice
  }
  boosters{reward: PackReward, reveal_index: U32, return_to: BoosterReturn}
  ultimate_preview{fx: UltimatePreviewFx}
  ultimate_cinematic{run: Run, ticks_remaining: U32}
  running{run: Run}
  paused{run: Run}
  resume_prompt{run: Run}
  run_report{run: Run}
  game_over{run: Run}
}

type SavedScene {
  saved_setup{}
  saved_character_select{preview_hero: U32}
  saved_boosters{reward: PackReward, reveal_index: U32}
  saved_running{run: Run}
}

type GameState {
  game_state{meta: Meta, scene: Scene, next_seed: U32}
}

type HpFx {
  hp_fx_none{}
  hp_fx_heal_a{}
  hp_fx_heal_b{}
  hp_fx_hurt_a{}
  hp_fx_hurt_b{}
}

type DmgFx {
  dmg_fx_none{}
  dmg_fx_up_a{}
  dmg_fx_up_b{}
  dmg_fx_down_a{}
  dmg_fx_down_b{}
}

type ImpactFx {
  impact_hit_a{}
  impact_hit_b{}
  impact_kill_a{}
  impact_kill_b{}
}

type Impact {
  no_impact{}
  impact{pos: Nat/V2, fx: ImpactFx}
}

type DamageOverlay {
  no_damage_overlay{}
  damage_overlay{pos: Nat/V2, trigger: ImpactFx, base_tile: Tile, state: Midum/Image/State}
}

type DeckCounterFx {
  deck_counter_idle{}
  deck_counter_playing{state: Midum/Image/State}
}

type UltimatePreviewFx {
  ultimate_preview_idle{}
  ultimate_preview_play_a{}
  ultimate_preview_play_b{}
}

type UltimateCutinSpec {
  ultimate_cutin_spec{
    banner_src: String,
    character_src: String,
    desktop_y_offset: String,
    mobile_y_offset: String,
    character_width: String,
    band_height: String,
    duration_ticks: U32,
    sound_placeholder: String
  }
}

type UiState {
  ui_state{hp_fx: HpFx, dmg_fx: DmgFx, impact: Impact, damage_overlay: DamageOverlay, deck_counter_fx: DeckCounterFx}
}

type DungeonState {
  dungeon{game: GameState, ui: UiState}
}

type DungeonEvent {
  start{}
  upgrade{}
  open_character_select{}
  close_character_select{}
  open_deckbuilder{}
  close_deckbuilder{}
  save_deckbuilder{}
  deckbuilder_toggle_list{}
  deckbuilder_select_deck{card: CardRef}
  deckbuilder_select_stash{card: CardRef}
  deckbuilder_scroll_deck_up{}
  deckbuilder_scroll_deck_down{}
  deckbuilder_scroll_stash_up{}
  deckbuilder_scroll_stash_down{}
  deckbuilder_add_one{}
  deckbuilder_add_all{}
  deckbuilder_remove_one{}
  deckbuilder_remove_all{}
  open_ultimate_preview{}
  close_ultimate_preview{}
  preview_character{ref: U32}
  select_character{}
  open_boosters{}
  close_boosters{}
  buy_pack{ref: U32}
  open_pack{ref: U32}
  prev_reward{}
  next_reward{}
  done_reward{}
  play_ultimate_preview{}
  ultimate{}
  move{dir: Direction}
  damage_tick{}
  ok{}
  pause_dungeon{}
  resume_dungeon{}
  abandon_dungeon{}
  ignore{}
  loaded{meta: Meta, saved_scene: SavedScene, next_seed: U32}
  no_save{}
}

type _PickResult {
  no_pick{counts: List(DeckEntry)}
  picked_entry{entry: DeckEntry, counts: List(DeckEntry)}
}

type _PackPickResult {
  no_pack_pick{pool: List(PackPoolEntry)}
  picked_pack_entry{card: CardRef, pool: List(PackPoolEntry)}
}
