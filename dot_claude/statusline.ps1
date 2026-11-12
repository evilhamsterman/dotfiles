# Claude Code status line: dir, git branch, model, context usage
$in = [Console]::In.ReadToEnd() | ConvertFrom-Json
$e = [char]27
$dir = if ($in.workspace.current_dir) { $in.workspace.current_dir } else { $in.cwd }
$short = if ($dir) { $dir.Replace($HOME, '~') } else { '' }

$out = "$e[34m$short$e[0m"
$branch = git -C $dir symbolic-ref --short HEAD 2>$null
if ($branch) { $out += " $e[94m$([char]0xe725) $branch$e[0m" }
if ($in.model.display_name) { $out += " $e[2m· $($in.model.display_name)$e[0m" }
if ($null -ne $in.context_window.used_percentage) {
    $out += " $e[2m· ctx $([math]::Round($in.context_window.used_percentage))%$e[0m"
}
[Console]::Out.Write($out)
