from typing import Any, Dict
from kitty.boss import Boss
from kitty.window import Window

FOCUSED_BG = "#222436"  # Tokyo Night Moon background (brighter)
UNFOCUSED_BG = "#0f0f0f"  # Much darker for clear unfocused indication


def on_focus_change(boss: Boss, window: Window, data: Dict[str, Any]) -> None:
    if data["focused"]:
        change_background(boss, window, FOCUSED_BG)
    else:
        change_background(boss, window, UNFOCUSED_BG)


def change_background(boss: Boss, window: Window, color: str) -> None:
    boss.call_remote_control(
        window, ("set-colors", f"--match=id:{window.id}", f"background={color}")
    )
