# This script can be required to ensure that a bin script is run inside
# docker. If it is called on the host, it re-runs itself in the given
# compose service:
#
#     #!/usr/bin/env ruby
#
#     require_relative "docker_wrapper"
#     DockerWrapper.ensure_inside_docker! container: "tests"
#
#     # Now run actual dev logic
#     puts "Running inside Docker"
#
# The re-run goes through bin/bundle_exec, which installs missing gems
# before executing the command.
#
module DockerWrapper
  def self.inside_docker?
    File.exist?("/.dockerenv") ||
    File.read("/proc/1/cgroup").include?("docker") ||
    ENV['DOCKER_BUILD'] == 'true'
  rescue Errno::ENOENT
    false
  end

  def self.ensure_inside_docker!(command: nil, container: 'web', service_ports: false)
    return if inside_docker?

    command ||= "bin/#{File.basename($0)}"

    dockerized_command = "docker compose run --rm #{'--service-ports' if service_ports} #{container} bin/bundle_exec #{command} #{ARGV.join(' ')}"
    print "$ #{dockerized_command}\n"

    exec(dockerized_command)
  end
end
