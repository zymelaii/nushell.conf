# Git plugin

def parse-subcmd-brief [raw: string] {
    let raw = ($raw | str trim)
    let subcmd = ($raw | split column ' ' | first | get column1)
    let brief = ($raw | str substring ($subcmd | str length).. | str trim)
    return {
        command: $subcmd,
        brief: $brief,
    }
}

def git-helper-command [] {
    [subcmd branch]
}

# Get helpful infomation from current repo.
export def git-helper [
    command: string@git-helper-command
] {
    match $command {
        subcmd => {
            let collection = (^git help --all | lines | each {|e| $e | find --regex '\s{2,}[a-zA-Z\-]+\s+.*$' })
            $collection | each {|e| parse-subcmd-brief $e} | get command
        },
        branch => {
            ^git branch --all |
                lines |
                str substring 2.. |
                parse -r '(remotes/(?<name>[^/]+)/)?((?!HEAD)(?<branch>[^\s]*)|.*)$' |
                select name branch |
                where branch != ''
        },
    }
}

def git-switch-completer [spans: list<string>] {
    let n = ($spans | length)
    match $n {
        1 => {
            git-helper branch |
                where name == '' |
                get branch |
                filter {|e| $e | str starts-with $spans.2}
        },
    }
}

# Completion program for git
export def git-completer [spans: list<string>] {
    let cmd = ($spans.0 | str downcase | split column '.exe' target | first | get target)
    if $cmd != 'git' { return }

    let n = ($spans | length)
    let subcommands = (git-helper subcmd)

    if $n == 2 {
        return ($subcommands | filter {|e| $e | str starts-with $spans.1})
    }

    if ($subcommands | find -r $'^($spans.1)$' | length) == 1 {
        match $spans.1 {
            'switch' => {
                git-helper branch |
                where name == '' |
                get branch |
                filter {|e| $e | str starts-with $spans.2}
            },
            'checkout' => {
                if $n > 3 and ($spans.2 | str downcase) == '-b' {
                    if $n == 4 {
                        git-helper branch |
                            where name == '' |
                            get branch |
                            filter {|e| $e | str starts-with $spans.3}
                    } else if $n == 5 {
                        git-helper branch |
                            where name != '' |
                            filter {|e| true in ([$'($e.name)/($e.branch)' $e.branch] | str starts-with $spans.4)} |
                            each {|$e| $'($e.name)/($e.branch)'}
                    }
                }
            }
        }
    }
}

# Convient git log shortcuts
def git-info-option [] {
    [
        'brief',
        'contribution',
        'commit-ref'
    ]
}

export def git-info [
    format: string@git-info-option
] {
    match $format {
        'brief' => {
            ^git log --pretty=%h»¦«%aN»¦«%s»¦«%aD |
                lines |
                split column "»¦«" sha1 committer desc merged_at
        }
        'contribution' => {
            ^git log --pretty=%h»¦«%aN»¦«%s»¦«%aD |
                lines |
                split column "»¦«" sha1 committer desc merged_at |
                histogram committer merger |
                sort-by merger |
                reverse
        },
        'commit-ref' => {
            ^git reflog --pretty=%h»¦«%aN»¦«%s»¦«%aD»¦«%D |
            lines |
            split column "»¦«" sha1 committer desc merged_at ref |
            uniq
        }
    }
}
