module Aquatone
  module Collectors
    class Gtr < Aquatone::Collector
      self.meta = {
        :name        => "Google Transparency Report",
        :author      => "Michael Henriksen (@michenriksen)",
        :description => "Uses Google Transparency Report to find hostnames",
        :slug        => "gtr",
        :cli_options  => {
          "gtr-pages PAGES" => "Number of Google Transparency Report pages to process (default: 30)"
        }
      }

      BASE_URI                 = "https://transparencyreport.google.com/transparencyreport/api/v3/httpsreport/ct/certsearch"
      DEFAULT_PAGES_TO_PROCESS = 30.freeze

      def run
        token = nil
        pages_to_process.times do
          response = parse_response(request_page(token))
          if response.code == 404
            failure("Google Transparency Report found nothing")
          end
          if response.code != 200
            failure("HackerTarget API returned unexpected response code: #{response.code}")
          end
          hosts    = response.first[1].map { |a| a[1] }.uniq
          hosts.each do |host|
            add_host(host) if valid_host?(host)
          end
          _, token, _, current_page, total_pages = response.first.last
          break if token.nil? || current_page == total_pages
        end
      end

      private

      def request_page(token = nil)
        if token.nil?
          uri = "#{BASE_URI}"
        else
          uri = "#{BASE_URI}/page?&p=#{url_escape(token)}"
        end
        get_request(uri,
          {
            :format => :plain,
            :params => {"include_expired": 'true',
                        'include_subdomains': 'true',
                        'domain': url_escape(domain.name)},
            :headers => { "Referer" => "https://transparencyreport.google.com/https/certificates" } }
        )
      end

      def parse_response(body)
        body = body.split("\n", 2).last.strip
        JSON.parse(body)
      end

      def valid_host?(host)
        return false if host.start_with?("*.")
        return false unless host.end_with?(".#{domain.name}")
        true
      end

      def pages_to_process
        if has_cli_option?("gtr-pages")
          return get_cli_option("gtr-pages").to_i
        end
        DEFAULT_PAGES_TO_PROCESS
      end
    end
  end
end
