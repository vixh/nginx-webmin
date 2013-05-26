do 'virtualmin-nginx-lib.pl';


use File::Copy;
use Cwd 'abs_path';
our ($conf_dir, $sites_avaliable_dir, $sites_enabled_dir, $log_dir);

#TODO if $conf_dir, $sites_avaliable_dir, $sites_enabled_dir come from user put trail slash
#TODO Config set by user not working, only default values

if($config{'conf_dir'} eq "")
{
  $conf_dir = '/etc/nginx/';
}

if($config{'sites_available_dir'} eq "")
{
  $sites_available_dir = 'sites-available/';
}

if($config{'sites_enabled_dir'} eq "")
{
  $sites_enabled_dir = 'sites-enabled/';
}



sub feature_always_links
{
  
}

sub feature_backup
{
  
}

sub feature_bandwidth
{
  
}

sub feature_check
{
  my $conf_file = $conf_dir . "nginx.conf";
  
  unless(-r $conf_file)
  {
    return "Nginx needs to be installed.";
  }
  
  unless (-d $conf_dir . $sites_available_dir)
  {
    mkdir($conf_dir . $sites_available_dir);
  }
  
  unless (-d $conf_dir . $sites_enabled_dir)
  {
    mkdir($conf_dir . $sites_enabled_dir);
  }

  
  open(CONF, $conf_file);
  
  local $/ = undef;
  my $filestring = <CONF>;
  close(CONF);
  
  #TODO: check if include directive not comment "# include /etc/nginx/sites-enabled/*;"
  my $pattern = "include " . $conf_dir . $sites_enabled_dir . "\\*;";
  
  unless ($filestring =~ /$pattern/) 
  {
    
    chop($filestring);
    
    $filestring .= "\tinclude " . $conf_dir . $sites_enabled_dir . "*;\n}"; 
    
    open(CONF,  ">", $conf_file);
    
    print(CONF $filestring);
    
    close(CONF);
    
  }
    
  return undef;
  
}

sub feature_clash
{
  return undef;
}

sub feature_delete
{
  my ($d) = @_;
  &$virtual_server::first_print("Deleting Nginx site ..");
  
  unlink($conf_dir . $sites_enabled_dir . $d->{'dom'} . ".conf");
  unlink($conf_dir . $sites_available_dir . $d->{'dom'} . ".conf");

  &$virtual_server::second_print(".. done");
  
}

sub feature_depends
{
  return undef;
}

sub feature_disable
{
  my ($d) = @_;
  &$virtual_server::first_print("Disabling Nginx website ..");
  unlink($conf_dir . $sites_enabled_dir . $d->{'dom'} . ".conf");
  reload_nginx();
  &$virtual_server::second_print(".. done");
}

sub feature_disname
{
  return "Nginx website";
}

sub feature_enable
{
  
  my ($d) = @_;
  &$virtual_server::first_print("Re-enabling Nginx website ..");
  symlink($conf_dir . $sites_available_dir . $d->{'dom'} . ".conf", $conf_dir . $sites_enabled_dir . $d->{'dom'} . ".conf");
  reload_nginx();
  &$virtual_server::second_print(".. done");
  
  
}

sub feature_import
{
  
}

sub feature_label
{
  return "Setup Nginx website for domain?";
}

sub feature_links
{
  
}

sub feature_losing
{
  return "The Nginx config file for this website will be deleted.";
}

sub feature_modify
{
  my ($d, $oldd) = @_;
  if ($d->{'dom'} ne $oldd->{'dom'}) {
  }
}

sub feature_name
{
  return "Nginx website";
}

sub feature_restore
{
  
}

sub feature_setup
{
  my ($d) = @_;
  &$virtual_server::first_print("Setting up Nginx site ..");
  
  my $file;
  
  if($config{'log_dir'} eq "")
  {
    $log_dir = "$d->{'home'}/logs/";
  }
  
  open($file, ">" . $conf_dir . $sites_available_dir . $d->{'dom'} . ".conf");

  $template = "";

  $template_file = abs_path(__FILE__);
  $template_file =~ s/virtual_feature.pl/nginx_conf.tpl/;

  open(TEMPLATE,$template_file) or die "Template opening failed: check file ".$template_file;

  while ($line = <TEMPLATE>){
    $template .= $line;
  }
  close TEMPLATE;
  $template =~ s/<domain>/$d->{'dom'}/g;
  $template =~ s/<path>/$d->{'home'}/g;
  $template =~ s/<ip>/$d->{'ip'}/g;
  $template =~ s/<log_directory>/$log_dir/g;

  $conf = $template;
  
  print($file $conf);
  
  close $file;
  
  symlink($conf_dir . $sites_available_dir . $d->{'dom'} . ".conf", $conf_dir . $sites_enabled_dir . $d->{'dom'} . ".conf");
  
  reload_nginx();
  fix_perm("$d->{'home'}/public_html/");
  
  &$virtual_server::second_print(".. done");
  
}

sub feature_suitable
{
  return 1;
}

sub feature_validate
{
  return undef;
}

sub feature_webmin
{
  
}

sub reload_nginx
{
  if($config{'nginx_pid'} eq "")
  {
    $nginx_pid = '/var/run/nginx.pid';
  }
  #TODO test nginx conf = nginx -t
  my $pid = `cat $nginx_pid`;
  `kill -HUP $pid`;
}

sub fix_perm
{
    # TODO nginx run as www-data, default perm on public_html in Virtualmin 0740 Sequrity alert if chmod 0755
    my ($dir) = @_;
    
    if($config{'public_html_perm'} eq "")
    {
        $public_html_perm = '0755';
    }
    chmod oct($public_html_perm), $dir;
}
