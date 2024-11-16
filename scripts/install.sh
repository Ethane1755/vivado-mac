#!/bin/zsh

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

cat SECRET_FILE
if ! [ -d "$script_dir/../installer" ]; then
    step "start extract installer"
    eval "$script_dir/../FPGAsAdaptiveSoCsUnified2024.1Lin64.bin --target $script_dir/../installer --noexec"
else
    debug "The installer already extracted"
fi

step "Generate AuthTokenGen"
if ! /home/user/installer/xsetup -b AuthTokenGen
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
fi

step "Start Download and Installing"
/home/user/installer/xsetup -c "/home/user/scripts/vivado_settings.txt" -b Install -a XilinxEULA,3rdPartyEULA