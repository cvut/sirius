require 'uri'
##
# Based on https://github.com/emk/sinatra-url-for
module UrlHelper

  # Construct an absolute path to a given +url_fragment+,
  # expects a leading slash.
  def path_for(url_fragment, **params)
    uri = URI.parse(url_fragment)

    # TODO: Use addressable and refactor this ugly sh*t!
    query = params.map { |k,v|
      "#{k}=#{URI.escape(v.to_s, /[^#{URI::PATTERN::UNRESERVED}]/)}"
    }.unshift(uri.query).compact.join('&')
    uri.query = query unless query.empty?

    url_fragment.start_with?(base_href) ? uri.to_s : "#{base_href}#{uri}"
  end

  # Construct a full URL to `url_fragment`, which should be given relative to
  # the base of an API.
  def url_for(url_fragment, **params)
    "#{base_domain(absolute: true)}#{path_for url_fragment, params}"
  end

  def base_domain(absolute: false)
    scheme = nil
    if absolute
      scheme = Config.force_ssl ? 'https://' : 'http://'
    end
    "#{scheme}#{Config.domain}"
  end

  # FIXME: This should/could use a context info or request.script_name if possible
  def base_href
    '/api/v1'
  end

end
