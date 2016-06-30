# Configures AD clusting

# DSC RRESORUCE dsc_xwaitforcluster
# https://github.com/PowerShell/xFailOverCluster

# HIERA DATA
# profile::cluster::cfg:
#   dsc_name: 'DNS short name'
#              required string
#   dsc_staticipaddress: 'Static IP Address of the cluster'
#                         required string
#   dsc_domainadministratorcredential: {Credential used to create the cluster }
#                                      required hash (user,password)
#   dsc_retryintervalsec: Interval to check for cluster existence
#                         required int
#   dsc_retrycount: Maximum number of retries to check for cluster existance
#                   required int
#
# profile::windowsfeatures:
#   { hash of windows features required for Failover Clustering}

# HIERA EXAMPLE:
# Windows 2012 R2 Specific features
# profile::cluster::cfg:
#   dsc_name: 'clustername'
#   dsc_staticipaddress: '10.10.10.10'
#   dsc_domainadministratorcredential:
#     user: 'domain\admin_acount'
#     password: 'ecnrypted password'
#   dsc_retryintervalsec: 10
#   dsc_retrycount: 60
#
# profile::windowsfeatures:
#   Failover-Clustering:
#     dsc_name: 'Failover-Clustering'
#     dsc_ensure: 'present'
#     dsc_includeallsubfeature: true
#   RSAT-Clustering-CmdInterface:
#     dsc_name: 'RSAT-Clustering-CmdInterface'
#     dsc_ensure: 'present'
#     dsc_includeallsubfeature: true
#   RSAT-Clustering-Mgmt:
#     dsc_name: 'RSAT-Clustering-Mgmt'
#     dsc_ensure: 'present'
#     dsc_includeallsubfeature: true
#   RSAT-Clustering-PowerShell:
#     dsc_name: 'RSAT-Clustering-PowerShell'
#     dsc_ensure: 'present'
#     dsc_includeallsubfeature: true

# MODULE DEPENDENCIES
# puppet module install puppetlabs-dsc

class profile_cluster {
  # requires windows features
  require profile_windowsfeatures

  # HIERA lOOKUP
  $cfg = hiera_hash('profile::cluster::cfg')

  # Name of the cluster
  $dsc_name                          = $cfg[dsc_name]
  # Static IP Address of the cluster
  $dsc_staticipaddress               = $cfg[dsc_staticipaddress]
  # Credential used to create the cluster
  $dsc_domainadministratorcredential = $cfg[dsc_domainadministratorcredential]
  # Interval to check for cluster existence
  $dsc_retryintervalsec              = $cfg[dsc_retryintervalsec]
  # Maximum number of retries to check for cluster existance
  $dsc_retrycount                    = $cfg[dsc_retrycount]

  # VARIABLE VALIDATION
  validate_hash($cfg, $dsc_domainadministratorcredential)
  validate_decrypted_content($dsc_domainadministratorcredential[password])
  validate_string($dsc_name)
  validate_ip_address($dsc_staticipaddress)
  validate_integer($dsc_retryintervalsec, $dsc_retrycount)

  # all nodes ending with a '1' will be first node to join cluster
  # ie: node0001 will join cluster before node0002
  if $::hostname =~ /^.*1$/ {

    # join 1st node to cluster
    dsc_xcluster { 'cluster':
      dsc_name                          => $dsc_name,
      dsc_staticipaddress               => $dsc_staticipaddress,
      dsc_domainadministratorcredential => $dsc_domainadministratorcredential,

    }
  }
  else {

    # all other nodes should check to see if cluster has been created
    dsc_xwaitforcluster { 'patience is a virtue':
      dsc_name             => $dsc_name,
      dsc_retryintervalsec => $dsc_retryintervalsec,
      dsc_retrycount       => $dsc_retrycount,
    } ->

    # cluster has been created. join nodes to cluster as well
    dsc_xcluster { 'cluster':
      dsc_name                          => $dsc_name,
      dsc_staticipaddress               => $dsc_staticipaddress,
      dsc_domainadministratorcredential => $dsc_domainadministratorcredential,
    }
  }

  # VALIDATION CODE
  # Tests:
  # - ensure cluster exists
  # - ensure node is part of cluster
  validation_script { 'profile_cluster':
    profile_name    => 'profile_cluster',
    validation_data => $dsc_name,
  }

}
