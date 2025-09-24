script_dir=$(dirname -- "$(readlink -nf $0)";)

function stop_container {
    /usr/local/bin/docker kill vivado > /dev/null 2>&1
    echo "Stopped Docker container"
    exit 0
}
trap 'stop_container' INT

# Check if XQuartz is running, start if needed
if ! pgrep -f "XQuartz" > /dev/null; then
    echo "Starting XQuartz..."
    open -a XQuartz
    
    echo -n "Waiting for XQuartz to initialize: "
    for i in 5 4 3 2; do
        echo -n "$i.."
        sleep 1
    done
    echo -n "1 "
    echo "✅"
    sleep 3  # Additional buffer time
fi

export DISPLAY=:0

# Configure XQuartz for better window handling
defaults write org.xquartz.X11 wm_ffm -bool true
defaults write org.xquartz.X11 wm_click_through -bool true
defaults write org.xquartz.X11 enable_iglx -bool true
defaults write org.xquartz.X11 depth -int 24

# Try xhost commands with error handling
if ! /opt/X11/bin/xhost + localhost 2>/dev/null; then
    echo -n "⏳ XQuartz initializing, retrying in: "
    for i in 5 4 3 2; do
        echo -n "$i.."
        sleep 1
    done
    echo -n "1 "
    echo "✅"
    /opt/X11/bin/xhost + localhost
fi

HOST_IP=$(ifconfig en0 | grep "inet " | awk '{print $2}')
/opt/X11/bin/xhost + $HOST_IP
# Get display resolution and DPI automatically
RESOLUTION=$(system_profiler SPDisplaysDataType | grep Resolution | head -1 | sed 's/.*Resolution: \([0-9]*\) x \([0-9]*\).*/\1x\2/')
DPI=220  # Standard Retina display DPI
echo "Detected resolution: $RESOLUTION"
/usr/local/bin/docker run --init --rm \
    -e DISPLAY=$HOST_IP:0 \
    -e RESOLUTION=$RESOLUTION \
    -e DPI=$DPI \
    --memory=13g \
    --memory-swap=20g \
    --shm-size=4g \
    --ulimit memlock=-1:-1 \
    --ulimit stack=67108864 \
    --privileged \
    -v /dev:/dev \
    -v /sys:/sys \
    --name vivado \
    --mount type=bind,source="$script_dir/../",target="/home/user" \
    --platform linux/amd64 ubuntu_vivado_env \
    sudo -H -u user bash scripts/startup.sh &

# monitor vivado container
sleep 10
while [[ $(/usr/local/bin/docker ps) == *vivado* ]]
do
    sleep 1
done
stop_container