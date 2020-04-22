#
class ngt_scripts (
  String $log_dir      = '/var/log/ngt',
  String $script_dir   = '/usr/local/sbin',
  String $db_conn_file = '/root/.my.cnf',
) {

  exec { "Create log dir ${log_dir}":
    creates => $log_dir,
    command => "mkdir -p ${log_dir}",
    path => $::path,
    before => File[$log_dir],
  }
  ensure_resource('file', $log_dir, { 'ensure' => 'directory'})

  exec { "Create script dir ${script_dir}":
    creates => $script_dir,
    command => "mkdir -p ${script_dir}",
    path => $::path,
    before => File[$script_dir],
  }
  ensure_resource('file', $script_dir, { 'ensure' => 'directory'})

  #NGT expects pre_freeze and post_that scripts in /usr/local/sbin
  $ngt_sbin = '/usr/local/sbin'
  exec { "Create NGT sbin ${ngt_sbin}":
    creates => $ngt_sbin,
    command => "mkdir -p ${ngt_sbin}",
    path => $::path,
    before => File[$ngt_sbin],
  }
  ensure_resource('file', $ngt_sbin, { 'ensure' => 'directory'})

  file { "${ngt_sbin}/pre_freeze":
    ensure => 'file',
    content => epp('ngt_scripts/pre_freeze.epp', {
       'log_dir' => $log_dir,
       'script_dir' => $script_dir,
     }),
     owner => 'root',
     mode  => '0700',
  }

  file { "${ngt_sbin}/post_thaw":
    ensure => 'file',
    content => epp('ngt_scripts/post_thaw.epp', {
       'log_dir' => $log_dir,
       'script_dir' => $script_dir,
     }),
     owner => 'root',
     mode  => '0700',
  }

  file { "${script_dir}/quiesce.py":
    ensure => 'file',
    content => epp('ngt_scripts/quiesce.epp', {
       'log_dir' => $log_dir,
       'db_conn_file' => $db_conn_file,
     }),
     owner => 'root',
     mode  => '0600',
  }

  file { "${script_dir}/unquiesce.py":
    ensure => 'file',
    content => epp('ngt_scripts/unquiesce.epp', {
       'log_dir' => $log_dir,
       'db_conn_file' => $db_conn_file,
     }),
     owner => 'root',
     mode  => '0600',
  }
}
