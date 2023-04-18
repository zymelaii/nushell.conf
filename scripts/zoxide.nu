# Setup zoxide hook.
export def-env init-zoxide [] {
    if ($env | default false __zoxide_hooked | get __zoxide_hooked) { return }

    let-env __zoxide_hooked = true
    let-env config = ($env | default {} config).config
    let-env config = ($env.config | default {} hooks)
    let-env config = ($env.config | update hooks ($env.config.hooks | default [] pre_prompt))
    let-env config = ($env.config | update hooks.pre_prompt ($env.config.hooks.pre_prompt | append {zoxide add -- $env.PWD}))
}

# Jump to a directory using interactive search.
export def-env z  [...rest: string] {
    cd $'(zoxide query -i -- $rest | str trim -r -c "\n")'
}

# Jump to a directory using only keywords.
export def-env zi [...rest: string] {
    let arg0 = ($rest | append '~').0
    let path = if (($rest | length) <= 1) and ($arg0 == '-' or ($arg0 | path expand | path type) == dir) {
        $arg0
    } else {
        (zoxide query --exclude $env.PWD -- $rest | str trim -r -c "\n")
    }
    cd $path
}
