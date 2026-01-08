#!/bin/bash
set -e

echo "🚀 Installation du client WoW 5.4.8"

commands/client_github.sh
commands/client_gdrive.sh
commands/client_extract.sh
commands/client_move.sh

echo "✅ Client prêt dans app/client"
