require "rubygems"
require "bundler/setup"

require "crowddirector/error"
require "crowddirector/version"
require "json"
require "mechanize"

module CrowdDirector
  class Scrape < Mechanize
    LOGIN_URL = "https://dashboard.3crowd.com/user/login"
    RESOURCES_URL = "https://dashboard.3crowd.com/network_resources"

    public
    def initialize(email, password, cookie_jar_path = nil)
      @email, @password = email, password
      @cookie_jar_path = cookie_jar_path
      @network_resources = nil

      super()

      if cookie_jar_path and ::File.exists?(cookie_jar_path)
        self.cookie_jar = Mechanize::CookieJar.new.load(cookie_jar_path)
      end
    end # def initialize

    # monkey-patch get. we intercept a 3crowd login form and login.
    public
    def get(url)
      page = super
      raise "error getting #{url}" unless page

      login_form = page.form_with(:action => LOGIN_URL)
      if login_form
        debug "Logging in as #{@email}"
        login_form.email = @email
        login_form.password = @password
        submit(login_form)
        if @cookie_jar_path
          debug "Saving cookie jar"
          cookie_jar.save_as(@cookie_jar_path)
        end

        page = super

        # If we still get a login form, our login is failing.
        if page.form_with(:action => LOGIN_URL)
          debug "failed login, page.code = #{page.code}"
          debug "failed login, page.body = #{page.body}"
          raise Error, "cannot login with email #{@email}"
        end
      end

      return page
    end

    public
    def network_resources
      return @network_resources if @network_resources

      resources_page = get(RESOURCES_URL)

      # Scraping the dashboard; 3crowd is setting a JS variable to a
      # JSON object that contains all the resource info.
      #    var network_resources_json = {foo}
      match = resources_page.body.match("var network_resources_json = (.+)\s*;")
      if !match
        debug "resources_page.body = #{resources_page.body}"
        raise Error, "#{RESOURCES_URL}: can't find network_resources_json"
      end

      begin
        resources = JSON.parse(match[1])
      rescue JSON::ParserError
        debug "match = #{match.inspect}"
        debug "match[1] = #{match[1]}"
        raise Error, "#{RESOURCES_URL}: can't parse network_resources_json"
      end

      @network_resources = resources
    end # def network_resources

    private
    def login_needed?(page)
      # If you make a request without a cookie, 3crowd serves a 200
      # with the login form as the body.

      login_form = page.form_with(:action => LOGIN_URL)
      return login_form ? true : false
    end # def login_needed?

    private
    def debug(msg)
      if $DEBUG
        $stderr.puts "CrowdDirector: #{msg}"
      end
    end # def debug
  end # class Scrape
end # module CrowdDirector
