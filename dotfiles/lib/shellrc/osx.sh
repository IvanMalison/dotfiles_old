function set_global_osx_ssh_port {
    set_osx_ssh_port $1 /System/Library/LaunchDaemons/ssh.plist
}

function set_osx_ssh_port {
    sudo sed -i -n "/SockServiceName/{p;n;s/>.*</>$1</;};p" $2; echo "SSH Port $1. Restart service for changes to take effect."
}

function enable_access_for_assistive_devices {
    local bundle_identifier=$(/usr/libexec/PlistBuddy -c 'Print CFBundleIdentifier' "$1/Contents/Info.plist")
    local where_clause="where service='kTCCServiceAccessibility' and client='$bundle_identifier'"
    local search_string="SELECT * from access ${where_clause};"
    local values_string="VALUES('kTCCServiceAccessibility','$bundle_identifier',0,1,1,NULL)"
    if test -z $(sudo sqlite3 '/Library/Application Support/com.apple.TCC/TCC.db' $search_string);
    then
        local sql_string="INSERT INTO access $values_string;"
    else
        local sql_string="UPDATE access set allowed = 1 ${where_clause};"
    fi
    echo $sql_string
    sudo sqlite3 '/Library/Application Support/com.apple.TCC/TCC.db' $sql_string
}

function as_user {
    local user="$1"
    local user_pid=$(ps -axj | awk "/^$user / {print \$2;exit}")
    local command="sudo /bin/launchctl bsexec $user_pid sudo -u '$user' $2"
    echo "Running:"
    echo "$command"
    eval $command
}

function as_current_user {
    as_user "$(whoami)" "$*"
}

function reload_user_agent {
    as_current_user /bin/launchctl unload "$1"
    as_current_user /bin/launchctl load "$1"
}
    
    
function reload_root_agent {
    as_user 'root' "/bin/launchctl unload '$1'"
    as_user 'root' "/bin/launchctl load '$1'"
}

function brew_for_multiple_users() {
    sudo chgrp -R admin /usr/local
    sudo chmod -R g+w /usr/local
    sudo chgrp -R admin /Library/Caches/Homebrew
    sudo chmod -R g+w /Library/Caches/Homebrew
}

function swap_audio() {
    test -z $(SwitchAudioSource -c | grep HDMI) && SwitchAudioSource -s HDMI || SwitchAudioSource -s "Built-in Output"
}

function ss() {
    osascript -e "tell application \"/System/Library/Frameworks/ScreenSaver.framework/Versions/A/Resources/ScreenSaverEngine.app\" to activate"
}

function set_modifier_keys_for_vendor_product_id() {
    local mapping="<dict><key>HIDKeyboardModifierMappingDst</key><integer>$3</integer><key>HIDKeyboardModifierMappingSrc</key><integer>$2</integer></dict>"
    echo $mapping
    defaults -currentHost write -g com.apple.keyboard.modifiermapping.$1-0 -array-add "$mapping"
}

function set_modifier_keys_on_all_keyboards() {
    for vendor_product_id in $(get_keyboard_vendor_id_product_id_pairs | tr " " "-"); do
        set_modifier_keys_for_vendor_product_id $vendor_product_id 0 2; echo $vendor_product_id;
    done;
}

function get_keyboard_vendor_id_product_id_pairs() {
    ioreg -n IOHIDKeyboard -r | grep -e 'class IOHIDKeyboard' -e VendorID\" -e Product | gawk 'BEGIN { RS = "class IOHIDKeyboard" } match($0, /VendorID. = ([0-9]*)/, arr) { printf arr[1]} match($0, /ProductID. = ([0-9]*)/, arr) { printf " %s\n", arr[1]} '
}

function set_osx_hostname() {
    local new_hostname="${1-imalison}"
    sudo scutil --set ComputerName $new_hostname
    sudo scutil --set HostName $new_hostname
    sudo scutil --set LocalHostName $new_hostname
    sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string $new_hostname
}
