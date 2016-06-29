# == Class: winimagebuilder::params
class winimagebuilder::params { 

  $windows_iso_path  = 'C:\ProgramData\Windows_ISOs'
  $cloud_image_path  = 'C:\ProgramData\Windows_Cloud_Images'
  $staging_file_path = 'C:\ProgramData\staging'
  $virtio_iso_file   = "${staging_file_path}\virtio-win.iso"
}
