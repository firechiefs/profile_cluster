## PURPOSE:

Configures AD clusting

## HIERA DATA:
DSC RRESORUCE
https://github.com/PowerShell/xFailOverCluster
```
profile::cluster::cfg:
  dsc_name: 'DNS short name'
  <required string>
  dsc_staticipaddress: 'Static IP Address of the cluster'
  <required string>
  dsc_domainadministratorcredential: {Credential used to create the cluster }
  <required hash (user,password)>
  dsc_retryintervalsec: Interval to check for cluster existence
  <required int>
  dsc_retrycount: Maximum number of retries to check for cluster existance
  <required int>

profile::windowsfeatures:
<hash of windows features required for Failover Clustering>
```
## HIERA EXAMPLE:
```
profile::cluster::cfg:
  dsc_name: 'clustername'
  dsc_staticipaddress: '10.10.10.10'
  dsc_domainadministratorcredential:
    user: 'domain\admin_acount'
    password: 'ecnrypted password'
  dsc_retryintervalsec: 10
  dsc_retrycount: 60

# Windows 2012 R2 Specific features
profile::windowsfeatures:
  Failover-Clustering:
    dsc_name: 'Failover-Clustering'
    dsc_ensure: 'present'
    dsc_includeallsubfeature: true
  RSAT-Clustering-CmdInterface:
    dsc_name: 'RSAT-Clustering-CmdInterface'
    dsc_ensure: 'present'
    dsc_includeallsubfeature: true
  RSAT-Clustering-Mgmt:
    dsc_name: 'RSAT-Clustering-Mgmt'
    dsc_ensure: 'present'
    dsc_includeallsubfeature: true
  RSAT-Clustering-PowerShell:
    dsc_name: 'RSAT-Clustering-PowerShell'
    dsc_ensure: 'present'
    dsc_includeallsubfeature: true
```

## MODULE DEPENDENCIES:
```
puppet module install puppetlabs-dsc
```
## USAGE:

#### Puppetfile:
```
mod 'puppetlabs-dsc',
  :git => 'https://github.com/puppetlabs/puppetlabs-dsc',
  :tag => '9f5c09cc194893040468cce12c4b036e4a54584a'

mod 'validation_script',
  :git => 'https://github.com/firechiefs/validate_decrypted_content',
  :ref => '1.0.0'

mod 'validation_script',
  :git => 'https://github.com/firechiefs/validation_script',
  :ref => '1.0.0'

mod 'profile_cluster',
  :git => 'https://github.com/firechiefs/profile_cluster',
  :ref => '1.0.0'
```
#### Manifests:
```
class role::*rolename* {
  include profile_cluster
}

```
