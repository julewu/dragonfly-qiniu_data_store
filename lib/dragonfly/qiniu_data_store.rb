require 'dragonfly'
require 'qiniu'
require 'securerandom'

Dragonfly::App.register_datastore(:qiniu){ Dragonfly::QiniuDataStore }

module Dragonfly
  class QiniuDataStore

    # Exceptions
    class NotConfigured < RuntimeError; end

    SUBDOMAIN_PATTERN = /^[a-z0-9][a-z0-9.-]+[a-z0-9]$/

    def initialize(opts={})
      @access_key = opts[:access_key]
      @secret_key = opts[:secret_key]
      @bucket_name = opts[:bucket_name]
      @url_host = opts[:url_host]
      @key_prefix = opts[:key_prefix]
    end

    attr_accessor :bucket_name, :access_key, :secret_key, :url_host, :key_prefix

    def write(content, opts={})
      ensure_configured
      ensure_connect_initialized

      uid = opts[:path] || generate_uid(content.name || 'file')

      code, result = Qiniu::Storage.upload_buffer_with_put_policy(
           Qiniu::Auth::PutPolicy.new(bucket_name),
           content.data,
           uid,
           nil,
           bucket: bucket_name
      )

      code == 200? result['key']: nil
    end

    def read(uid)
      ensure_configured
      ensure_connect_initialized

      uri = URI(url_for(uid))
      response = Net::HTTP.get_response(uri)
      response.is_a?(Net::HTTPOK) ? [response.body, nil] : nil
    rescue StandardError => e
      nil
    end

    def destroy(uid)
      ensure_connect_initialized

      Qiniu.delete(bucket_name, uid)
    rescue StandardError => e
      Dragonfly.warn("#{self.class.name} destroy error: #{e}")
    end

    def url_for(uid, opts={})
      uid = URI.escape(uid)
      if expires = opts[:expires]
        response = Qiniu.get(bucket_name, uid, nil, expires)
        response['url']
      else
        host = opts[:host] || url_host
        "#{host}/#{uid}"
      end
    end

    private

    def ensure_configured
      unless @configured
        [:bucket_name, :access_key, :secret_key, :url_host].each do |attr|
          raise NotConfigured, "You need to configure #{self.class.name} with #{attr}" if send(attr).nil?
        end
        @configured = true
      end
    end

    def ensure_connect_initialized
      unless @initialized
        Qiniu.establish_connection! :access_key => access_key,
                                    :secret_key => secret_key
        @initialized = true
      end
    end

    def generate_uid(name)
      "#{key_prefix}#{Time.now.strftime '%Y/%m/%d/%H/%M/%S'}/#{SecureRandom.uuid}/#{name}"
    end

    def get_remote_file(url)
      RestClient.get(url)
    end
  end
end
