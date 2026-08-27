# frozen_string_literal: true

require "net/http"
require "uri"
require "rspec/expectations"
require "open_feature/sdk"
require "openfeature/flagd/provider"

World(RSpec::Matchers)

# Boots the shared flagd testbed container and drives its launchpad so flagd is serving the
# standard flag set before the suite runs. Uses the Docker CLI directly (reliable on CI).
module Testbed
  VERSION = File.read(File.expand_path("../../test-harness/version.txt", __dir__)).strip
  IMAGE = "ghcr.io/open-feature/flagd-testbed:v#{VERSION}"
  NAME = "flagd-e2e-ruby-#{Process.pid}"

  module_function

  def start
    sh("docker rm -f #{NAME}")
    raise "failed to start #{IMAGE} (is docker available?)" unless
      sh("docker run -d --name #{NAME} -p 8013:8013 -p 8014:8014 -p 8080:8080 #{IMAGE}")

    # launchpad starts flagd with the default flag set
    wait_for { http_code(:post, "http://localhost:8080/start") }
    wait_for { http_code(:get, "http://localhost:8014/healthz") == "200" } ||
      raise("flagd testbed did not become healthy in time")
  end

  def stop
    sh("docker rm -f #{NAME}")
  end

  def sh(cmd)
    system(cmd, out: File::NULL, err: File::NULL)
  end

  def http_code(verb, url)
    uri = URI(url)
    res = if verb == :post
      Net::HTTP.post(uri, "")
    else
      Net::HTTP.get_response(uri)
    end
    res.code
  rescue
    nil
  end

  def wait_for(timeout: 60)
    deadline = Time.now + timeout
    loop do
      return true if yield
      return false if Time.now > deadline

      sleep 0.5
    end
  end
end

Testbed.start
at_exit { Testbed.stop }
