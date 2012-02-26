# ruby-crowddirector

This is a ruby library to access [3Crowd](http://www.3crowd.com)'s
[CloudDirector Dashboard](https://dashboard.3crowd.com) data. Until
there's an API available, there is a scraper mechanism provided:
`CrowdDirector::Scrape`.

For now, only accessing network resources is supported (both HTTP and DNS
resources).

## Example library usage

Print out all attributes for each network resource:

    require "crowddirector/scrape"

    dashboard = CrowdDirector::Scrape.new("foo@example.org", "MyPassword")
    dashboard.network_resources.each do |id, data|
      puts "network resource id #{id}:"
      data.each { |k, v| puts " - #{k}: #{v}" }
    end

Some some specific data about network resource id `123`:

    resource = dashboard.network_resources["123"]
    puts "base url: " + resource["base_url"]
    puts "current health state: " + resource["current_health_state"]

All methods may raise `CrowdDirector::Error` if there is a problem
logging in or scraping the dashboard site.

## Nagios plugin

This library comes with a Nagios plugin to check the health state
of a resource. Usage:

    Usage: check_3crowd_net_resource -e email {-p pass|-f passfile}
                       -r resource [-j cookiejar]
         --email, -e <s>:   CrowdDirector email
          --pass, -p <s>:   CrowdDirector password
      --passfile, -f <s>:   File containing CrowdDirector password
      --resource, -r <s>:   Network resource ID to check
              You can locate the resource ID by logging in to the CrowdDirector
              Dashboard, editing the network resource, and taking the last URL
              component after a "/" (seems to always be an integer).

           --jar, -j <s>:   Path to cookie jar file
              Optionally specify the path to a "cookie jar" to store a
              session cookie. Without a cookie jar, each invocation of
              the check will have to complete the login process.

           --version, -v:   Print version and exit
              --help, -h:   Show this message

Example run:

    $ check_3crowd_net_resource -e petef@example.org -p "sekret" -r 2151 -j /tmp/cookies
    OK: id=2151 type=server dns_host=1.2.3.4 is up (state 1)
    $ echo $?
    0

    $ umask 0077 && echo "sekret" > .pass
    $ check_3crowd_net_resource -e petef@example.org -f .pass -r 2152 -j /tmp/cookies
    CRITICAL: id=2153 type=server dns_host=1.2.3.5 is down (state 0)
    $ echo $?
    2
