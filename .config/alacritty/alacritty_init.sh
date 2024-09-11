#!/bin/zsh
# source /Users/johnson/.zshrc

# Function to check if a tmux session named "Core" exists
check_core_session() {
    tmux has-session -t=Core 2>/dev/null
    return $?
}

# Function to get the number of tmux sessions
get_session_count() {
    tmux ls 2>/dev/null | wc -l
}

# Function to attach to a session named "Core"
attach_to_core() {
    tmux attach-session -t Core
}

# Function to create a new tmux session
create_new_session() {
    tmux new-session
}


check_and_start() {
    # Main logic
    check_core_session
    core_exists=$?
    session_count=$(get_session_count)

    # echo "Core session exists = $core_exists\n"
    # echo "session count = $session_count\n"

    if [ $session_count -eq 0 ]; then
        tmux new-session -d -s Core
    fi

    if [ $core_exists -eq 0 ]; then
        # "Core" session exists
        if ! tmux list-clients -t=Core 2>/dev/null | grep . >/dev/null; then
            # "Core" session exists and is not attached
            attach_to_core
        else
            # new login shell without tmux
            /usr/local/bin/zsh -l
        fi
    else
        # "Core" session does not exist
        tmux rename-session -t $(tmux ls | head -n 1 | cut -d: -f1) Core
        attach_to_core

    fi

}

check_and_start_tmux0() {
    # Main logic
    check_core_session
    core_exists=$?
    session_count=$(get_session_count)

    # echo "Core session exists = $core_exists\n"
    # echo "session count = $session_count\n"

    if [ $session_count -eq 0 ]; then
        tmux new-session -A -s Core
    fi

    if [ $core_exists -eq 0 ]; then
        # "Core" session exists
        if ! tmux list-clients -t=Core 2>/dev/null | grep . >/dev/null; then
            # "Core" session exists and is not attached
            attach_to_core
        else
            # "Core" session exists and is attached
            if [ $session_count -eq 1 ]; then
                create_new_session
            elif [ $session_count -eq 2 ]; then
                create_new_session
            elif [ $session_count -ge 3 ]; then
                # Get the count of attached tmux sessions
                attached_count=$(tmux list-sessions -F '#{session_attached}' | grep -c '1')
                if [ $attached_count -eq 3 ]; then
                    tmux attach-session -t $(tmux ls | grep -v Core | head -n 1 | cut -d: -f1)
                else
                    # attach to head first session that not been attached
                    tmux attach-session -t $(tmux list-sessions -F "#{session_attached} #{session_name}" | grep "^0" | head -n 1 | awk '{print $2}')
                fi
            fi
        fi
    else
        # "Core" session does not exist
        if [ $session_count -eq 1 ]; then
            tmux rename-session -t $(tmux ls | head -n 1 | cut -d: -f1) Core
            attach_to_core
        elif [ $session_count -ge 2 ]; then
            tmux rename-session -t $(tmux ls | head -n 1 | cut -d: -f1) Core
            attach_to_core
        fi
    fi

}

# function
check_and_start_tmux() {
	# Check if there is any running alacritty instance
    # 用内置的CreateNewWindow会让 pgrep 捕捉不到 alacritty 进程
	if /usr/bin/pgrep alacritty >/dev/null; then
		# Alacritty is running, start tmux with the remote session
		/usr/local/bin/tmux new-session
	else
		# No alacritty instance is running, start tmux with the main session
		/usr/local/bin/tmux new-session -A -s main
	fi
}

check_and_start
