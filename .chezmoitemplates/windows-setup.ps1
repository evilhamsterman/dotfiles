# Install packages
winget.exe import --accept-package-agreements --import-file $Env:CHEZMOI_SOURCE_DIR/win-packages.json
