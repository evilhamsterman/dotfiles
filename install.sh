#!/bin/sh

# -e: exit on error
# -u: exit on unset variables
set -eu

env | sort

# Clear config already there
if [ -d "$HOME/.config/chezmoi" ]; then
	rm -r $HOME/.config/chezmoi
fi

if ! chezmoi="$(command -v chezmoi)"; then
	bin_dir="${HOME}/.local/bin"
	chezmoi="${bin_dir}/chezmoi"
	echo "Installing chezmoi to '${chezmoi}'" >&2
	if command -v curl; then
		echo "Using curl to get script"
		chezmoi_install_script="$(curl -fsSL get.chezmoi.io)"
	elif command -v wget; then
		echo "Using wget to get script"
		chezmoi_install_script="$(wget -qO- get.chezmoi.io)"
	else
		echo "To install chezmoi, you must have curl or wget installed." >&2
		exit 1
	fi
	echo "Executing install script"
	sh -c "${chezmoi_install_script}" -- -b "${bin_dir}" -d
	unset chezmoi_install_script bin_dir
fi

# POSIX way to get script's dir: https://stackoverflow.com/a/29834779/12156188
script_dir="$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)"

set -- init --apply --source="${script_dir}"

echo "Running 'chezmoi $*'" >&2
# exec: replace current process with chezmoi
exec "$chezmoi" "$@"
