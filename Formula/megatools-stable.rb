class MegatoolsStable < Formula
  desc "Command-line client for Mega.co.nz"
  homepage "https://megatools.megous.com/"
  url "https://megatools.megous.com/builds/megatools-1.11.0.20220519.tar.gz"
  version "1.11.0.20220519"
  sha256 "b30b1d87d916570f7aa6d36777dd378e83215d75ea5a2c14106028b6bddc261b"

  livecheck do
    url "https://megatools.megous.com/builds/"
    regex(/href=.*?megatools[._-]v?(\d+(?:\.\d+)+)\.tar\.gz/i)
  end

  conflicts_with "megatools", because: "Homebrew version"
  conflicts_with "megatools-experimental", because: "Experimental version"
  conflicts_with "megatools-experimental-extra", because: "Experimental extra version"
  conflicts_with "megatools-stable-extra", because: "Stable extra version"

  depends_on "asciidoc" => :build
  depends_on "pkg-config" => :build
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "cmake" => :build
  depends_on "docbook2x" => :build
  depends_on "glib"
  depends_on "glib-networking"
  depends_on "openssl@1.1"

  uses_from_macos "curl"

  def install
    mkdir "build" do
      system "meson", ".."
      system "meson", "configure", "--prefix", prefix
      system "ninja", "--verbose"
      system "ninja", "install", "--verbose"
    end
  end

  test do
    # From core homebrew formula.
    system "#{bin}/megadl",
      "https://mega.co.nz/#!3Q5CnDCb!PivMgZPyf6aFnCxJhgFLX1h9uUTy9ehoGrEcAkGZSaI",
      "--path", "testfile.txt"
    assert_equal File.read("testfile.txt"), "Hello Homebrew!\n"
  end
end
