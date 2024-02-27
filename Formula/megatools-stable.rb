class MegatoolsStable < Formula
  desc "Command-line client for Mega.co.nz"
  homepage "https://megatools.megous.com/"
  url "https://github.com/JrMasterModelBuilder/homebrew-megatools/releases/download/sources/megatools-1.11.1.20230212.tar.gz"
  version "1.11.1.20230212"
  sha256 "ecfa2ee4b277c601ebae648287311030aa4ca73ea61ee730bc66bef24ef19a34"

  livecheck do
    url "https://megatools.megous.com/builds/"
    regex(/href=.*?megatools[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "curl"
  depends_on "glib"
  depends_on "glib-networking"
  depends_on "openssl@3"

  uses_from_macos "curl"

  conflicts_with "megatools", because: "homebrew version"
  conflicts_with "megatools-experimental", because: "experimental version"
  conflicts_with "megatools-experimental-extra", because: "experimental extra version"
  conflicts_with "megatools-stable-extra", because: "stable extra version"

  def install
    system "meson", "setup", "build", *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"
  end

  test do
    # From core homebrew formula.
    system "#{bin}/megadl",
      "https://mega.co.nz/#!3Q5CnDCb!PivMgZPyf6aFnCxJhgFLX1h9uUTy9ehoGrEcAkGZSaI",
      "--path", "testfile.txt"
    assert_equal File.read("testfile.txt"), "Hello Homebrew!\n"
  end
end
