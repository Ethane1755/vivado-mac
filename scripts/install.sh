#!/bin/bash

script_dir=$(dirname -- "$(readlink -nf $0)";)
source "$script_dir/headers.sh"

get_credentials() {
    local secret_file="$1"
    local secret_dir=$(dirname "$secret_file")

    # Create directory if it doesn't exist
    mkdir -p "$secret_dir"

    # Prompt for credentials
    echo -n "Enter your email address: "
    read email
    echo -n "Enter your password: "
    read -s password
    echo  # New line after password input

    # Save credentials to file
    echo "$email" > "$secret_file"
    echo "$password" >> "$secret_file"

    echo "Credentials saved to $secret_file"
}

SECRET_FILE="$script_dir/secret.txt"

INSTALLATION_FILE_PATH=$(cat "$INSTALLATION_BIN_LOG_PATH" | xargs)

step "try to find $INSTALLATION_FILE_PATH"

if [ -f "$script_dir/$INSTALLATION_FILE_PATH" ]; then
    success "File exists: $INSTALLATION_FILE_PATH"
else
    error "File does not exist: $INSTALLATION_FILE_PATH"
    error "cleaning up cache files please run this script again"
    rm $script_dir/installation_location.txt
    exit
fi

# cat $SECRET_FILE
if ! [ -d "$script_dir/../installer" ]; then
    step "start extract installer"
    chmod u+x "$script_dir/$INSTALLATION_FILE_PATH"
    eval "\"$script_dir/$INSTALLATION_FILE_PATH\" --target \"$script_dir/../installer\" --noexec"
else
    debug "The installer already extracted"
fi

step "Generate AuthTokenGen"

GENERATED_TOKEN=false

if [ -f "$SECRET_FILE" ]; then
        info "Credentials file found."
        if ! expect -f $HOME/scripts/auth_token_gen.exp /home/user/installer/xsetup "$SECRET_FILE"; then
            error secret.txt corrupt. removing $SECRET_FILE
            rm $SECRET_FILE
        else
            GENERATED_TOKEN=true
        fi
fi

if ! $GENERATED_TOKEN && ! /home/user/installer/xsetup -b AuthTokenGen
then
    warning "Can't Generate AuthTokenGen"
    step "now using expect method"
    step "Checking for credentials..."
    if ! [ -f "$SECRET_FILE" ]; then
        warning "Credentials file not found."
        get_credentials "$SECRET_FILE"
    fi

    # Check if secret.txt is readable and not empty
    if ! [ -r "$SECRET_FILE" ] || ! [ -s "$SECRET_FILE" ]; then
        warning "Error: Cannot read credentials file or file is empty"
        get_credentials "$SECRET_FILE"
    fi

    step "Generate AuthTokenGen"

    expect -f $HOME/scripts/auth_token_gen.exp /home/user/installer/xsetup "$SECRET_FILE"
else
    GENERATED_TOKEN=true
fi

if $GENERATED_TOKEN; then
    step "Start Download and Installing"
    /home/user/installer/xsetup -c "/home/user/scripts/vivado_settings.txt" -b Install -a XilinxEULA,3rdPartyEULA
fi