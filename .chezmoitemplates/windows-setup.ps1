# Install packages
# Windows packages hash {{ include "win-packages.json" | sha256sum }}
winget.exe import --accept-package-agreements --import-file $Env:CHEZMOI_SOURCE_DIR/win-packages.json
