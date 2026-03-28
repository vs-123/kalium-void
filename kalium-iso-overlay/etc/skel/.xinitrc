#export XDG_SESSION_TYPE=x11
#export XDG_CURRENT_DESKTOP=Openbox
#export XDG_RUNTIME_DIR=/run/user/$(id -u)

export MESA_GL_VERSION_OVERRIDE=3.3
export MESA_GLSL_VERSION_OVERRIDE=330

picom --config ~/.config/picom/picom.conf &
xset r rate 200 50
xrandr --output <OUTPUT_SCREEN_NAME> --mode 2048x1152
feh --bg-fill ~/wp/wp.jpg

exec dbus-run-session openbox

