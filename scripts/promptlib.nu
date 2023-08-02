# oh-my-posh prompt

export def "prompt home" [] {
    $'($env.USERPROFILE)(char psep).oh-my-posh'
}

# List available prompt themes.
export def "prompt list" [] {
    ls (prompt home)
    | each {|e|
        $e.name
        | path basename
        | split column '.' theme
        | get theme
    }
    | flatten
}

# Render prompt in the specific theme.
export def "prompt display" [
    theme: string@"prompt list"
] {
    let theme = $'(prompt home)(char psep)($theme).omp.json'

    let timeUsed = if $env.CMD_DURATION_MS == '0823' { 0 } else { $env.CMD_DURATION_MS }
    let width = ((term size).columns | into string)

    (oh-my-posh print secondary
        $'--config=($theme)'
        --shell=nu
        $'--shell-version=($env.NU_VERSION)')

    (oh-my-posh print primary
        $'--config=($theme)'
        --shell=nu
        $'--shell-version=($env.NU_VERSION)'
        $'--execution-time=($timeUsed)'
        $'--error=($env.LAST_EXIT_CODE)'
        $'--terminal-width=($width)')
}

# Change prompt theme provided by oh my posh.
export def-env prompt [
    theme?: string@"prompt list"
] {
    let theme = if $theme in (prompt list) {
        $theme
    } else {
        prompt list | first
    }
    $env.POSH_THEME = $'(prompt home)(char psep)($theme).omp.json'
}

export def-env "prompt init" [] {
    $env.POWERLINE_COMMAND = 'oh-my-posh'
    $env.PROMPT_INDICATOR = ''
    $env.POSH_PID = (random uuid)
    $env.PROMPT_COMMAND_RIGHT = ''
    $env.NU_VERSION = (version | get version)

    $env.POSH_THEME = if ($env.POSH_THEME? | is-empty) {
        prompt
        $env.POSH_THEME
    } else {
        $env.POSH_THEME
    }

    $env.PROMPT_MULTILINE_INDICATOR = {||
        (oh-my-posh print secondary
            $'--config=($env.POSH_THEME)'
            --shell=nu
            $'--shell-version=($env.NU_VERSION)')
    }

    $env.PROMPT_COMMAND = {||
        let timeUsed = if $env.CMD_DURATION_MS == '0823' { 0 } else { $env.CMD_DURATION_MS }
        let width = ((term size).columns | into string)
        (oh-my-posh print primary
            $'--config=($env.POSH_THEME)'
            --shell=nu
            $'--shell-version=($env.NU_VERSION)'
            $'--execution-time=($timeUsed)'
            $'--error=($env.LAST_EXIT_CODE)'
            $'--terminal-width=($width)')
    }
}
