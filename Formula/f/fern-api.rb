class FernApi < Formula
  desc "Stripe-level SDKs and Docs for your API"
  homepage "https://buildwithfern.com/"
  url "https://registry.npmjs.org/fern-api/-/fern-api-0.51.7.tgz"
  sha256 "5c8cf8d231eb439472c3fb6336c04d0edba2a3da936a3025024c2f90c9996356"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, all: "2f04c3308efeafa671b137091dc529238ff9886281a88d3a0e12e52a3beb8243"
  end

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    system bin/"fern", "init", "--docs", "--org", "brewtest"
    assert_path_exists testpath/"fern/docs.yml"
    assert_match "\"organization\": \"brewtest\"", (testpath/"fern/fern.config.json").read

    system bin/"fern", "--version"
  end
end
