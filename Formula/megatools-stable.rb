class MegatoolsStable < Formula
  desc "Command-line client for Mega.co.nz"
  homepage "https://megatools.megous.com/"
  url "https://github.com/JrMasterModelBuilder/homebrew-megatools/releases/download/sources/megatools-1.11.0.20220519.tar.gz"
  version "1.11.0.20220519"
  sha256 "b30b1d87d916570f7aa6d36777dd378e83215d75ea5a2c14106028b6bddc261b"

  livecheck do
    url "https://megatools.megous.com/builds/"
    regex(/href=.*?megatools[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  depends_on "asciidoc" => :build
  depends_on "cmake" => :build
  depends_on "docbook2x" => :build
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "glib"
  depends_on "glib-networking"
  depends_on "openssl@1.1"

  uses_from_macos "curl"

  conflicts_with "megatools", because: "homebrew version"
  conflicts_with "megatools-experimental", because: "experimental version"
  conflicts_with "megatools-experimental-extra", because: "experimental extra version"
  conflicts_with "megatools-stable-extra", because: "stable extra version"

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
