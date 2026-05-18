type Midum {
  midum__module{}
}

import Midum/Config as M__Midum_Config
import Midum/Internal/DOM/Card as M__Midum_Internal_DOM_Card
import Midum/Internal/DOM/Layout as M__Midum_Internal_DOM_Layout
import Midum/Internal/DOM/Text as M__Midum_Internal_DOM_Text
import Midum/Internal/DOM/Theme as M__Midum_Internal_DOM_Theme
# Public Midum entrypoint.
#
# The public API stays renderer-neutral. Today, screen() is implemented by the
# internal DOM renderer.

import HTML as HTML
import Midum/Internal/DOM/Button/base_css as button_base_css
import Midum/Internal/DOM/Button/catoon_css as button_catoon_css
import Midum/Internal/DOM/Button/role_css as button_role_css
import Midum/Internal/DOM/Button/style_css as button_style_css
import Midum/Internal/DOM/Grid/base_css as grid_css
import Midum/Internal/DOM/Image/base_css as image_css

def screen(Event: Type, body: HTML(Event)) -> HTML(Event):
  <main class={"bc-font-ui " ++ Midum/Internal/DOM/Theme/root_class(Midum/Config/palette(), Midum/Config/style())}>
    <style>{text{Midum/Internal/DOM/Theme/base_css()}}</style>
    <style>{text{Midum/Internal/DOM/Theme/orange_css()}}</style>
    <style>{text{Midum/Internal/DOM/Theme/olive_css()}}</style>
    <style>{text{Midum/Internal/DOM/Layout/css()}}</style>
    <style>{text{grid_css()}}</style>
    <style>{text{image_css()}}</style>
    <style>{text{Midum/Internal/DOM/Card/base_css()}}</style>
    <style>{text{Midum/Internal/DOM/Card/role_css()}}</style>
    <style>{text{Midum/Internal/DOM/Card/style_css()}}</style>
    <script>
      {text{Midum/Internal/DOM/Card/surface_script_0()}}
      {text{Midum/Internal/DOM/Card/surface_script_1()}}
      {text{Midum/Internal/DOM/Card/surface_script_2()}}
      {text{Midum/Internal/DOM/Card/surface_script_3()}}
    </script>
    <style>{text{button_base_css()}}</style>
    <style>{text{button_role_css()}}</style>
    <style>{text{button_style_css()}}</style>
    <style>{text{button_catoon_css()}}</style>
    <style>{text{Midum/Internal/DOM/Text/css()}}</style>
    {body}
  </main>
