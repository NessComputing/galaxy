require 'galaxy/temp'
require 'galaxy/host'
require 'json'
require 'open-uri'

module Galaxy
  class Fetcher
    def initialize base_url, http_user, http_password, log
        @base, @http_user, @http_password, @log = base_url, http_user, http_password, log
    end

    # return path on filesystem to the binary
    def fetch build, build_uri=nil, extension="tar.gz"
      core_url = build_uri || @base

      if !build.group.nil?
        if core_url.start_with? "nexus:"
          core_url = core_url.slice(6..-1)
          core_url = "#{core_url}/service/local/artifact/maven/redirect?r=public&g=#{build.group}&a=#{build.artifact}&v=#{build.version}&e=#{extension}"
        else
          group_path=build.group.gsub /\./, '/'
          # Maven repo compatible
          core_url = "#{core_url}/#{group_path}/#{build.artifact}/#{build.version}"
        end
      else
        core_url="#{core_url}/#{build.artifact}-#{build.version}.#{extension}"
      end

      tmp = Galaxy::Temp.mk_auto_file "galaxy-download"

      @log.info("Fetching #{core_url} into #{tmp}")
      if core_url =~ /^https?:/
        begin
          curl_command = "curl -L -D - \"#{core_url}\" -o #{tmp} -s"
          if !@http_user.nil? && !@http_password.nil?
            curl_command << " -u #{@http_user}:#{@http_password}"
          end

          @log.debug("Running CURL command: #{curl_command}")
          output = Galaxy::HostUtils.system(curl_command)
        rescue Galaxy::HostUtils::CommandFailedError => e
          raise "Failed to download archive #{core_url}: #{e.message}"
        end
        # cURL prints out each status code as it gets it, so in the case of a 301 redirect
        # we need to make sure to get the last one, which should still be 200.
        status = output.select {|l| l.start_with? "HTTP" }.last
        (protocol, response_code, response_message) = status.split
        unless response_code == '200'
          raise "Failed to download archive #{core_url}: #{status}"
        end
      else
        open(core_url) do |io|
          File.open(tmp, "w") { |f| f.write(io.read) }
        end
      end
      return tmp
    end

  end
end
