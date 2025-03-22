from libqtile import bar, layout, widget, hook
from libqtile import extension, qtile
from libqtile.config import Click, Drag, Group, Key, Match, Screen, KeyChord
from libqtile.lazy import lazy
from re import findall
from os import path
from io import open
from libqtile.log_utils import logger

try:
    from libqtile.backend.wayland import InputConfig
except ImportError:
    pass

import subprocess

mod        = "mod4"
alt        = "mod1"
g_home = path.expanduser('~')
theme_file = "colors-terminal.sexy-4"

def get_backend():
    if qtile.core.name == "wayland":
        return "W"
    else:
        return "X"

backend_opts_map = {
        "X": {  "terminal": "alacritty"
              , "windows": lazy.spawn("mxctl.control dmenu_select_window")
              , "input_rules": None
              , "keys": []
              },
        "W": {  "terminal": "foot"
              , "windows": lazy.spawn("mxctl.control dmenu_select_window")
              , "input_rules": {
                  "*": InputConfig(left_handed=False, tap=True),
                  "type:pointer": InputConfig(left_handed=False, tap=True),
                  "type:keyboard": InputConfig(kb_options="ctrl:nocaps,compose:ralt"),

                  # actual device using `qtile cmd-obj -o core -f get_inputs`
                  "1267:12608:MSFT0001:01 04F3:3140 Touchpad": InputConfig(left_handed=False, tap=True, dwt=True),
                  }
              , "keys": [  Key([alt, "control"], "F1", lazy.change_vt(1))
                         , Key([alt, "control"], "F2", lazy.change_vt(2))
                         , Key([alt, "control"], "F3", lazy.change_vt(3))
                         , Key([alt, "control"], "F4", lazy.change_vt(4))
                         , Key([alt, "control"], "F5", lazy.change_vt(5))
                         , Key([alt, "control"], "F6", lazy.change_vt(6))
                  ]
              },
             
        }    

backend_opts = backend_opts_map[get_backend()]

terminal = backend_opts["terminal"]

def parse_terminal_sexy():
    home = path.expanduser('~/')
    theme_path = home + '.config/xresources.d/'+theme_file
    f = open(theme_path, 'r')
    theme = dict(
        findall(r'[^!]\*?(\w*)\:\s*#?(.*)', f.read())
    )
    f.close()
    if 'cursorColor' not in theme:
        theme.update({ 'cursorColor': theme['color4']})
    return theme

def map_colors(color_theme):
    colors = ["black","red","green","yellow","blue","magenta","cyan","white"]
    colorv = [("#"+color_theme[f'color{n}'], "#"+color_theme[f'color{n+8}']) for n in range(8)]
    return dict(list(zip(colors, colorv)))

# Colours
color_theme = parse_terminal_sexy()
color_map = map_colors(color_theme)
color_alert = color_map["red"][1]
color_frame = color_map["black"][0]

def is_running(process):
    s = subprocess.Popen(["ps", "axw"], stdout=subprocess.PIPE)
    for x in s.stdout:
        if re.search(process, x):
            return True
        return False

def execute_once(process):
    if not is_running(process):
        return subprocess.Popen(process.split())

@hook.subscribe.client_focus
def float_to_front(w):
    w.cmd_bring_to_front()

# only window manangement hotkeys
# others via triggerhappy
keys = [
    # A list of available commands that can be bound to keys can be found
    # at https://docs.qtile.org/en/latest/manual/config/lazy.html
    # Switch between windows
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "space", lazy.layout.next(), desc="Move window focus to other window"),

    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key([mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move window to the left"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(), desc="Move window to the right"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),

    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    Key([mod, "control"], "h", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key([mod, "control"], "l", lazy.layout.grow_right(), desc="Grow window to the right"),
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),

    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key([mod, "shift"], "Return", lazy.layout.toggle_split(), desc="Toggle between split and unsplit sides of stack"),
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),

    # Toggle between different layouts as defined below
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod], "c", lazy.window.kill(), desc="Kill focused window"),
    Key([mod], "f", lazy.window.toggle_floating(), desc='Toggle floating'),
    Key([mod, alt], "f", lazy.window.toggle_fullscreen()),
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([mod], "r", lazy.spawncmd(), desc="Spawn a command using a prompt widget"),

    Key([mod], "d"
        #, app_launcher()
        , lazy.spawn("mxctl.control dmenu_run")
        , desc="Spawn app launcher"),
    
    Key([mod], "w"
        #, window_list()
        , lazy.spawn("mxctl.control dmenu_select_window")
        , desc="Spawn window selector"),

    Key([mod], "q"
        , lazy.spawn("mxctl.control dmenu_exit")
        , desc="Exit menu"),
    
    # ALT
    Key([alt], "grave", lazy.window.bring_to_front()),
    Key([alt], "Tab", lazy.group.next_window()),
    
    Key([alt, "control"], "2"
        , lazy.spawn("mxctl.control dmenu_setup_display")
        , desc="setup display"),
    
    Key([alt, "control"], "3"
        , lazy.spawn("mxctl.control dmenu_select_pa_sinks")
        , desc="select pa sink"),

    Key([alt, "control"], "4"
        , lazy.spawn("mxctl.control dmenu_misc")
        , desc="Misc menu"),

    # ALT
    Key([alt], "grave", lazy.window.bring_to_front()),
    Key([alt], "Tab", lazy.group.next_window()),

    # Change the volume if our keyboard has keys
    Key(
        [], "XF86AudioRaiseVolume",
        lazy.spawn("mxctl.control vol_up")
    ),
    Key(
        [], "XF86AudioLowerVolume",
        lazy.spawn("mxctl.control vol_down")
    ),
    Key(
        [], "XF86AudioMute",
        lazy.spawn("mxctl.control vol_mute")
    ),

    # backlight controls
    Key([], "XF86MonBrightnessUp", 
        lazy.spawn("brightnessctl set +2%")),
    
    Key([], "XF86MonBrightnessDown",
        lazy.spawn("brightnessctl set 2%-")),

    Key([], "Print",
        lazy.spawn("grim")),

    Key(["control"], "Print",
        lazy.spawn("slurp")),

    # Key(['mod4'], 'r', lazy.run_extension(extension.DmenuRun(
    #     dmenu_prompt=">",
    #     dmenu_font="terminus-8",
    #     background="#15181a",
    #     foreground="#00ff00",
    #     selected_background="#079822",
    #     selected_foreground="#fff",
    #     dmenu_height=24,  # Only supported by some dmenu forks
    # ))),


    # Key([mod], 'm', lazy.run_extension(extension.CommandSet(
    # commands={
    #     'play/pause': '[ $(mocp -i | wc -l) -lt 2 ] && mocp -p || mocp -G',
    #     'next': 'mocp -f',
    #     'previous': 'mocp -r',
    #     'quit': 'mocp -x',
    #     'open': 'urxvt -e mocp',
    #     'shuffle': 'mocp -t shuffle',
    #     'repeat': 'mocp -t repeat',
    #     },
    # pre_commands=['[ $(mocp -i | wc -l) -lt 1 ] && mocp -S'],
    # **Theme.dmenu))),

    KeyChord([mod], "z", [
        Key([], "g", lazy.layout.grow()),
        Key([], "s", lazy.layout.shrink()),
        Key([], "n", lazy.layout.normalize()),
        Key([], "m", lazy.layout.maximize())],
        mode=True,
        name="Windows"
    ),
] + backend_opts["keys"]

groups = [Group(i) for i in "1234"]

for i in groups:
    Key([mod], "c", lazy.window.kill(), desc="Kill focused window"),
    keys.extend(
        [
            # mod1 + letter of group = switch to group
            Key(
                [mod],
                i.name,
                lazy.group[i.name].toscreen(),
                desc="Switch to group {}".format(i.name),
            ),
            # mod1 + shift + letter of group = switch to & move focused window to group
            Key(
                [mod, "shift"],
                i.name,
                lazy.window.togroup(i.name, switch_group=True),
                desc="Switch to & move focused window to group {}".format(i.name),
            ),
            # Or, use below if you prefer not to switch to that group.
            # # mod1 + shift + letter of group = move focused window to group
            # Key([mod, "shift"], i.name, lazy.window.togroup(i.name),
            #     desc="move focused window to group {}".format(i.name)),
        ])
border = dict(
    border_focus     = color_map['blue'][0],
    border_normal    = color_map['white'][0],
    border_width     = 2,
    margin           = 8,
    radio            = 0.5001,
)

layouts = [
    layout.Floating(**border),
    layout.Spiral(**border),
    layout.Max(),
]

widget_defaults = dict(
    font="monospace",
    fontsize=16,
    padding=4,
)

extension_defaults = widget_defaults.copy()

top_bar = [
    widget.TextBox(
        text='',
        padding=4
    ),
    widget.Clock(
        format='%a %d %b %Y %H:%M:%S', **widget_defaults
    ),
    # widget.LaunchBar(
    #     progs = [
    #         ("Terminal", "qterminal", "Launch QTerminal")
    #     ]
    # ),
    widget.Sep(padding=12),
    widget.WindowName(),
    widget.Systray(icon_size=24),
    widget.Volume(
        update_interval=2,
        fmt="墳 {}"
    ),
    # widget.CPUGraph(
    #     graph_color=color_alert,
    #     fill_color='{}.5'.format(color_alert),
    #     border_color=color_frame,
    #     line_width=2,
    #     border_width=1,
    #     samples=40,
    #     width=50,
    #     )
    widget.CPU(
        format=" {load_percent}%",
        update_interval=2
    ),
    widget.ThermalZone(
        update_interval=2,
        format=" {temp}°C"
    ),
    # widget.MemoryGraph(
    #     graph_color=color_alert,
    #     fill_color='{}.5'.format(color_alert),
    #     border_color=color_frame,
    #     line_width=2,
    #     border_width=1,
    #     samples=40,
    #     width=50,
    #     ),
    widget.Memory(
        format="溜{MemUsed: .0f}{mm}",
        update_interval=2
    ),
    widget.Wlan(
        format=" {essid} {quality}",
        update_interval=2
    ),
    # widget.Net(
    #    interface = "wlp0s20f3",
    #    format = 'Net: {down} ↓↑ {up}',
    #    padding = 5
    #    ),
    widget.Battery(energy_now_file = "charge_now",
                   energy_full_file = "charge_full",
                   power_now_file = "current_now",
                   update_delay = 5,
                   charge_char = u'',
                   discharge_char = u'',),
    # widget.QuickExit(),
]

bottom_bar = [
    widget.GroupBox(),
    widget.Prompt(),
    widget.Chord(
        chords_colors={
            "launch": ("#ff0000", "#ffffff"),
        },
        name_transform=lambda name: name.upper(),
    ),
    widget.TaskList(
        border=color_frame,
        highlight_method='block',
        max_title_width=196,
        urgent_border=color_alert,
    ),
    widget.TextBox(
        text=' ',
        padding=2
        ),
    widget.CheckUpdates(
        update_interval=18000,
        display_format="{updates}",
        colour_have_updates="#191724",
        ),
    widget.CurrentLayoutIcon(),
]

screens = [
    Screen(
        wallpaper = g_home + "/.wlprs/wallpaper",
        wallpaper_mode = "stretch",
        #left=bar.Gap(8),
        #right=bar.Gap(8),
        top=bar.Bar(top_bar,
            26,
            background="#00000088"
        ),
        bottom=bar.Bar(bottom_bar,
            26,
            background="#00000088"
        ),
    ),
]

# Drag floating layouts.
mouse = [
    Drag([mod],  "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod],  "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = False
bring_front_click = False
cursor_warp = False

floating_layout = layout.Floating(
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
        Match(title='Open File'),
        Match(title='Unlock Database - KeePassXC'),  # Wayland
        Match(title='File Operation Progress', wm_class='thunar'),  # Wayland
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(wm_class='Arandr'),
        Match(wm_class='org.kde.ark'),
        Match(wm_class='confirm'),
        Match(wm_class='dialog'),
        Match(wm_class='download'),
        Match(wm_class='error'),
        Match(wm_class='fiji-Main'),
        Match(wm_class='file_progress'),
        Match(wm_class='imv'),
        Match(wm_class='lxappearance'),
        Match(wm_class='mpv'),
        Match(wm_class='notification'),
        Match(wm_class='pavucontrol'),
        Match(wm_class='Pinentry-gtk-2'),
        Match(wm_class='qt5ct'),
        Match(wm_class='ssh-askpass'),
        Match(wm_class='Dragon'),
        Match(wm_class='Dragon-drag-and-drop'),
        Match(wm_class='toolbar'),
        Match(wm_class='wlroots'),
        Match(wm_class='Xephyr'),
        Match(wm_class='Popeye'),
        Match(wm_type='dialog'),
        Match(role='gimp-file-export'),
        # Match(func=lambda c: c.has_fixed_size()),
        # Match(func=lambda c: bool(c.is_transient_for())),
    ],
    **border
)
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# When using the Wayland backend, this can be used to configure input devices.
# wl_input_rules = None
wl_input_rules = backend_opts["input_rules"] 
