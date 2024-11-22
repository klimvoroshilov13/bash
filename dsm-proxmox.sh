#!/bin/bash

# Set variables
VM_ID=100
VM_NAME="dsm"
ARC_URL="https://github.com/AuxXxilium/arc/releases/download/1.1.5/arc-1.1.5-stable.img.zip"
ARC_IMG_ZIP="arc.img.zip"
ARC_IMG="arc.img"
DISK_SIZE="512G"
CORES=4
MEMORY=8192
BRIDGE="vmbr1"
STORAGE_ZFS="local-zfs"
STORAGE_LVM="local-lvm"

# Download and decompress the image
echo "Downloading VM image..."
wget -q --show-progress "${ARC_URL}" -O "${ARC_IMG_ZIP}"
if [ $? -ne 0 ]; then
  echo "Error downloading the image. Check the URL."
  exit 1
fi

echo "Extracting VM image..."
unzip -qo "${ARC_IMG_ZIP}" || { echo "Failed to extract the image."; exit 1; }

# Allocate storage for SATA1
echo "Allocating storage on ${STORAGE_ZFS}..."
pvesm alloc "${STORAGE_ZFS}" "${VM_ID}" "vm-${VM_ID}-disk-1" "${DISK_SIZE}"
if [ $? -ne 0 ]; then
  echo "Failed to allocate storage."
  exit 1
fi

# Create the VM
echo "Creating VM with ID ${VM_ID}..."
qm create "${VM_ID}" \
  --name "${VM_NAME}" \
  --ostype l26 \
  --machine q35 \
  --cores "${CORES}" \
  --memory "${MEMORY}" \
  --numa 0 \
  --sockets 1 \
  --net0 virtio,bridge="${BRIDGE}" \
  --boot order=sata0 \
  --scsihw virtio-scsi-pci \
  --sata0 "${STORAGE_LVM}:0,import-from=/root/${ARC_IMG},cache=writeback" \
  --sata1 "${STORAGE_ZFS}:vm-${VM_ID}-disk-1,cache=writeback,size=${DISK_SIZE}"

if [ $? -ne 0 ]; then
  echo "Failed to create the VM."
  exit 1
fi

# Cleanup
echo "Cleaning up temporary files..."
rm -f "${ARC_IMG}" "${ARC_IMG_ZIP}"

echo "VM with ID ${VM_ID} created successfully!"

# star vm
#qm start ${vm}

# loader web interface
# http://ip:7681/ 

# NAS web interface
# http://ip:5000/

# прокинуть диски в виртуальную машину
# lsblk
# qm set 100 -sata2 /dev/sdc
# qm set 100 -sata3 /dev/sdd

# Репозиторий сообщества
# https://synopackage.com/repository/spk/All
# https://packages.synocommunity.com/
# https://spk7.imnks.com 