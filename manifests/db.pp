# Class: omeka::db
#
# This class installs mysql server and setups the database for omeka.
# Omeka expects db.ini to be populated with database details, we make
# use of a template for that.
#
# Optionally, you can specify a database name and user
#
# == Variables
#
# A root and db password is expected
#
# == Usage
#
# This class is not intended to be used directly. It's automatically
# included by omeka
#

class omeka::db (
  $mysql_root,
  $omekadb_password,
  $omeka_home       = '/var/www/html/omeka',
  $omekadb_user     = 'omeka',
  $omekadb_dbname   = 'omeka_db',
) {
  
  class { '::mysql::server':
    root_password    => $mysql_root,
    override_options => {
      'mysqld' => {
        'max_connections' => '1024'
      }
    }
  }
  
  class { '::mysql::bindings':
    php_enable => true,
  }
  
  mysql::db { $omekadb_dbname:
    user     => $omekadb_user,
    password => $omekadb_password,
    host     => 'localhost',
    grant    => ['ALL'],
    charset  => 'utf8',
    collate  => 'utf8_unicode_ci',
  }
  
  file { "${omeka_home}/db.ini":
    ensure  => present,
    content => template('omeka/db.ini.erb'),
    owner   => 'apache',
    mode    => '0644',
  }

  class { 'mysql::server::backup':
    backupuser     => 'mysqlbackup',
    backuppassword => 'Xo4paiM9b',
    backupdir      => '/var/mysqlbackups',
  }

}
