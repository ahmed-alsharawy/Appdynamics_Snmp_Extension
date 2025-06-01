#!/bin/bash

HOST="192.168.6.40"
COMMUNITY="public"

# Function to safely get SNMP values
get_oid() {
    snmpget -v2c -c "$COMMUNITY" -Ovq "$HOST" "$1" 2>/dev/null
}

# Function to emit metrics in required format
emit_metric() {
    echo "name=Custom Metrics|ESXi|$HOST|$1, value=$2, aggregator=OBSERVATION, time-rollup=AVERAGE, cluster-rollup=INDIVIDUAL"
}

# Get system uptime (correct OID: sysUpTime)
UPTIME_TICKS=$(snmpget -v2c -c $COMMUNITY $HOST .1.3.6.1.2.1.1.3.0 | awk -F'[()]' '{print $2}')
emit_metric "Uptime_Ticks" "${UPTIME_TICKS:-0}"

DISK_ALLOC_FAILURES=$(snmpwalk -v2c -c "$COMMUNITY" "$HOST" .1.3.6.1.2.1.25.2.3.1.7.1 | awk '{print $NF}')
emit_metric "Disk_Allocation_Failures" "${DISK_ALLOC_FAILURES:-0}"


Process_load=$(snmpwalk -v2c -c "$COMMUNITY" "$HOST" .1.3.6.1.2.1.25.3.3.1.2 | awk '{print $NF}')
emit_metric "Process_load" "${Process_load:-0}"


Total_Memory=$(snmpwalk -v2c -c "$COMMUNITY" "$HOST" .1.3.6.1.2.1.25.2.3.1.5.5 | awk '{print $NF}')
emit_metric "Total_Memory" "${Total_Memory:-0}"


TOTAL_MEM=$(snmpwalk -v2c -c "$COMMUNITY" "$HOST" .1.3.6.1.2.1.25.2.3.1.5.5 | awk '{print $NF}')
USED_MEM=$(snmpwalk -v2c -c "$COMMUNITY" "$HOST" .1.3.6.1.2.1.25.2.3.1.6.5 | awk '{print $NF}')

emit_metric "Memory_Total_Units" "${TOTAL_MEM:-0}"
emit_metric "Memory_Used_Units" "${USED_MEM:-0}"

if [[ -n "$TOTAL_MEM" && "$TOTAL_MEM" =~ ^[0-9]+$ && "$TOTAL_MEM" -ne 0 ]]; then
    MEM_PCT=$(( 100 * USED_MEM / TOTAL_MEM ))
    emit_metric "Memory_Usage_Percent" "$MEM_PCT"
fi





# Get CPU loads for all cores
while IFS= read -r line; do
    if [[ "$line" =~ hrProcessorLoad\.([0-9]+)\ =\ INTEGER:\ ([0-9]+) ]]; then
        core="${BASH_REMATCH[1]}"
        load="${BASH_REMATCH[2]}"
        emit_metric "CPU_Load_Core_${core}" "$load"
    fi
done < <(snmpwalk -v2c -c "$COMMUNITY" "$HOST" .1.3.6.1.2.1.25.3.3.1.2)
 
 
    
for i in {1..5}; do
    DESC=$(snmpwalk -v2c -c "$COMMUNITY" "$HOST" .1.3.6.1.2.1.25.2.3.1.3.$i | awk -F': ' '{print $2}')
    USED=$(snmpwalk -v2c -c "$COMMUNITY" "$HOST" .1.3.6.1.2.1.25.2.3.1.6.$i | awk '{print $NF}')
    SIZE=$(snmpwalk -v2c -c "$COMMUNITY" "$HOST" .1.3.6.1.2.1.25.2.3.1.5.$i | awk '{print $NF}')

    if [[ -n "$DESC" && "$USED" =~ ^[0-9]+$ && "$SIZE" =~ ^[0-9]+$ && "$SIZE" -ne 0 ]]; then
        NAME=$(echo "$DESC" | tr ' ' '_' | tr -cd '[:alnum:]_')
        PCT=$(( 100 * USED / SIZE ))
        emit_metric "${NAME}_Used_Units" "$USED"
        emit_metric "${NAME}_Total_Units" "$SIZE"
        emit_metric "${NAME}_Usage_Percent" "$PCT"
    fi
done
