# Install NFS Application
sudo apt install nfs-kernel-server nfs-common -y

#Format the second Disk without userinteraction. 
echo -e 'n\np\n1\n\n\nw' | sudo fdisk /dev/sdb
#Create EXT4 FS
sudo mkfs.ext4 /dev/sdb1


#Create a Folder and mount the Folder to the newly formated Disk 
sudo mkdir /nfs
sudo mount /dev/sdb1 /nfs
echo '/dev/sdb1       /nfs    ext4    defaults     0   0' | sudo tee -a /etc/fstab


#Create a Subfolder for the NFS Share
sudo mkdir /nfs/subdir_name -p


#Make an entry for the Subfolder in /etc/exports
echo '/nfs/subdir_name              *(rw,sync,no_root_squash,no_subtree_check)' | sudo tee -a /etc/exports
sudo chown nobody:nogroup /nfs/subdir_name

#Restart the NFS Server
sudo systemctl restart nfs-kernel-server
