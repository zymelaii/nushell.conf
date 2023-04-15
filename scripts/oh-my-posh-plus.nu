#! \brief plugin for oh my posh

module oh-my-posh-plus {
    def theme-home [] {
        $'($env.USERPROFILE)\.oh-my-posh'
    }

    def prompt-theme [] {
        let themes = (ls (theme-home) | each {|e| $e.name | path basename | split column '.' theme | get theme } | flatten)
        $themes | each {|theme| $''($theme)'' }
    }

    # Change prompt theme provided by oh my posh
    export def-env prompt [theme: string@prompt-theme] {
        let-env POSH_THEME = $'(theme-home)\($theme).omp.json'
    }
}
