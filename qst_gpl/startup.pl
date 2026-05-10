use strict;
use lib qw(/home);
use lib qw(/usr/local/lib/x86_64-linux-gnu/perl/5.30.0);
use lib qw(/usr/local/share/perl/5.30.0);
use lib qw(/usr/lib/x86_64-linux-gnu/perl/5.30); 

# environment check
$ENV{MOD_PERL} or die "not running under mod_perl!";

use File::Path;
use POSIX qw(strftime);
use Crypt::PBKDF2;
use MIME::Base64;
use Archive::Zip qw(:ERROR_CODES :CONSTANTS);
use Exporter 'import';

# Database connection from environment variables (Docker)
my $db_host = $ENV{QST_DB_HOST} || 'localhost';
my $db_name = $ENV{QST_DB_NAME} || 'qst';
my $db_user = $ENV{QST_DB_USER} || 'qst';
my $db_pass = $ENV{QST_DB_PASS} || 'Qst#captain2';

use Apache::DBI;
DBI->install_driver("mysql");
Apache::DBI->connect_on_init
 ("DBI:mysql:$db_name:$db_host",
   $db_user,
   $db_pass,
   {
    PrintError => 1,
    RaiseError => 0,
    AutoCommit => 1,
   }
  );

1;
