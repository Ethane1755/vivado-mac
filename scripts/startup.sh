#!/bin/bash

# Configure display settings for high-DPI displays
if [ ! -z "$RESOLUTION" ] && [ ! -z "$DPI" ]; then
    export GDK_SCALE=2
    export GDK_DPI_SCALE=0.5
    export QT_AUTO_SCREEN_SCALE_FACTOR=1
    export QT_SCALE_FACTOR=2
    export XCURSOR_SIZE=32
    
    # Font smoothing and rendering settings
    export FREETYPE_PROPERTIES="truetype:interpreter-version=40"
    export GDK_USE_XFT=1
    export QT_XFT=true
    export Xft_antialias=1
    export Xft_hinting=1
    export Xft_hintstyle="hintfull"
    export Xft_rgba="rgb"
    
    # GUI rendering fixes
    export GDK_SYNCHRONIZE=1
    export LIBGL_ALWAYS_INDIRECT=1
    export LIBGL_ALWAYS_SOFTWARE=1
    export MESA_GL_VERSION_OVERRIDE=3.3
    export QT_X11_NO_MITSHM=1
    
    # X11 window manager properties for better popup handling
    export WINDOW_MANAGER=none
    export DESKTOP_SESSION=X11
    
    # Fixes for fast-appearing dialogs and black box issues  
    # AWT_TOOLKIT will be set later for dropdown compatibility
    export JAVA2D_NODDRAW=true
    export J2D_USE_OPENGL=false
    export SWING_DOUBLE_BUFFERING=true
    export _JAVA_OPTIONS="$_JAVA_OPTIONS -Dsun.java2d.pmoffscreen=false -Dsun.java2d.d3d=false -Dsun.java2d.opengl=false"
    export XLIB_SKIP_ARGB_VISUALS=1
    
    # Dropdown and popup menu fixes
    export _JAVA_OPTIONS="$_JAVA_OPTIONS -Dswing.aatext=true -Dswing.plaf.metal.controlFont=Dialog-PLAIN-12 -Dswing.plaf.metal.systemFont=Dialog-PLAIN-12"
    export _JAVA_OPTIONS="$_JAVA_OPTIONS -Dsun.awt.disablegrab=false -Djava.awt.Window.locationByPlatform=false"
    export _JAVA_OPTIONS="$_JAVA_OPTIONS -Dsun.java2d.xrender=false -Dsun.java2d.noddraw=true"
    export JAVA_TOOL_OPTIONS="$JAVA_TOOL_OPTIONS -Dawt.useSystemAAFontSettings=on"
    
    # Set Java font scaling, smoothing, and memory settings for Vivado
    export _JAVA_OPTIONS="-Dsun.java2d.uiScale=2.0 -Dswing.defaultlaf=javax.swing.plaf.metal.MetalLookAndFeel -Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -Dsun.java2d.xrender=true -Xmx10g -XX:MaxMetaspaceSize=2g -XX:+UseG1GC -XX:+UseStringDeduplication"
    
    # Create X11 resources file for font rendering (macOS optimized)
    cat > ~/.Xresources << 'EOF'
Xft.dpi:        220
Xft.antialias:  true
Xft.hinting:    true
Xft.autohint:   true
Xft.rgba:       rgb
Xft.hintstyle:  hintfull

XTerm*faceName: SF Mono
*faceName: SF Mono
EOF

    # Create GTK2 configuration for better font rendering
    cat > ~/.gtkrc-2.0 << 'EOF'
style "user-font" {
    font_name = "SF Pro Display 11"
}
widget_class "*" style "user-font"

gtk-font-name="SF Pro Display 11"
gtk-enable-mnemonics = 0
gtk-xft-antialias = 1
gtk-xft-hinting = 1
gtk-xft-hintstyle = "hintfull"
gtk-xft-rgba = "rgb"
EOF

    # Create GTK3 configuration
    mkdir -p ~/.config/gtk-3.0
    cat > ~/.config/gtk-3.0/settings.ini << 'EOF'
[Settings]
gtk-font-name=SF Pro Display 11
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintfull
gtk-xft-rgba=rgb
gtk-enable-mnemonics=0
EOF

    # Create fontconfig for better font rendering
    mkdir -p ~/.config/fontconfig
    cat > ~/.config/fontconfig/fonts.conf << 'EOF'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <!-- macOS font substitutions -->
  <alias>
    <family>SF Pro Display</family>
    <prefer>
      <family>DejaVu Sans</family>
      <family>Liberation Sans</family>
    </prefer>
  </alias>
  
  <alias>
    <family>SF Mono</family>
    <prefer>
      <family>DejaVu Sans Mono</family>
      <family>Liberation Mono</family>
    </prefer>
  </alias>

  <match target="font">
    <edit name="antialias" mode="assign">
      <bool>true</bool>
    </edit>
    <edit name="hinting" mode="assign">
      <bool>true</bool>
    </edit>
    <edit name="hintstyle" mode="assign">
      <const>hintfull</const>
    </edit>
    <edit name="rgba" mode="assign">
      <const>rgb</const>
    </edit>
    <edit name="lcdfilter" mode="assign">
      <const>lcddefault</const>
    </edit>
  </match>
</fontconfig>
EOF

    # Load X11 resources
    xrdb -merge ~/.Xresources 2>/dev/null || true
    
    # Update font cache
    fc-cache -fv 2>/dev/null || true
    
    # Initialize D-Bus for proper GUI components
    if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
        eval $(dbus-launch --sh-syntax --exit-with-session)
        export DBUS_SESSION_BUS_ADDRESS
    fi
    
    # Start a lightweight window manager to handle compositing and popups
    if which openbox > /dev/null 2>&1; then
        openbox --sm-disable --config-file /dev/null &
    elif which metacity > /dev/null 2>&1; then
        metacity --sm-disable --replace &
    elif which fluxbox > /dev/null 2>&1; then
        fluxbox &
    fi
    
    # Configure window manager for better dropdown handling
    export _JAVA_AWT_WM_NONREPARENTING=1
    export AWT_TOOLKIT=XToolkit
    
    # Give window manager time to start
    sleep 3
fi

# # if Vivado is installed
if [ -d "/home/user/Xilinx" ]
then
	# Set Vivado environment variables for better memory management
	export XIL_TIMING_ALLOW_IMPOSSIBLE=1
	export XIL_PAR_DESIGN_CHECK_VERBOSE=1
	export XIL_CSE_TCL_DEBUG=0
	export VIVADO_ENABLE_HD_LOGGING=0
	export XIL_DISABLE_USB_DEVICE_SCAN=1
	export XIL_DISABLE_HW_PLATFORM_DETECT=1
	
	# Increase system limits (with error handling)
	ulimit -v unlimited 2>/dev/null || true
	ulimit -s unlimited 2>/dev/null || true
	
	/home/user/Xilinx/Vivado/*/bin/hw_server -e "set auto-open-servers xilinx-xvc:host.docker.internal:3721" &
	source /home/user/Xilinx/Vivado/*/settings64.sh
	/home/user/Xilinx/Vivado/*/bin/vivado -nolog -nojournal
else
	echo "The installation is incomplete."
fi