#!/bin/bash
set -euo pipefail
ORIGEN_LOG="${1:-/var/log/messages}"
DIR_DESTINO="$HOME/nuevanet-proyecto/logs"
FECHA_ACTUAL=$(date +"%Y%m%d_%H%M%S")
ARCHIVO_REPORTE="$DIR_DESTINO/reporte_critico_$FECHA_ACTUAL.log"
LOG_EJECUCION="$DIR_DESTINO/auditoria_script.log"
manejar_error() {
    local codigo_salida=$?
    local linea=$1
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] [ERROR] Fallo en línea $linea (Código: $codigo_salida)." | tee -a "$LOG_EJECUCION" >&2
    exit "$codigo_salida"
}
trap 'manejar_error $LINENO' ERR
[ ! -d "$DIR_DESTINO" ] && mkdir -p "$DIR_DESTINO"
[ ! -e "$ORIGEN_LOG" ] && { echo "[ERROR] Origen no existe." >&2; exit 2; }
[ ! -r "$ORIGEN_LOG" ] && { echo "[ERROR] Permisos denegados." >&2; exit 3; }
grep -iE "error|fail|warn|denied" "$ORIGEN_LOG" > "$ARCHIVO_REPORTE" || true
find "$DIR_DESTINO" -type f -name "reporte_critico_*.log" -mtime +7 -exec rm -f {} \;
echo "[ÉXITO] Rutina finalizada." | tee -a "$LOG_EJECUCION"
exit 0
