module OtwArchive
  class ImportConfig
    require "resolv"

    attr_reader :archive_host, :token, :restricted, :override_tags, :detect_tags,
                :encoding, :archive_config

    def initialize(archive_host, token, restricted = true, override_tags = true, detect_tags = false,
                   encoding = "UTF-8", archive_config)
      protocol = isHttp?(archive_host) ? "http" : "https"
      @archive_host = "#{protocol}://#{archive_host}"
      @token = token
      @restricted = restricted
      @override_tags = override_tags
      @detect_tags = detect_tags
      @encoding = encoding
      @archive_config = archive_config
    end
    
    def isHttp?(archive_host)
      archive_host.include?("ariana.archiveofourown.org") || archive_host.include?("localhost") || archive_host.split(":")[0] =~ Resolv::IPv4::Regex
    end
  end
end # OtwArchive
