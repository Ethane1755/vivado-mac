#!/bin/bash

script_dir=$(dirname -- "$(readlink -nf $0)";)
source "$script_dir/headers.sh"

if [ -d "$script_dir/../Xilinx" ]
then
	error "A previous installation was found. To reinstall, remove the Xilinx folder."
	exit 1
fi

if ! [ -f "$INSTALLATION_BIN_LOG_PATH" ]; then
    drag_and_drop_files "please drags and drop your vivado installer.bin to this terminal" "copy" $INSTALLATION_BIN_LOG_PATH
else
    info "$INSTALLATION_BIN_LOG_PATH found."
fi

if ! [[ $(docker image ls ) == *$IMAGE_NAME* ]]
then
    step "Build The Image"
    if ! docker build --platform linux/amd64 -t $IMAGE_NAME "$script_dir"
    then
        error "Docker image generation failed!"
        exit 1
    fi
    success "The Docker image was successfully generated."
else
    debug "The Image already exits"
fi

step "Start container for setup Vivado"
docker run --init --rm -it --name vivado_x11 --mount type=bind,source="$script_dir/..",target="/home/user" --platform linux/amd64 $IMAGE_NAME bash scripts/install.sh

# Ask user if they want to add vivado to PATH
echo ""
step "PATH Installation (Optional)"
info "Would you like to add the 'vivado' launcher to your PATH?"
info "This allows you to run 'vivado' from anywhere in your terminal."
echo ""
read -p "Add vivado to PATH? (y/n): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    VIVADO_SCRIPT_PATH="$script_dir/../vivado"
    
    # Determine which shell profile to update
    if [[ "$SHELL" == *"zsh"* ]]; then
        PROFILE_FILE="$HOME/.zshrc"
        SHELL_NAME="zsh"
    elif [[ "$SHELL" == *"bash"* ]]; then
        PROFILE_FILE="$HOME/.bash_profile"
        SHELL_NAME="bash"
    else
        PROFILE_FILE="$HOME/.profile"
        SHELL_NAME="shell"
    fi
    
    # Create a symlink in /usr/local/bin if it doesn't exist
    if [[ -w "/usr/local/bin" ]]; then
        if [[ ! -L "/usr/local/bin/vivado" ]]; then
            ln -sf "$VIVADO_SCRIPT_PATH" "/usr/local/bin/vivado"
            success "Created symlink: /usr/local/bin/vivado -> $VIVADO_SCRIPT_PATH"
        else
            info "Symlink already exists: /usr/local/bin/vivado"
        fi
    else
        # Fallback: Add to PATH via profile
        PATH_EXPORT="export PATH=\"$(dirname "$VIVADO_SCRIPT_PATH"):\$PATH\""
        
        if ! grep -q "vivado-mac" "$PROFILE_FILE" 2>/dev/null; then
            echo "" >> "$PROFILE_FILE"
            echo "# Added by vivado-mac setup" >> "$PROFILE_FILE"
            echo "$PATH_EXPORT" >> "$PROFILE_FILE"
            success "Added vivado-mac to PATH in $PROFILE_FILE"
            info "Please restart your terminal or run: source $PROFILE_FILE"
        else
            info "vivado-mac already appears to be in your PATH configuration"
        fi
    fi
    
    success "✅ Setup complete! You can now run 'vivado' from anywhere."
else
    info "Skipped PATH installation. You can run vivado from: $script_dir/../vivado"
fi

echo ""
success "🎉 Vivado setup is complete!"
info "To start Vivado, you can either:"
if [[ $REPLY =~ ^[Yy]$ ]]; then
    info "  • Run 'vivado' from anywhere in your terminal"
fi
info "  • Navigate to $(dirname "$script_dir") and run './vivado'"
info "  • Navigate to $(dirname "$script_dir") and run './scripts/start_container.sh'"