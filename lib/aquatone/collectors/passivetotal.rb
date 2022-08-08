module Aquatone
  module Collectors
    class Passivetotal < Aquatone::Collector
      self.meta = {
        :name => "PassiveTotal",
        :author => "Michael Henriksen (@michenriksen)",
        :description => "Uses RiskIQ's PassiveTotal API to find hostnames",
        :require_keys => %w[passivetotal_key passivetotal_secret]
      }

      API_BASE_URI = "https://api.passivetotal.org".freeze

      def run
        response = get_request(
          "#{API_BASE_URI}/v2/enrichment/subdomains?query=.#{url_escape(domain.name)}",
          :basic_auth => { :username => get_key("passivetotal_key"), :password => get_key("passivetotal_secret") }
        )
        body = response.parsed_response
        if response.code == 401
          failure("PassiveTotal Api: Unauthorised")
        end
        if response.code != 200
          message = ''
          if body.key?('message')
            message = body["message"]
          end
          failure(failure(message || "PassiveTotal API returned unexpected response code: #{response.code}"))
        end
        unless body.key?("success") && body["success"]
          failure("Request failed")
        end
        body["subdomains"].each do |subdomain|
          add_host("#{subdomain}.#{domain.name}")
        end
      end
    end
  end
end
