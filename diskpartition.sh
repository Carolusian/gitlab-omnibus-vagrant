# Configure and mount second disk
sudo parted /dev/xvdb mklabel msdos
sudo parted /dev/xvdb mkpart primary 512 100%
sudo mkfs.ext4 /dev/xvdb
