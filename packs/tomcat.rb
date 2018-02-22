include_pack "genericlb"
name "tomcat"
owner "brett.bourquin@walmartlabs.com"
description "Provides a Tomcat Servlet Container to deploy java web application workloads"
version "1.1"
type "Platform"
category "Web Application"

environment "single", {}
environment "redundant", {}

variable "groupId",
         :description => 'Group Identifier',
         :value => 'org.apache.brooklynn.example'

variable "artifactId",
         :description => 'Artifact Identifier',
         :value => 'hello-world'

variable "appVersion",
         :description => 'Artifact version',
         :value => '1.0.0'

variable "extension",
         :description => 'Artifact extension',
         :value => 'war'

variable "repository",
         :description => 'Repository name',
         :value => ''

##SHA version of the artifact
variable "shaVersion",
         :description => 'Checksum for artifact download',
         :value => ''

#The deployment context which application teams can set
variable "deployContext",
         :description => 'The context in which the app needs to be deployed',
         :value => 'ROOT'

resource "tomcat",
  :cookbook => "oneops.1.tomcat",
  :design => true,
  :requires => {
      :constraint => "1..1",
      :services=> "mirror",
   },
  :monitors => {
      'HttpValue' => {:description => 'HttpValue',
                 :source => '',
                 :chart => {'min' => 0, 'unit' => ''},
                 :cmd => 'check_http_value!#{cmd_options[:url]}!#{cmd_options[:format]}',
                 :cmd_line => '/opt/nagios/libexec/check_http_value.rb $ARG1$ $ARG2$',
                 :cmd_options => {
                     'url' => '',
                     'format' => ''
                 },
                 :metrics => {
                     'value' => metric( :unit => '',  :description => 'value', :dstype => 'DERIVE'),

                 }
       },
        'Log' => {:description => 'Log',
                 :source => '',
                 :chart => {'min' => 0, 'unit' => ''},
                 :cmd => 'check_logfiles!logtomcat!#{cmd_options[:logfile]}!#{cmd_options[:warningpattern]}!#{cmd_options[:criticalpattern]}',
                 :cmd_line => '/opt/nagios/libexec/check_logfiles   --noprotocol --tag=$ARG1$ --logfile=$ARG2$ --warningpattern="$ARG3$" --criticalpattern="$ARG4$"',
                 :cmd_options => {
                     'logfile' => '/log/apache-tomcat/catalina.out',
                     'warningpattern' => 'WARNING',
                     'criticalpattern' => 'CRITICAL'
                 },
                 :metrics => {
                     'logtomcat_lines' => metric(:unit => 'lines', :description => 'Scanned Lines', :dstype => 'GAUGE'),
                     'logtomcat_warnings' => metric(:unit => 'warnings', :description => 'Warnings', :dstype => 'GAUGE'),
                     'logtomcat_criticals' => metric(:unit => 'criticals', :description => 'Criticals', :dstype => 'GAUGE'),
                     'logtomcat_unknowns' => metric(:unit => 'unknowns', :description => 'Unknowns', :dstype => 'GAUGE')
                 },
                 :thresholds => {
                   'CriticalLogException' => threshold('15m', 'avg', 'logtomcat_criticals', trigger('>=', 1, 15, 1), reset('<', 1, 15, 1)),
                 }
       },
      'JvmInfo' =>  { :description => 'JvmInfo',
                  :source => '',
                  :chart => {'min'=>0, 'unit'=>''},
                  :cmd => 'check_tomcat_jvm',
                  :cmd_line => '/opt/nagios/libexec/check_tomcat.rb JvmInfo',
                  :metrics =>  {
                    'max'   => metric( :unit => 'B', :description => 'Max Allowed', :dstype => 'GAUGE'),
                    'free'   => metric( :unit => 'B', :description => 'Free', :dstype => 'GAUGE'),
                    'total'   => metric( :unit => 'B', :description => 'Allocated', :dstype => 'GAUGE'),
                    'percentUsed'  => metric( :unit => 'Percent', :description => 'Percent Memory Used', :dstype => 'GAUGE'),
                  },
                  :thresholds => {
                     'HighMemUse' => threshold('5m','avg','percentUsed',trigger('>',98,15,1),reset('<',98,5,1)),
                  }
                },
      'ThreadInfo' =>  { :description => 'ThreadInfo',
                  :source => '',
                  :chart => {'min'=>0, 'unit'=>''},
                  :cmd => 'check_tomcat_thread',
                  :cmd_line => '/opt/nagios/libexec/check_tomcat.rb ThreadInfo',
                  :metrics =>  {
                    'currentThreadsBusy'   => metric( :unit => '', :description => 'Busy Threads', :dstype => 'GAUGE'),
                    'maxThreads'   => metric( :unit => '', :description => 'Maximum Threads', :dstype => 'GAUGE'),
                    'currentThreadCount'   => metric( :unit => '', :description => 'Ready Threads', :dstype => 'GAUGE'),
                    'percentBusy'    => metric( :unit => 'Percent', :description => 'Percent Busy Threads', :dstype => 'GAUGE'),
                  },
                  :thresholds => {
                     'HighThreadUse' => threshold('5m','avg','percentBusy',trigger('>',90,5,1),reset('<',90,5,1)),
                  }
                },
      'RequestInfo' =>  { :description => 'RequestInfo',
                  :source => '',
                  :chart => {'min'=>0, 'unit'=>''},
                  :cmd => 'check_tomcat_request',
                  :cmd_line => '/opt/nagios/libexec/check_tomcat.rb RequestInfo',
                  :metrics =>  {
                    'bytesSent'   => metric( :unit => 'B/sec', :description => 'Traffic Out /sec', :dstype => 'DERIVE'),
                    'bytesReceived'   => metric( :unit => 'B/sec', :description => 'Traffic In /sec', :dstype => 'DERIVE'),
                    'requestCount'   => metric( :unit => 'reqs /sec', :description => 'Requests /sec', :dstype => 'DERIVE'),
                    'errorCount'   => metric( :unit => 'errors /sec', :description => 'Errors /sec', :dstype => 'DERIVE'),
                    'maxTime'   => metric( :unit => 'ms', :description => 'Max Time', :dstype => 'GAUGE'),
                    'processingTime'   => metric( :unit => 'ms', :description => 'Processing Time /sec', :dstype => 'DERIVE')
                  },
                  :thresholds => {
                  }
                },
      'AppVersion' => {:description => 'AppVersion',
                       :source => '',
                       :enable => 'false',
                       :chart => {'min' => 0, 'unit' => ''},
                       :cmd => 'check_tomcat_app_version',
                       :cmd_line => '/opt/nagios/libexec/check_tomcat_app_version.sh',
                       :metrics => {
                           'versionlatest' => metric(:unit => '', :description => 'value=0; App version is latest', :dstype => 'GAUGE'),
                       },
                       :thresholds => {
                         'VersionIssue' => threshold('1m', 'avg', 'versionlatest', trigger('>', 0, 5, 4), reset('<=', 0, 1, 1)),
                       }
      }
  }

resource "tomcat-daemon",
         :cookbook => "oneops.1.daemon",
         :design => true,
         :requires => {
             :constraint => "1..1",
             :help => "Restarts Tomcat"
         },
         :attributes => {
             :service_name => 'tomcat7',
             :use_script_status => 'true',
             :pattern => ''
         },
         :monitors => {
             'tomcatprocess' => {:description => 'TomcatProcess',
                           :source => '',
                           :chart => {'min' => '0', 'max' => '100', 'unit' => 'Percent'},
                           :cmd => 'check_process!:::node.workorder.rfcCi.ciAttributes.service_name:::!:::node.workorder.rfcCi.ciAttributes.use_script_status:::!:::node.workorder.rfcCi.ciAttributes.pattern:::!:::node.workorder.rfcCi.ciAttributes.secondary_down:::',
                           :cmd_line => '/opt/nagios/libexec/check_process.sh "$ARG1$" "$ARG2$" "$ARG3$" "$ARG4$"',
                           :metrics => {
                               'up' => metric(:unit => '%', :description => 'Percent Up'),
                           },
                           :thresholds => {
                               'TomcatDaemonProcessDown' => threshold('1m', 'avg', 'up', trigger('<=', 98, 1, 1), reset('>', 95, 1, 1))
                           }
             }
          }
resource "keystore",
         :cookbook => "oneops.1.keystore",
         :design => true,
         :requires => {"constraint" => "0..1"},
         :attributes => {
             "keystore_filename" => "/var/lib/certs/keystore.jks"
         }

resource "artifact",
  :cookbook => "oneops.1.artifact",
  :design => true,
  :requires => { "constraint" => "1..*", "services" => "*maven" },
  :attributes => {
     :repository => '$OO_LOCAL{repository}',
     :location => '$OO_LOCAL{groupId}:$OO_LOCAL{artifactId}:$OO_LOCAL{extension}',
     :version => '$OO_LOCAL{appVersion}',
     :install_dir => '/opt/tomcat7/$OO_LOCAL{artifactId}',
     :as_user => 'tomcat',
     :as_group => 'tomcat',
     :restart => "execute \"rm -fr /opt/tomcat7/webapps/$OO_LOCAL{deployContext}\" \n\nlink \"/opt/tomcat7/webapps/$OO_LOCAL{deployContext}\" do \n  to \"/opt/tomcat7/$OO_LOCAL{artifactId}/current\" \nend \n\n"
   },

  :monitors => {
         'URL' => {:description => 'URL',
                   :source => '',
                   :chart => {'min' => 0, 'unit' => ''},
                   :cmd => 'check_http_status!#{cmd_options[:host]}!#{cmd_options[:port]}!#{cmd_options[:url]}!#{cmd_options[:wait]}!#{cmd_options[:expect]}!#{cmd_options[:regex]}',
                   :cmd_line => '/opt/nagios/libexec/check_http_status.sh $ARG1$ $ARG2$ "$ARG3$" $ARG4$ "$ARG5$" "$ARG6$"',
                   :cmd_options => {
                       'host' => 'localhost',
                       'port' => '8080',
                       'url' => '/',
                       'wait' => '15',
                       'expect' => '200 OK',
                       'regex' => ''
                   },
                   :metrics => {
                       'time' => metric(:unit => 's', :description => 'Response Time', :dstype => 'GAUGE'),
                       'up' => metric(:unit => '', :description => 'Status', :dstype => 'GAUGE'),
                       'size' => metric(:unit => 'B', :description => 'Content Size', :dstype => 'GAUGE', :display => false)
                   },
                   :thresholds => {

                   }
         },
          'exceptions' => {:description => 'Exceptions',
                     :source => '',
                     :chart => {'min' => 0, 'unit' => ''},
                     :cmd => 'check_logfiles!logexc!#{cmd_options[:logfile]}!#{cmd_options[:warningpattern]}!#{cmd_options[:criticalpattern]}',
                     :cmd_line => '/opt/nagios/libexec/check_logfiles   --noprotocol  --tag=$ARG1$ --logfile=$ARG2$ --warningpattern="$ARG3$" --criticalpattern="$ARG4$"',
                     :cmd_options => {
                         'logfile' => '/log/logmon/logmon.log',
                         'warningpattern' => 'Exception',
                         'criticalpattern' => 'Exception'
                     },
                     :metrics => {
                         'logexc_lines' => metric(:unit => 'lines', :description => 'Scanned Lines', :dstype => 'GAUGE'),
                         'logexc_warnings' => metric(:unit => 'warnings', :description => 'Warnings', :dstype => 'GAUGE'),
                         'logexc_criticals' => metric(:unit => 'criticals', :description => 'Criticals', :dstype => 'GAUGE'),
                         'logexc_unknowns' => metric(:unit => 'unknowns', :description => 'Unknowns', :dstype => 'GAUGE')
                     },
                     :thresholds => {
                       'CriticalExceptions' => threshold('15m', 'avg', 'logexc_criticals', trigger('>=', 1, 15, 1), reset('<', 1, 15, 1))
                    }
           }
       }

resource "build",
  :cookbook => "oneops.1.build",
  :design => true,
  :requires => { "constraint" => "0..*" },
  :attributes => {
    "install_dir"   => '/usr/local/build',
    "repository"    => "",
    "remote"        => 'origin',
    "revision"      => 'HEAD',
    "depth"         => 1,
    "submodules"    => 'false',
    "environment"   => '{}',
    "persist"       => '[]',
    "migration_command" => '',
    "restart_command"   => ''
  }

resource "secgroup",
         :cookbook => "oneops.1.secgroup",
         :design => true,
         :attributes => {
             "inbound" => '[ "22 22 tcp 0.0.0.0/0", "8080 8080 tcp 0.0.0.0/0", "8443 8443 tcp 0.0.0.0/0" ]'
         },
         :requires => {
             :constraint => "1..1",
             :services => "compute"
         }

resource 'java',
         :cookbook => 'oneops.1.java',
         :design => true,
         :requires => {
             :constraint => '1..1',
             :services => '*mirror',
             :help => 'Java Programming Language Environment'
         },
         :attributes => {}


# depends_on
[ { :from => 'tomcat',     :to => 'os' },
 { :from => 'tomcat',     :to => 'user'  },
 { :from => 'tomcat',     :to => 'java'  },
 { :from => 'tomcat',     :to => 'volume'},
 { :from => 'tomcat',     :to => 'keystore'},
 { :from => 'tomcat-daemon',     :to => 'compute' },
 { :from => 'daemon',     :to => 'tomcat' },
 { :from => 'daemon',     :to => 'artifact' },
 { :from => 'daemon',     :to => 'build' },
 { :from => 'artifact',   :to => 'library' },
 { :from => 'artifact',   :to => 'download'},
 { :from => 'artifact',   :to => 'build'},
 { :from => 'artifact',   :to => 'volume'},
 { :from => 'build',      :to => 'library' },
 { :from => 'build',      :to => 'tomcat'  },
 { :from => 'build',      :to => 'download'},
 { :from => 'java',       :to => 'compute' },
 { :from => 'java',       :to => 'os' },
 { :from => 'keystore',    :to => 'java'},
 { :from => 'java',       :to => 'download'} ].each do |link|
 relation "#{link[:from]}::depends_on::#{link[:to]}",
   :relation_name => 'DependsOn',
   :from_resource => link[:from],
   :to_resource   => link[:to],
   :attributes    => { "flex" => false, "min" => 1, "max" => 1 }
end

relation "tomcat-daemon::depends_on::artifact",
  :relation_name => 'DependsOn',
  :from_resource => 'tomcat-daemon',
  :to_resource => 'artifact',
  :attributes => {"propagate_to" => "from", "flex" => false, "min" => 1, "max" => 1}

relation "tomcat-daemon::depends_on::tomcat",
  :relation_name => 'DependsOn',
  :from_resource => 'tomcat-daemon',
  :to_resource => 'tomcat',
  :attributes => {"propagate_to" => "from", "flex" => false, "min" => 1, "max" => 1}

relation "artifact::depends_on::tomcat",
  :relation_name => 'DependsOn',
  :from_resource => 'artifact',
  :to_resource => 'tomcat',
  :attributes => {"propagate_to" => "from", "flex" => false, "min" => 1, "max" => 1}

relation "tomcat-daemon::depends_on::keystore",
  :relation_name => 'DependsOn',
  :from_resource => 'tomcat-daemon',
  :to_resource => 'keystore',
  :attributes => {"propagate_to" => "from", "flex" => false, "min" => 1, "max" => 1}

relation "tomcat-daemon::depends_on::certificate",
  :relation_name => 'DependsOn',
  :from_resource => 'tomcat-daemon',
  :to_resource => 'certificate',
  :attributes => {"propagate_to" => "from", "flex" => false, "min" => 1, "max" => 1}


relation "keystore::depends_on::certificate",
  :relation_name => 'DependsOn',
  :from_resource => 'keystore',
  :to_resource => 'certificate',
  :attributes => {"propagate_to" => "from", "flex" => false, "min" => 1, "max" => 1}


# managed_via
[ 'tomcat', 'artifact', 'build', 'java','keystore', 'tomcat-daemon'].each do |from|
  relation "#{from}::managed_via::compute",
    :except => [ '_default' ],
    :relation_name => 'ManagedVia',
    :from_resource => from,
    :to_resource   => 'compute',
    :attributes    => { }
end


policy "vulnerable-tomcat-version",
  :description => 'Using a known vulnerable version of Tomcat',
  :query => 'ciClassName:("bom.Tomcat") AND NOT (ciAttributes.version:("7.0.75") OR ciAttributes.version:("7.0.78") OR ciAttributes.version:("8.5.12") OR ciAttributes.version:("8.5.14"))',
  :docUrl => '',
  :mode => 'passive'