**dash1 for Vsphere Vcenter**
Terraform module to setup dash1 as infrastructure for apollo on vsphere vcenter. Key facts are:

## Deploys (Single/Multiple) Windows Virtual Machines to your vSphere environment

This Terraform module deploys single or multiple virtual machines of type (Windows) with following features:

- Ability to specify Windows VM customization.
- Ability to add extra data disk (up to 15) to the VM.
- Ability to deploy Multiple instances.
- Ability to set IP and Gateway configuration for the VM.
- Ability to add multiple network cards for the VM
- Ability to choose vSphere resource pool or fall back to Cluster/ESXi root resource pool.
- Ability to deploy Windows images to WorkGroup or Domain.
- Ability to output VM names and IPs per module.
- Ability assign tags and custom variables.
- Ability to configure advance features for the vm.
- Ability to deploy either a datastore or a datastore cluster.
- Ability to enable cpu and memory hot plug features for the VM.

> Note: For module to work it needs number of required variables corresponding to an existing resources in vSphere. Please refer to variable section for the list of required variables.

**usage**

```
module "example-server-windowsvm" {
  vmtemp           = "TemplateName"
  is_windows_image = "true"
  instances        = 1
  vmname           = "example-server-windows"
  vmrp             = "esxi/Resources"
  network_cards    = ["Name of the Port Group in vSphere"]
  ipv4 = {
    "Name of the Port Group in vSphere" = ["10.0.0.1"] # To use DHCP create Empty list for each instance
  }
  dc        = "Datacenter"
  datastore = "Data Store name(use ds_cluster for datastore cluster)"
}
```



**Advanced Usage**

```
module "example-server-windowsvm-advanced" {
  dc                     = "Datacenter"
  vmrp                   = "cluster/Resources" #Works with ESXi/Resources
  vmfolder               = "Cattle"
  ds_cluster             = "Datastore Cluster" #You can use datastore variable instead
  vmtemp                 = "TemplateName"
  instances              = 2
  cpu_number             = 2
  ram_size               = 2096
  cpu_hot_add_enabled    = "true"
  cpu_hot_remove_enabled = "true"
  memory_hot_add_enabled = "true"
  vmname                 = "AdvancedVM"
  vmdomain               = "somedomain.com"
  network_cards          = ["VM Network", "test-network"] #Assign multiple cards
  ipv4submask            = ["24", "8"]
  ipv4 = { #assign IPs per card
    "VM Network" = ["192.168.0.4", ""] // Here the first instance will use Static Ip and Second DHCP
    "test"       = ["", "192.168.0.3"]
  }
  data_disk_size_gb = [10, 5] // Aditional Disk to be used
  thin_provisioned  = ["true", "false"]
  vmdns             = ["192.168.0.2", "192.168.0.1"]
  vmgateway         = "192.168.0.1"
  tags = {
    "terraform-test-category"    = "terraform-test-tag"
    "terraform-test-category-02" = "terraform-test-tag-02"
  }
  enable_disk_uuid = "true"
  auto_logon       = "true"
  run_once         = ["command01", "command02"] // You can also run Powershell commands
  orgname          = "Terraform-Module"
  workgroup        = "Module-Test"
  is_windows_image = "true"
  firmware         = "efi"
  local_adminpass  = "Password@Strong"
}
```

