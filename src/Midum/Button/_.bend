type Button {
  button__module{}
}

import Midum/Config as M__Midum_Config
import Midum/Internal/DOM/Button as M__Midum_Internal_DOM_Button
# Public button API for Midum.
#
# The public surface stays renderer-neutral. The current renderer lives under
# /Midum/Internal/DOM/.

import HTML as HTML

def apply_override(cfg: Midum/Button/Config, override: Midum/Button/Override) -> Midum/Button/Config:
  match cfg override:
    case button{text, icon, shape, size, width, state} icon_off{}:
      button{text, icon: off{}, shape, size, width, state}
    case button{text, icon, shape, size, width, state} icon_left{src}:
      button{text, icon: left{src}, shape, size, width, state}
    case button{text, icon, shape, size, width, state} icon_right{src}:
      button{text, icon: right{src}, shape, size, width, state}
    case button{text, icon, shape, size, width, state} shape_square{}:
      button{text, icon, shape: square{}, size, width, state}
    case button{text, icon, shape, size, width, state} shape_rounded{}:
      button{text, icon, shape: rounded{}, size, width, state}
    case button{text, icon, shape, size, width, state} width_fit{}:
      button{text, icon, shape, size, width: fit{}, state}
    case button{text, icon, shape, size, width, state} width_wide{}:
      button{text, icon, shape, size, width: wide{}, state}
    case button{text, icon, shape, size, width, state} width_full{}:
      button{text, icon, shape, size, width: full{}, state}
    case button{text, icon, shape, size, width, state} state_enabled{}:
      button{text, icon, shape, size, width, state: enabled{}}
    case button{text, icon, shape, size, width, state} state_disabled{}:
      button{text, icon, shape, size, width, state: disabled{}}

def apply_overrides(cfg: Midum/Button/Config, overrides: List(Midum/Button/Override)) -> Midum/Button/Config:
  match overrides:
    case []:
      cfg
    case override<>rest:
      apply_overrides(apply_override(cfg, override), rest)

def config_with_defaults(defaults: Midum/Button/Defaults, text: String, size: Midum/Button/Size, overrides: List(Midum/Button/Override)) -> Midum/Button/Config:
  match defaults:
    case defaults{icon, shape, width, state}:
      apply_overrides(button{text, icon, shape, size, width, state}, overrides)

def config(text: String, size: Midum/Button/Size, overrides: List(Midum/Button/Override)) -> Midum/Button/Config:
  config_with_defaults(Midum/Config/button_defaults(), text, size, overrides)

def primary(Event: Type, evt: Event, size: Midum/Button/Size, text: String, overrides: List(Midum/Button/Override)) -> HTML(Event):
  Midum/Internal/DOM/Button/primary(Event, evt, config(text, size, overrides))

def catoon_yellow(Event: Type, evt: Event, size: Midum/Button/Size, text: String, overrides: List(Midum/Button/Override)) -> HTML(Event):
  Midum/Internal/DOM/Button/catoon_yellow(Event, evt, config(text, size, overrides))

def catoon_dark(Event: Type, evt: Event, size: Midum/Button/Size, text: String, overrides: List(Midum/Button/Override)) -> HTML(Event):
  Midum/Internal/DOM/Button/catoon_dark(Event, evt, config(text, size, overrides))

def catoon_dark_counter(Event: Type, evt: Event, size: Midum/Button/Size, text: String, count: String, overrides: List(Midum/Button/Override)) -> HTML(Event):
  Midum/Internal/DOM/Button/catoon_dark_counter(Event, evt, config(text, size, overrides), count)

def catoon(Event: Type, evt: Event, size: Midum/Button/Size, text: String, overrides: List(Midum/Button/Override)) -> HTML(Event):
  catoon_yellow(Event, evt, size, text, overrides)

def catoon_secondary(Event: Type, evt: Event, size: Midum/Button/Size, text: String, overrides: List(Midum/Button/Override)) -> HTML(Event):
  catoon_dark(Event, evt, size, text, overrides)

def secondary(Event: Type, evt: Event, size: Midum/Button/Size, text: String, overrides: List(Midum/Button/Override)) -> HTML(Event):
  Midum/Internal/DOM/Button/secondary(Event, evt, config(text, size, overrides))

def neutral(Event: Type, evt: Event, size: Midum/Button/Size, text: String, overrides: List(Midum/Button/Override)) -> HTML(Event):
  Midum/Internal/DOM/Button/neutral(Event, evt, config(text, size, overrides))

def success(Event: Type, evt: Event, size: Midum/Button/Size, text: String, overrides: List(Midum/Button/Override)) -> HTML(Event):
  Midum/Internal/DOM/Button/success(Event, evt, config(text, size, overrides))

def warning(Event: Type, evt: Event, size: Midum/Button/Size, text: String, overrides: List(Midum/Button/Override)) -> HTML(Event):
  Midum/Internal/DOM/Button/warning(Event, evt, config(text, size, overrides))

def danger(Event: Type, evt: Event, size: Midum/Button/Size, text: String, overrides: List(Midum/Button/Override)) -> HTML(Event):
  Midum/Internal/DOM/Button/danger(Event, evt, config(text, size, overrides))
