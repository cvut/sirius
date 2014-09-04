require 'uri'
##
# Based on https://github.com/emk/sinatra-url-for
module UrlHelper

  # Construct an absolute path to a given +url_fragment+,
  # expects a leading slash.
  def path_for url_fragment, **params
    paramstr = nil
    # TODO: Use addressable
    unless params.empty?
      paramstr = '?' + params.map { |k,v| "#{k}=#{URI.escape(v.to_s, /[^#{URI::PATTERN::UNRESERVED}]/)}" }.join('&')
    end
    "#{base_href}#{url_fragment}#{paramstr}"
  end

  # Construct a full URL to `url_fragment`, which should be given relative to
  # the base of an API.
  def url_for url_fragment, **params
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
