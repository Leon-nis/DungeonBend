import Dungeon/DeckEntry as DeckEntry
import Dungeon/default_meta as default_meta
import Dungeon/deckbuilder_helpers/add_one_to_draft as add_one_to_draft
import Dungeon/deckbuilder_helpers/collection_deck as collection_deck

# === Deck — laws mirroring design-rules.md §"Deck" ===
#
# The deck represents the player's card inventory. Types referenced
# (DeckEntry) are defined in /src/Dungeon/_.bend. Laws here focus on
# duplicates-allowed and the in-run capacity cap.

# "The deck can contain duplicated cards, both inside and outside
# of a run." Duplicates are represented by DeckEntry.count > 1.
assert deck_entry_allows_duplicates_monster:
  monster_entry{0, 5} == monster_entry{0, 5} :: DeckEntry

assert deck_entry_allows_duplicates_sword:
  sword_entry{0, 3} == sword_entry{0, 3} :: DeckEntry

assert deck_entry_allows_duplicates_potion:
  potion_entry{0, 2} == potion_entry{0, 2} :: DeckEntry

# "A hero card in the deck is represented by hero_entry."
assert deck_entry_hero:
  hero_entry{1} == hero_entry{1} :: DeckEntry

# "The deck can grow without a fixed limit" outside runs — the
# inventory is a plain List(DeckEntry) so it has no compile-time
# cap. Concrete 3-entry inventory:
assert inventory_open_ended:
  [monster_entry{0, 1}, sword_entry{0, 1}, potion_entry{0, 1}]
    == [monster_entry{0, 1}, sword_entry{0, 1}, potion_entry{0, 1}]
    :: List(DeckEntry)

# A deckbuilder add action cannot create cards once the stash is empty.
assert deckbuilder_add_one_respects_exhausted_stash:
  add_one_to_draft(default_meta(), collection_deck(default_meta()), monster_card{0})
    == collection_deck(default_meta())
    :: List(DeckEntry)
