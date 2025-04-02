# Documentación de Seguridad en Redes y Sistemas

## Tabla de Contenidos
1. [Configuración de dispositivos de seguridad perimetral](#configuracion-de-dispositivos-de-seguridad-perimetral)
   1.1. [Sistema Operativo](#sistema-operativo)
   1.2. [Firewall](#firewall)
   1.3. [Esquema de red](#esquema-de-red)
   1.4. [Configuración de firewall](#configuracion-de-firewall)
2. [Detección de errores de configuración mediante análisis de tráfico](#deteccion-de-errores-de-configuracion-mediante-analisis-de-trafico)
3. [Identificación de comportamientos no deseados en la red a través del análisis de logs](#identificacion-de-comportamientos-no-deseados-en-la-red-a-traves-del-analisis-de-logs)
4. [Implementación de contramedidas frente a comportamientos no deseados](#implementacion-de-contramedidas-frente-a-comportamientos-no-deseados)
5. [Caracterización, instalación y configuración de herramientas de monitorización](#caracterizacion-instalacion-y-configuracion-de-herramientas-de-monitorizacion)

---

## Configuración de dispositivos de seguridad perimetral

### Sistema Operativo
Rocky Linux es una distribución enfocada en entornos empresariales y servidores, diseñada para ser un clon binario de Red Hat Enterprise Linux (RHEL) siendo el sucesor de CentOS.

### Firewall
Iptables es una herramienta de Linux que filtra el tráfico de red entrante y saliente. Actúa como un firewall que controla las conexiones que se permiten y las que se bloquean.

### Esquema de red
![Esquema](img/bastionado.png)
El esquema consta de un Rocky Linux 9.5 como router usando Iptables como firewall y cockpit para el sistema de monitoreo, tendra una DMZ en la subred 10.0.0.0/8 para los servicios que se van a exponer al exterior, una LAN en la subred 172.16.0.0/16 y por separado estara suricata en la red 205.124.212.252/30 que va a monitorizar todo el trafico que entre a la red con elasticsearch, kibana y filebeats para la recoleccion de logs
### Configuración de firewall
```bash
#!/bin/bash
# Preguntan al ususario las interfaces
read -p "Pon la interfaz WAN: " WAN
read -p "Pon la interfaz LAN: " LAN
read -p "IP del IPS: " IPS

# Limpiar todas las reglas de iptables
iptables -F
iptables -X
iptables -Z
iptables -t nat -F

# Establecer por defecto aceptar todo el trafico
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -t nat -P PREROUTING ACCEPT
iptables -t nat -P POSTROUTING ACCEPT
# Permitir todo el trafico en localhost
iptables -A INPUT -i lo -j ACCEPT
# Habilitar el reenvio de paquetes
echo 1 > /proc/sys/net/ipv4/ip_forward
# Configurar el NAT para que la red local pueda acceder a internet
iptables -t nat -A POSTROUTING -o $WAN -j MASQUERADE
# Permitir conexiones establecidas
iptables -A FORWARD -i $WAN -o $LAN -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i $LAN -o $WAN -j ACCEPT
# Configura el reenvío del puerto 2222 al puerto SSH
iptables -A INPUT -p tcp --dport 2222 -j ACCEPT
iptables -t nat -A PREROUTING -p tcp --dport 2222 -j DNAT --to-destination $IPS:22
# Agregar reglas específicas para permitir conexiones SSH al IPS
iptables -A FORWARD -p tcp -d $IPS --dport 22 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -p tcp -s $IPS --sport 22 -m state --state ESTABLISHED -j ACCEPT
# Enviar copias de todo el tráfico al IPS
iptables -t mangle -A PREROUTING -j TEE --gateway $IPS
iptables -t mangle -A POSTROUTING -j TEE --gateway $IPS
```

## Detección de errores de configuración mediante análisis de tráfico
<!-- Métodos y herramientas para identificar errores de configuración analizando el tráfico de red. -->

## Identificación de comportamientos no deseados en la red a través del análisis de logs
<!-- Procedimientos para analizar logs y detectar actividades sospechosas o no deseadas. -->

## Implementación de contramedidas frente a comportamientos no deseados
<!-- Estrategias y técnicas para mitigar comportamientos no deseados en la red. -->

## Caracterización, instalación y configuración de herramientas de monitorización
### Instalacion de Cockpit
#### Base Debian
```bash
echo "deb http://deb.debian.org/debian ${VERSION_CODENAME}-backports main" > \
    /etc/apt/sources.list.d/backports.list
apt update

apt install -t ${VERSION_CODENAME}-backports cockpit -y
```

#### Base Ubuntu
```bash
sudo apt install -t ${VERSION_CODENAME}-backports cockpit
```

#### Base RHEL

```bash
sudo dnf install cockpit
sudo systemctl enable --now cockpit.socket
```

#### Base Arch

```bash
sudo pacman -S cockpit
sudo systemctl enable --now cockpit.socket
```

Acceder a `https://$ip:9090/`