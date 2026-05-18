type Card {
  card__module{}
}

import Midum/Config as M__Midum_Config
import Midum/Internal/DOM/Card as M__Midum_Internal_DOM_Card
# Public card API for Midum.
#
# Cards stay renderer-neutral. The current renderer lives under
# /Midum/Internal/DOM/.

import HTML as HTML

def apply_override(cfg: Midum/Card/Config, override: Midum/Card/Override) -> Midum/Card/Config:
  match cfg override:
    case card{padding, radius, background, border, gradient, surface} padding_none{}:
      card{padding: none{}, radius, background, border, gradient, surface}
    case card{padding, radius, background, border, gradient, surface} padding_sm{}:
      card{padding: sm{}, radius, background, border, gradient, surface}
    case card{padding, radius, background, border, gradient, surface} padding_md{}:
      card{padding: md{}, radius, background, border, gradient, surface}
    case card{padding, radius, background, border, gradient, surface} padding_lg{}:
      card{padding: lg{}, radius, background, border, gradient, surface}
    case card{padding, radius, background, border, gradient, surface} background_none{}:
      card{padding, radius, background: background_off{}, border, gradient, surface}
    case card{padding, radius, background, border, gradient, surface} border_none{}:
      card{padding, radius, background, border: border_off{}, gradient, surface}
    case card{padding, radius, background, border, gradient, surface} radius_square{}:
      card{padding, radius: square{}, background, border, gradient, surface}
    case card{padding, radius, background, border, gradient, surface} radius_rounded{}:
      card{padding, radius: rounded{}, background, border, gradient, surface}
    case card{padding, radius, background, border, gradient, surface} gradient{}:
      card{padding, radius, background, border, gradient: gradient_on{}, surface}
    case card{padding, radius, background, border, gradient, surface} surface_image{src, left, right, top, bottom}:
      card{
        padding,
        radius,
        background,
        border,
        gradient,
        surface: surface_image{
          src,
          source_left: left,
          source_right: right,
          source_top: top,
          source_bottom: bottom,
          target_left: left,
          target_right: right,
          target_top: top,
          target_bottom: bottom,
        }
      }
    case card{padding, radius, background, border, gradient, surface} surface_image_sized{src, source_left, source_right, source_top, source_bottom, target_left, target_right, target_top, target_bottom}:
      card{
        padding,
        radius,
        background,
        border,
        gradient,
        surface: surface_image{src, source_left, source_right, source_top, source_bottom, target_left, target_right, target_top, target_bottom}
      }

def apply_overrides(cfg: Midum/Card/Config, overrides: List(Midum/Card/Override)) -> Midum/Card/Config:
  match overrides:
    case []:
      cfg
    case override<>rest:
      apply_overrides(apply_override(cfg, override), rest)

def config_with_defaults(defaults: Midum/Card/Defaults, overrides: List(Midum/Card/Override)) -> Midum/Card/Config:
  match defaults:
    case defaults{padding, radius}:
      apply_overrides(card{padding, radius, background: background_on{}, border: border_on{}, gradient: gradient_off{}, surface: surface_off{}}, overrides)

def config(overrides: List(Midum/Card/Override)) -> Midum/Card/Config:
  config_with_defaults(Midum/Config/card_defaults(), overrides)

def primary(Event: Type, body: HTML(Event), overrides: List(Midum/Card/Override)) -> HTML(Event):
  Midum/Internal/DOM/Card/primary(Event, body, config(overrides))

def secondary(Event: Type, body: HTML(Event), overrides: List(Midum/Card/Override)) -> HTML(Event):
  Midum/Internal/DOM/Card/secondary(Event, body, config(overrides))

def neutral(Event: Type, body: HTML(Event), overrides: List(Midum/Card/Override)) -> HTML(Event):
  Midum/Internal/DOM/Card/neutral(Event, body, config(overrides))

def success(Event: Type, body: HTML(Event), overrides: List(Midum/Card/Override)) -> HTML(Event):
  Midum/Internal/DOM/Card/success(Event, body, config(overrides))

def warning(Event: Type, body: HTML(Event), overrides: List(Midum/Card/Override)) -> HTML(Event):
  Midum/Internal/DOM/Card/warning(Event, body, config(overrides))

def danger(Event: Type, body: HTML(Event), overrides: List(Midum/Card/Override)) -> HTML(Event):
  Midum/Internal/DOM/Card/danger(Event, body, config(overrides))
