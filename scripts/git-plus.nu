#! \brief plugin for git

module git-plus {
    def parse-subcmd-brief [raw: string] {
        let raw = ($raw | str trim)
        let subcmd = ($raw | split column ' ' | first | get column1)
        let brief = ($raw | str substring ($subcmd | str length).. | str trim)
        return {
            command: $subcmd,
            brief: $brief,
        }
    }

    def git-subcommands [] {
        let collection = (^git help --all | lines | each {|e| $e | find --regex '\s{2,}[a-zA-Z\-]+\s+.*$' })
        ($collection | each {|e| parse-subcmd-brief $e} | get command)
    }

    def git-branches [] {
        (^git branch | lines | str substring 2..)
    }

    def git-logfmt [] {
        [
            'brief',
            'contribution',
            'commit-ref',
        ]
    }

    # Completion program for git
    export def git-completer [spans: list<string>] {
        let cmd = ($spans.0 | str downcase | split column '.exe' target | first | get target)
        if $cmd != 'git' { return }

        let n = ($spans | length)
        let subcommands = (git-subcommands)

        if $n == 1 {
            $subcommands
        } else if $n == 2 {
            ($subcommands | filter {|e| $e | str starts-with $spans.1})
        } else if ($subcommands | find $spans.1 | length) == 1 {
            match $spans.1 {
                'switch' => {
                    (git-branches)
                },
            }
        }
    }

    # Convient git log shortcuts
    export def git-info [format: string@git-logfmt] {
        match $format {
            'brief' => {
                ^git log --pretty=%h»¦«%aN»¦«%s»¦«%aD | lines | split column "»¦«" sha1 committer desc merged_at
            }
            'contribution' => {
                ^git log --pretty=%h»¦«%aN»¦«%s»¦«%aD | lines | split column "»¦«" sha1 committer desc merged_at | histogram committer merger | sort-by merger | reverse
            },
            'commit-ref' => {
                ^git reflog --pretty=%h»¦«%aN»¦«%s»¦«%aD»¦«%D | lines | split column "»¦«" sha1 committer desc merged_at ref | uniq
            }
        }
    }
}
