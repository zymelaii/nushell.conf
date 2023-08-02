# plugin for carapace-bin

# Install carapace completer.
export def-env "install carapace" [] {
    let carapace_completer = {|spans|
        let executable = ($spans.0 | path parse | get stem)
        let spans = ($spans | skip 1 | prepend $executable)
        carapace $executable nushell $spans | from json
    }

    mut config = $env.config.completions.external
    $config.enable = true
    $config.completer = $carapace_completer

    $env.config.completions.external = $config
}
