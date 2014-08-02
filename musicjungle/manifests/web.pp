exec { "apt-update":
    command => "/usr/bin/apt-get update"
}

#Basics
package { "unzip":
  ensure => installed,
  require => Exec["apt-update"]
}
package { "openjdk-7-jre":
  ensure => installed,
  require => Exec["apt-update"]
}

#Tomcat
package { 'tomcat7':
    ensure => installed,
    require => Exec["apt-update"]
}

service { 'tomcat7':
    ensure => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
    require => Package['tomcat7']    
}

#Apps / .war
file { "/var/lib/tomcat7/webapps/vraptor-musicjungle.war":
    source => "/vagrant/manifests/vraptor-musicjungle.war",
    owner => "tomcat7",
    group => "tomcat7",
    mode => 0644,
    require => Package["tomcat7"],
    notify => Service["tomcat7"]
}
file { "/var/lib/tomcat7/webapps/vraptor-second-app.war":
    source => "/vagrant/manifests/vraptor-musicjungle.war",
    owner => "tomcat7",
    group => "tomcat7",
    mode => 0644,
    require => Package["tomcat7"],
    notify => Service["tomcat7"]
}


#MySQL
package { "mysql-server":
  ensure => installed,
  require => Exec["apt-update"]
}

service { "mysql":
    ensure => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
    require => Package["mysql-server"]    
}

exec { "musicjungle":
    command => "mysqladmin -uroot create musicjungle",
    unless => "mysql -u root musicjungle",
    path => "/usr/bin",
    require => Service["mysql"]
}

exec { "mysql-password" :
	command => "mysql -uroot -e \"GRANT ALL PRIVILEGES ON * TO 'musicjungle'@'%'' IDENTIFIED BY 'minha-senha';\" musicjungle",
    unless  => "mysql -umusicjungle -pminha-senha musicjungle",
    path => "/usr/bin",
    require => Service["mysql"]
}

#Denindo para App que o ambiente é de producao
#file_line { "production":
    #file => "/etc/default/tomcat7",
    #line => "JAVA_OPTS=\"\$JAVA_OPTS -Dbr.com.caelum.vraptor.environment=production\"",
    #require => Package["tomcat7"],
    #notify => Service["tomcat7"]
#}

#define file_line($file, $line) {
    #exec { "/bin/echo '${line}' >> '${file}'":
        #unless => "/bin/grep -qFx '${line}' '${file}'"
    #}
#}