function push_line --description "Push the command buffer and clear the command line"
    set --local buffer (commandline | string collect --allow-empty)[1]
    set --append --global _push_line_buffers "$buffer"
    set --append --global _push_line_cursors (commandline --cursor)

    commandline ""
    commandline --function repaint
end

function _push_line_restore --on-event fish_prompt
    if not set --query _push_line_buffers[-1]
        return
    end

    set --local buffer $_push_line_buffers[-1]
    set --local cursor $_push_line_cursors[-1]
    set --erase _push_line_buffers[-1]
    set --erase _push_line_cursors[-1]

    commandline -- "$buffer"
    commandline --cursor "$cursor"

    if not set --query _push_line_buffers[-1]
        set --erase _push_line_buffers _push_line_cursors
    end
end

function _push_line_restore_after_error --on-event fish_posterror
    _push_line_restore
end

function fish_user_key_bindings
    bind escape,q push_line
end

fish_user_key_bindings
