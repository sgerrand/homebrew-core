class Zipkin < Formula
  desc "Zipkin is a distributed tracing system"
  homepage "https://zipkin.io/"
  url "https://github.com/openzipkin/zipkin/archive/2.23.9.tar.gz"
  sha256 "94e92eac297f9b744da2f8543d1c71dcdc9620c5e34e688fcc87472bd50222cf"
  license "Apache-2.0"

  depends_on "maven" => :build
  depends_on "openjdk@11"

  def install
    ENV["JAVA_HOME"] = Formula["openjdk@11"].opt_prefix
    system "./mvnw", "-DskipTests", "--also-make", "-pl", "zipkin-server", "clean", "install"
    libexec.install Dir["*/target/*.jar"]
    bin.write_jar_script libexec/"zipkin-server-#{version}-exec.jar", "zipkin", java_version: "11"
  end

  def zipkin_log_path
    var/"log/zipkin.log"
  end

  plist_options manual: "zipkin"

  def plist
    <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>KeepAlive</key>
        <true/>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{Formula["openjdk@11"].bin}/java</string>
          <string>-jar</string>
          <string>#{opt_libexec}/zipkin-server-#{version}-exec.jar</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>WorkingDirectory</key>
        <string>#{HOMEBREW_PREFIX}</string>
        <key>StandardOutPath</key>
        <string>#{zipkin_log_path}</string>
        <key>StandardErrorPath</key>
        <string>#{zipkin_log_path}</string>
      </dict>
      </plist>
    EOS
  end

  test do
    port = free_port
    fork do
      ENV["QUERY_PORT"] = "#{port}"
      exec "#{bin}/zipkin"
    end
    sleep 20

    output = shell_output("curl localhost:#{port}/info")
    assert_match(/{"zipkin":{"version":"#{version}","commit":"@git.commit.id.abbrev@"}}/, output)
  end
end
