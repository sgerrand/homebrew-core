class Zipkin < Formula
  desc "Zipkin is a distributed tracing system"
  homepage "https://zipkin.io/"
  url "https://github.com/openzipkin/zipkin/archive/2.22.1.tar.gz"
  sha256 "22967f599ebdfa2bee895747e0541f90ccea8bc461a6a257f0a5136bda0dd5eb"
  license "Apache-2.0"

  depends_on "maven" => :build
  depends_on "openjdk"

  def install
    ENV["JAVA_HOME"] = Formula["openjdk"].opt_prefix
    system "./mvnw", "-DskipTests", "--also-make", "-pl", "zipkin-server", "clean", "install"
    libexec.install Dir["*/target/*.jar"]
  end

  def zipkin_log_path
    var/"log/zipkin.log"
  end

  plist_options manual: "java -jar #{HOMEBREW_PREFIX}/opt/zipkin/zipkin-server-*exec.jar"

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
          <string>#{Formula["openjdk"].bin}/java</string>
          <string>-jar</string>
          <string>#{libexec}/zipkin-server-#{version}-exec.jar</string>
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
    system "#{Formula["openjdk"].bin}/java", "-jar", "#{libexec}/benchmarks.jar"
  end
end
