name "ceph-osd"
description "The role for Ceph OSDs providing storage for the Ceph system"
run_list ["recipe[base_packages::debian]", "recipe[ceph-base]","recipe[ceph-osd]"]
