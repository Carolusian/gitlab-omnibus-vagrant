# Configure and mount second disk
sudo parted /dev/sdb mklabel msdos
sudo parted /dev/sdb mkpart primary 512 100%
sudo mkfs.ext4 /dev/sdb1
