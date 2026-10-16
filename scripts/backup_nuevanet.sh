#!/bin/bash
set -euo pipefail
USUARIO_HOME="/home/ec2-user"
DIR_ORIGEN="$USUARIO_HOME/nuevanet-proyecto/datos_criticos"
DIR_BACKUP="$USUARIO_HOME/nuevanet-proyecto/backups"
ARCHIVO_METADATOS="$DIR_BACKUP/control_incremental.snar"
LOG_BACKUP="$USUARIO_HOME/nuevanet-proyecto/logs/historial_backups.log"
FECHA=$(date +"%Y%m%d_%H%M%S")
DIA_SEMANA=$(date +"%u")

mkdir -p "$DIR_BACKUP" "$(dirname "$LOG_BACKUP")"

if [ ! -d "$DIR_ORIGEN" ] || [ -z "$(ls -A "$DIR_ORIGEN" 2>/dev/null)" ]; then
    echo "[$FECHA] [ERROR] Directorio origen vacío o inexistente." | tee -a "$LOG_BACKUP" >&2
    exit 1
fi

MODO_SOLICITADO="${1:-auto}"
if [ "$MODO_SOLICITADO" == "completo" ] || [ "$DIA_SEMANA" -eq 7 ] || [ ! -f "$ARCHIVO_METADATOS" ]; then
    TIPO="COMPLETO"
    ARCHIVO_FINAL="$DIR_BACKUP/respaldo_COMPLETO_$FECHA.tar.gz"
    rm -f "$ARCHIVO_METADATOS"
else
    TIPO="INCREMENTAL"
    ARCHIVO_FINAL="$DIR_BACKUP/respaldo_INCREMENTAL_$FECHA.tar.gz"
fi

tar --listed-incremental="$ARCHIVO_METADATOS" -czf "$ARCHIVO_FINAL" -C "$DIR_ORIGEN" . 2>>"$LOG_BACKUP"
sha256sum "$ARCHIVO_FINAL" > "$ARCHIVO_FINAL.sha256"
echo "[$FECHA] [ÉXITO] Respaldo $TIPO creado: $ARCHIVO_FINAL" | tee -a "$LOG_BACKUP"
exit 0
