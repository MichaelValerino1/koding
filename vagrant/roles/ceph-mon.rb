name "ceph-mon"
description "The role for Ceph Monitors"
run_list ["recipe[base_packages::debian]", "recipe[ceph-base]","recipe[ceph-mon]"]