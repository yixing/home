# GRUB2的配置

查询所有entry

    # awk -F \' '$1=="menuentry " {print i++ " : " $2}' /boot/efi/EFI/centos/grub.cfg
    0 : CentOS Linux (4.20.17.v7) 7 (Core)
    1 : CentOS Linux (3.10.0-957.21.3.el7.x86_64) 7 (Core)
    2 : CentOS Linux (3.10.0-693.el7.x86_64) 7 (Core)
    3 : CentOS Linux (0-rescue-c7c384c2474a414aad002fbde9b4395f) 7 (Core)
    4 : Windows Boot Manager (on /dev/nvme1n1p2)

查询当前default

    # grub2-editenv list
    saved_entry=CentOS Linux (3.10.0-957.21.3.el7.x86_64) 7 (Core)

更新

    # grub2-set-default 0
    # grub2-editenv list
    saved_entry=0
