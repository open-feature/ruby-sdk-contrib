# frozen_string_literal: true

require "net/http"
require "uri"
require "rspec/expectations"
require "testcontainers"
require "open_feature/sdk"
require "openfeature/flagd/provider"

World(RSpec::Matchers)

# Boots the shared flagd testbed container via testcontainers and drives its launchpad so flagd is
# serving the standard flag set before the suite runs. The image version is pinned to the
# flagd-testbed submodule (test-harness/version.txt), matching the other flagd providers.
module Testbed
  VERSION = File.read(File.expand_path("../../test-harness/version.txt", __dir__)).strip
  IMAGE = "ghcr.io/open-feature/flagd-testbed:v#{VERSION}"
  RPC_PORT = 8013
  HEALTH_PORT = 8014
  LAUNCHPAD_PORT = 8080

  module_function

  def start
    @container = Testcontainers::DockerContainer
      .new(IMAGE)
      .with_exposed_ports(RPC_PORT, HEALTH_PORT, LAUNCHPAD_PORT)
      .with_wait_for(:tcp_port, LAUNCHPAD_PORT)
    @container.start

    # launchpad starts flagd with the default flag set
    Net::HTTP.post(URI("http://#{host}:#{mapped(LAUNCHPAD_PORT)}/start"), "")
    wait_for { http_code(:get, "http://#{host}:#{mapped(HEALTH_PORT)}/healthz") == "200" } ||
      raise("flagd testbed did not become healthy in time")

    # point the provider at the mapped RPC port for this run
    ENV["FLAGD_HOST"] = host
    ENV["FLAGD_PORT"] = mapped(RPC_PORT).to_s
  end

  def stop
    @container&.stop
    @container&.remove
  end

  def host
    @container.host
  end

  def mapped(port)
    @container.mapped_port(port)
  end

  def http_code(verb, url)
    uri = URI(url)
    res = (verb == :post) ? Net::HTTP.post(uri, "") : Net::HTTP.get_response(uri)
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

# register teardown before startup so a container is cleaned up even if start raises
at_exit { Testbed.stop }
Testbed.start
