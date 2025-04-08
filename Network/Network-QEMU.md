# QEMU Network Security 

This guide provides end-to-end documentation for setting up a network security testing lab using QEMU virtual machines. This setup allows you to create isolated environments for security testing, penetration testing practice, and network analysis.

## Prerequisites

- Linux host system (Ubuntu/Debian recommended)
- Root/sudo access
- At least 50GB free disk space
- 8GB+ RAM recommended
- QEMU and KVM installed

## 1. Installation of Required Software

```bash
# For Debian/Ubuntu systems
sudo apt update
sudo apt install -y qemu-kvm qemu-system-x86 qemu-utils bridge-utils virt-manager libvirt-daemon-system
sudo apt install -y uml-utilities net-tools

# Enable and start libvirt service
sudo systemctl enable libvirtd
sudo systemctl start libvirtd

# Add your user to relevant groups
sudo usermod -aG kvm $USER
sudo usermod -aG libvirt $USER
```

## 2. Download Required ISO Images

```bash
# Create a directory for ISO files
mkdir -p ~/qemu/isos
cd ~/qemu/isos

# Download Kali Linux ISO (adjust URL for latest version)
wget https://cdimage.kali.org/kali-2023.1/kali-linux-2023.1-installer-amd64.iso

# Download a vulnerable target OS (Metasploitable as an example)
wget https://downloads.metasploit.com/data/metasploitable/metasploitable-linux-2.0.0.zip
unzip metasploitable-linux-2.0.0.zip

# Alternative: Download a minimal Ubuntu Server ISO for target systems
wget https://releases.ubuntu.com/22.04/ubuntu-22.04.3-live-server-amd64.iso
```

## 3. Create Virtual Disk Images

```bash
# Create a directory for disk images
mkdir -p ~/qemu/images
cd ~/qemu/images

# Create a disk for Kali Linux (30GB)
qemu-img create -f qcow2 kali.qcow2 30G

# Create disks for target systems (10GB each)
qemu-img create -f qcow2 target1.qcow2 10G
qemu-img create -f qcow2 target2.qcow2 10G
```

## 4. Set Up Network Infrastructure

### 4.1 Create a Bridge Network Interface

```bash
# Create a network bridge configuration file
sudo nano /etc/network/interfaces.d/bridge

# Add the following content
auto br0
iface br0 inet static
        address 192.168.100.1
        netmask 255.255.255.0
        bridge_ports none
        bridge_stp off
        bridge_fd 0
        bridge_maxwait 0

# Save and exit

# Bring up the bridge
sudo ifup br0

# Configure IP forwarding
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward

# Make IP forwarding persistent
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Set up NAT for the bridge
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -A FORWARD -i br0 -o eth0 -j ACCEPT
sudo iptables -A FORWARD -i eth0 -o br0 -m state --state RELATED,ESTABLISHED -j ACCEPT

# Make iptables rules persistent
sudo apt install -y iptables-persistent
sudo netfilter-persistent save
```

### 4.2 Create TAP Interfaces for VMs

```bash
# Create tap interfaces for each VM
sudo ip tuntap add dev tap0 mode tap user $USER
sudo ip tuntap add dev tap1 mode tap user $USER
sudo ip tuntap add dev tap2 mode tap user $USER

# Add tap interfaces to the bridge
sudo ip link set tap0 master br0
sudo ip link set tap1 master br0
sudo ip link set tap2 master br0

# Bring up the tap interfaces
sudo ip link set tap0 up
sudo ip link set tap1 up
sudo ip link set tap2 up

# Create a script to set up these interfaces automatically
cat > ~/qemu/setup_network.sh << 'EOF'
#!/bin/bash
# Set up bridge and tap interfaces
sudo ip link add br0 type bridge
sudo ip addr add 192.168.100.1/24 dev br0
sudo ip link set br0 up

# Create tap interfaces
sudo ip tuntap add dev tap0 mode tap user $USER
sudo ip tuntap add dev tap1 mode tap user $USER
sudo ip tuntap add dev tap2 mode tap user $USER

# Add taps to bridge
sudo ip link set tap0 master br0
sudo ip link set tap1 master br0
sudo ip link set tap2 master br0

# Bring up tap interfaces
sudo ip link set tap0 up
sudo ip link set tap1 up
sudo ip link set tap2 up

# Enable IP forwarding and NAT
sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables -t nat -A POSTROUTING -o $(ip route | grep default | awk '{print $5}') -j MASQUERADE
sudo iptables -A FORWARD -i br0 -j ACCEPT
sudo iptables -A FORWARD -o br0 -j ACCEPT
EOF

chmod +x ~/qemu/setup_network.sh
```

## 5. Install Kali Linux VM

```bash
# Create a script to install Kali
cat > ~/qemu/install_kali.sh << 'EOF'
#!/bin/bash
sudo qemu-system-x86_64 \
  -name "Kali Linux" \
  -m 4G \
  -enable-kvm \
  -cpu host \
  -smp cores=2 \
  -boot d \
  -drive file=$HOME/qemu/images/kali.qcow2,format=qcow2 \
  -cdrom $HOME/qemu/isos/kali-linux-2023.1-installer-amd64.iso \
  -device e1000,netdev=net0,mac=52:54:00:12:34:56 \
  -netdev tap,id=net0,ifname=tap0,script=no,downscript=no \
  -vga virtio \
  -display sdl
EOF

chmod +x ~/qemu/install_kali.sh

# Run the installation
~/qemu/install_kali.sh

# Follow the on-screen installation instructions:
# 1. Select your language, location, and keyboard
# 2. Set up hostname (e.g., kali)
# 3. Create a user account and password
# 4. Partition the disk (use guided - use entire disk)
# 5. Select packages (default Kali installation)
# 6. Complete installation and reboot
```

## 6. Create Start Scripts for VMs

### 6.1 Kali Linux Start Script

```bash
cat > ~/qemu/start_kali.sh << 'EOF'
#!/bin/bash
sudo qemu-system-x86_64 \
  -name "Kali Linux" \
  -m 4G \
  -enable-kvm \
  -cpu host \
  -smp cores=2 \
  -drive file=$HOME/qemu/images/kali.qcow2,format=qcow2 \
  -device e1000,netdev=net0,mac=52:54:00:12:34:56 \
  -netdev tap,id=net0,ifname=tap0,script=no,downscript=no \
  -vga virtio \
  -display sdl
EOF

chmod +x ~/qemu/start_kali.sh
```

### 6.2 Target 1 VM (Install Ubuntu)

```bash
cat > ~/qemu/install_target1.sh << 'EOF'
#!/bin/bash
sudo qemu-system-x86_64 \
  -name "Target 1" \
  -m 2G \
  -enable-kvm \
  -cpu host \
  -smp cores=1 \
  -boot d \
  -drive file=$HOME/qemu/images/target1.qcow2,format=qcow2 \
  -cdrom $HOME/qemu/isos/ubuntu-22.04.3-live-server-amd64.iso \
  -device e1000,netdev=net0,mac=52:54:00:12:34:57 \
  -netdev tap,id=net0,ifname=tap1,script=no,downscript=no \
  -vga virtio \
  -display sdl
EOF

chmod +x ~/qemu/install_target1.sh

# Run the installation
~/qemu/install_target1.sh

# Create a start script
cat > ~/qemu/start_target1.sh << 'EOF'
#!/bin/bash
sudo qemu-system-x86_64 \
  -name "Target 1" \
  -m 2G \
  -enable-kvm \
  -cpu host \
  -smp cores=1 \
  -drive file=$HOME/qemu/images/target1.qcow2,format=qcow2 \
  -device e1000,netdev=net0,mac=52:54:00:12:34:57 \
  -netdev tap,id=net0,ifname=tap1,script=no,downscript=no \
  -vga virtio \
  -display sdl
EOF

chmod +x ~/qemu/start_target1.sh
```

### 6.3 Target 2 VM (Using Metasploitable)

```bash
cat > ~/qemu/start_target2.sh << 'EOF'
#!/bin/bash
sudo qemu-system-x86_64 \
  -name "Metasploitable" \
  -m 1G \
  -enable-kvm \
  -cpu host \
  -smp cores=1 \
  -drive file=$HOME/qemu/isos/Metasploitable.vmdk,format=vmdk \
  -device e1000,netdev=net0,mac=52:54:00:12:34:58 \
  -netdev tap,id=net0,ifname=tap2,script=no,downscript=no \
  -vga virtio \
  -display sdl
EOF

chmod +x ~/qemu/start_target2.sh
```

## 7. Setting Up a DHCP Server (Optional)

For a more realistic network environment, you can set up a DHCP server on your host:

```bash
# Install DHCP server
sudo apt install -y isc-dhcp-server

# Configure DHCP server
sudo nano /etc/dhcp/dhcpd.conf

# Add the following configuration
subnet 192.168.100.0 netmask 255.255.255.0 {
  range 192.168.100.10 192.168.100.50;
  option domain-name-servers 8.8.8.8, 8.8.4.4;
  option routers 192.168.100.1;
  default-lease-time 600;
  max-lease-time 7200;
}

# Configure DHCP server to listen on the bridge
sudo nano /etc/default/isc-dhcp-server
# Set INTERFACESv4="br0"

# Restart DHCP service
sudo systemctl restart isc-dhcp-server
```

## 8. Testing Your Network

Once all VMs are running, you can verify network connectivity:

### 8.1 From Kali Linux:

1. Log in with your created credentials
2. Open a terminal
3. Run `ip a` to check your IP address (should be in 192.168.100.x range)
4. Try to ping other machines and the internet:
   ```
   ping 192.168.100.1
   ping [Target1_IP]
   ping 8.8.8.8
   ping google.com
   ```

### 8.2 From Target VMs:

Similarly, verify network connectivity from target VMs.

## 9. Security Testing Scenarios

Here are some scenarios you can practice:

### 9.1 Network Scanning from Kali

```bash
# Basic network discovery
sudo nmap -sn 192.168.100.0/24

# Full port scan of a target
sudo nmap -sS -sV -p- [Target_IP]

# Vulnerability scanning
sudo nmap -sV --script vuln [Target_IP]
```

### 9.2 Setting Up Vulnerable Services

On Target 1:

```bash
# Install and misconfigure services for practice
sudo apt install -y apache2 mysql-server vsftpd
```

## 10. Troubleshooting

### Network Issues

If VMs can't connect to the network:

1. Verify bridge and tap interfaces are up:
   ```
   ip a | grep -E 'br0|tap'
   ```

2. Check that IP forwarding is enabled:
   ```
   cat /proc/sys/net/ipv4/ip_forward
   ```

3. Verify iptables rules:
   ```
   sudo iptables -L -v
   sudo iptables -t nat -L -v
   ```

4. Restart network services:
   ```
   sudo systemctl restart networking
   ```

### VM Boot Problems

If a VM fails to boot (like in your screenshot):

1. Verify the boot order in the QEMU command
2. Ensure the disk image exists and is properly formatted
3. Check that the installation ISO is valid

## 11. Snapshots and VM Management

### Creating Snapshots

```bash
# Create a snapshot of a clean VM state
qemu-img snapshot -c clean_state ~/qemu/images/kali.qcow2

# List available snapshots
qemu-img snapshot -l ~/qemu/images/kali.qcow2

# Revert to a snapshot
qemu-img snapshot -a clean_state ~/qemu/images/kali.qcow2
```

### Converting VM Formats

```bash
# Convert from one format to another
qemu-img convert -f qcow2 -O vmdk ~/qemu/images/kali.qcow2 ~/qemu/images/kali.vmdk
```

## 12. Advanced QEMU Features

### GUI Management with virt-manager

For easier VM management, you can use virt-manager:

```bash
sudo apt install -y virt-manager
sudo virt-manager
```

### QEMU Monitor Commands

During VM execution, press `Ctrl+Alt+2` to access the QEMU monitor, where you can:

- Control VM state: `stop`, `cont`, `system_reset`
- Take screenshots: `screendump filename.ppm`
- Manage devices: `info block`, `change ide1-cd0 /path/to/new.iso`
- Return to VM: `Ctrl+Alt+1`
