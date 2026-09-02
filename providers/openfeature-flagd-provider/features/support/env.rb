# frozen_string_literal: true

require "net/http"
require "uri"
require "rspec/expectations"
require "testcontainers"
require "open_feature/sdk"
require "openfeature/flagd/provider"

World(RSpec::Matchers)

# Boots the flagd testbed container via testcontainers and drives its launchpad; version pinned to test-harness/version.txt
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

    # start flagd via launchpad; retry since the mapped port opens before the app serves
    launchpad = "http://#{host}:#{mapped(LAUNCHPAD_PORT)}/start"
    wait_for { http_code(:post, launchpad) == "200" } ||
      raise("launchpad did not start flagd in time")
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
