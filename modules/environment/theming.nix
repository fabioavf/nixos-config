# /etc/nixos/modules/environment/theming.nix
# GTK and Qt theming configuration

{ config, lib, pkgs, ... }:

{
  # GTK Configuration
  programs.dconf.enable = true;
  
  # Set dark theme system-wide
  environment.variables = {
    # GTK themes
    GTK_THEME = "Adwaita:dark";
    
    # Qt themes
    QT_QPA_PLATFORMTHEME = "gtk3";
    QT_STYLE_OVERRIDE = "adwaita-dark";
    
    # Force dark mode for applications
    GTK_USE_DARK_THEME = "1";
    QT_QPA_PLATFORM = "wayland";
  };

  # Install theme packages
  environment.systemPackages = with pkgs; [
    # GTK themes
    adwaita-icon-theme
    gnome-themes-extra
    gtk-engine-murrine
    
    # Qt themes
    adwaita-qt
    adwaita-qt6
    libsForQt5.qtstyleplugins
    
    # Icon themes
    papirus-icon-theme
    numix-icon-theme
    
    # Additional theming tools
    lxappearance    # GTK theme configurator
    libsForQt5.qt5ct
    qt6ct          # Qt6 configuration tool
    libsForQt5.qt5ct
    kdePackages.qt6ct
    
    # Cursor themes
    bibata-cursors
    vanilla-dmz
  ];

  # System-wide GTK configuration
  environment.etc = {
    "gtk-2.0/gtkrc".text = ''
      gtk-theme-name = "Adwaita-dark"
      gtk-icon-theme-name = "Adwaita"
      gtk-cursor-theme-name = "Adwaita"
      gtk-font-name = "Sans 10"
    '';
    
    "gtk-3.0/settings.ini".text = ''
      [Settings]
      gtk-application-prefer-dark-theme = true
      gtk-theme-name = Adwaita-dark
      gtk-icon-theme-name = Adwaita
      gtk-cursor-theme-name = Adwaita
      gtk-font-name = Sans 10
      gtk-decoration-layout = appmenu:minimize,maximize,close
      gtk-enable-animations = true
      gtk-primary-button-warps-slider = false
    '';
    
    "gtk-4.0/settings.ini".text = ''
      [Settings]
      gtk-application-prefer-dark-theme = true
      gtk-theme-name = Adwaita-dark
      gtk-icon-theme-name = Adwaita
      gtk-cursor-theme-name = Adwaita
      gtk-font-name = Sans 10
      gtk-decoration-layout = appmenu:minimize,maximize,close
      gtk-enable-animations = true
      gtk-primary-button-warps-slider = false
    '';
  };

  # Qt configuration
  environment.etc."xdg/qt5ct/qt5ct.conf".text = ''
    [Appearance]
    color_scheme_path=${pkgs.adwaita-qt}/share/color-schemes/AdwaitaDark.colors
    custom_palette=false
    icon_theme=Adwaita
    standard_dialogs=gtk3
    style=adwaita-dark

    [Fonts]
    fixed="JetBrains Mono,10,-1,5,50,0,0,0,0,0,Regular"
    general="Sans,10,-1,5,50,0,0,0,0,0,Regular"

    [Interface]
    activate_item_on_single_click=1
    buttonbox_layout=3
    cursor_flash_time=1000
    dialog_buttons_have_icons=2
    double_click_interval=400
    gui_effects=@Invalid()
    keyboard_scheme=2
    menus_have_icons=true
    show_shortcuts_in_context_menus=true
    stylesheets=@Invalid()
    toolbutton_style=4
    underline_shortcut=1
    wheel_scroll_lines=3

    [SettingsWindow]
    geometry="@ByteArray(\x1\xd9\xd0\xcb\0\x3\0\0\0\0\x2\x95\0\0\x1\x10\0\0\x5\x64\0\0\x3\x63\0\0\x2\x95\0\0\x1\x10\0\0\x5\x64\0\0\x3\x63\0\0\0\0\0\0\0\0\a\x80\0\0\x2\x95\0\0\x1\x10\0\0\x5\x64\0\0\x3\x63)"
  '';

  environment.etc."xdg/qt6ct/qt6ct.conf".text = ''
    [Appearance]
    color_scheme_path=${pkgs.adwaita-qt6}/share/color-schemes/AdwaitaDark.colors
    custom_palette=false
    icon_theme=Adwaita
    standard_dialogs=gtk3
    style=adwaita-dark

    [Fonts]
    fixed="JetBrains Mono,10,-1,5,50,0,0,0,0,0,Regular"
    general="Sans,10,-1,5,50,0,0,0,0,0,Regular"

    [Interface]
    activate_item_on_single_click=1
    buttonbox_layout=3
    cursor_flash_time=1000
    dialog_buttons_have_icons=2
    double_click_interval=400
    gui_effects=@Invalid()
    keyboard_scheme=2
    menus_have_icons=true
    show_shortcuts_in_context_menus=true
    stylesheets=@Invalid()
    toolbutton_style=4
    underline_shortcut=1
    wheel_scroll_lines=3
  '';

  # User session configuration
  programs.dconf.profiles.user.databases = [
    {
      settings = {
        "org/gnome/desktop/interface" = {
          gtk-theme = "Adwaita-dark";
          icon-theme = "Adwaita";
          cursor-theme = "Adwaita";
          color-scheme = "prefer-dark";
          font-name = "Sans 10";
        };
        
        "org/gnome/desktop/wm/preferences" = {
          theme = "Adwaita-dark";
          button-layout = "appmenu:minimize,maximize,close";
        };
      };
    }
  ];
}
