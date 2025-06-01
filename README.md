# Appdynamics_Snmp_Extension based on  pulling  
# SNMP Metrics Extension

This is a custom SNMP Metrics Extension for the AppDynamics Machine Agent. It collects various system metrics (uptime, CPU, memory, disk usage, etc.) from an SNMP-enabled device (e.g., ESXi host) and reports them as custom metrics to AppDynamics.

---

## 📌 Features

✅ Collects system uptime  
✅ Collects disk allocation failures  
✅ Monitors CPU load per core  
✅ Monitors memory usage and usage percentage  
✅ Monitors disk usage and usage percentage  
✅ Easy integration with AppDynamics Machine Agent  

---

## 🚀 Getting Started

### Prerequisites

- AppDynamics Machine Agent installed and running.
- SNMP enabled on the target device.
- Bash shell and `snmpwalk` and `snmpget` utilities installed.

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/yourusername/snmp-metrics-extension.git
   cd snmp-metrics-extension

   cp -r snmp-metrics-extension /opt/appdynamics/machine-agent/monitors/

   chmod +x src/snmp-metrics.sh

   
   
