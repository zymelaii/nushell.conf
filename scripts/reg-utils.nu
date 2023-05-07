# List registered applications.
export def list-apps [
    --hklm, # show global applications
    --hkcu, # show local applications
] {
    let root = (if $hklm { 'HKLM' } else { 'HKCU' })
    let regPath = $'($root)\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths'
    let resp = (reg query $regPath | iconv --from gbk --to utf-8)
    let resp = ($resp | lines | each {|$e| $e | parse -r 'App Paths\\(?<name>.+)$'} | flatten | get name)
    return $resp
}

# Register new application locally.
export def append-app [
    appPath: string, # full path to application
] {
    if not ($appPath | path exists) {
        return
    }
    let key = $'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\($appPath | path basename)'
    do {
        reg add $key /f
        reg add $key /ve /d $appPath /f
        reg add $key /v Path /t REG_SZ /d ($appPath | path dirname) /f
    } | ignore
}

# Unregister local application.
export def remove-app [
    app: string, # executable of the target application
] {
    let appList = (list-apps --hkcu)
    mut appFull = $app
    if not ($app in $appList) {
        if not ($'($app).exe' in $appList) {
            return
        }
        $appFull = $'($app).exe'
    }
    let key = $'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\($appFull)'
    do {
        reg delete $key /f
    } | ignore
}
