# == Class: winimagebuilder
# A puppet module to deploy the Cloudbase Windows OpenStack Imaging Tools located here:
# https://github.com/cloudbase/windows-openstack-imaging-tools
# === Parameters
# [*windows_iso_path*]
# The directory containing the Windows ISO Images.
# [*cloud_image_path*]
# The directory to output the CloudImages to.
# === Variables
#
# === Examples
#
#  class { 'winimagebuilder': }
#
# === Authors
#
# Peter J. Pouliot <peter@pouliot.net>
#
# === Copyright
#
# Copyright 2016 Peter J. Pouliot <peter@pouliot.net>, unless otherwise noted.

class winimagebuilder (

  $windows_iso_path  = $winimagebuilder::params::windows_iso_path,
  $staging_file_path = $winimagebuilder::params::staging_file_path,
  $virtio_iso_path   = $winimagebuilder::params::virtio_iso_path,
  $cloud_image_path  = $winimagebuilder::parmas::cloud_image_path,


) inherits winimagebuilder::params {

  validate_string($windows_iso_path, 'You must supply a directory path to put your Windows ISOs in.')
  validate_string($cloud_image_path, 'You must supply a directory path to put the created cloud images in.')
  validate_re($::operatingsystem, '(^windows)$', 'This Module currently only works on Windows based systems.')
  
  file{[
    $winimagebuilder::windows_iso_path,
    $winimagebuilder::cloud_image_path,
  ]:
    ensure => directory,
  }

  # Create a Staging Directory
  class{'staging':
    path    => 'C:/ProgramData/staging',
    owner   => 'Administrator',
    group   => 'Administrator',
    mode    => '0777',
    require => Package['unzip'],
  } ->

  # Get the Virtio Drivers
  staging::file{'virtio-win.iso':
    source  => 'https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso',
    timeout => 0,
  }

  # Cloudbase Windows OpenStack Imaging Tools
  vcsrepo{'C:\Windows\System32\WindowsPowerShell\v1.0\Modules\WinImageBuilder':
    source   => 'https://github.com/cloudbase/windows-openstack-imaging-tools',
    provider => git,
    ensure   => present,
    revision => 'master',
  } ->

  # Unblock the Files in the WinImageBuilder directories
  exec{'unblock-windows_openstack_imaging_tools':
    command   => 'dir * |Unblock-File',
    provider  => powershell,
    cwd       => 'C:\Windows\System32\WindowsPowerShell\v1.0\Modules\WinImageBuilder',
    logoutput => true,
  } ->

  exec{'unblock-windows_openstack_imaging_tools_bin':
    command   => 'dir * |Unblock-File',
    provider  => powershell,
    cwd       => 'C:\Windows\System32\WindowsPowerShell\v1.0\Modules\WinImageBuilder\bin',
    logoutput => true,
  }

}
