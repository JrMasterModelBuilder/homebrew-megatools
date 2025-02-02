class MegatoolsStable < Formula
  desc "Command-line client for Mega.co.nz"
  homepage "https://xff.cz/megatools/"
  url "https://github.com/JrMasterModelBuilder/homebrew-megatools/releases/download/sources/megatools-1.11.2.20250127.tar.gz"
  version "1.11.2.20250127"
  sha256 "222a9292542d056b00098bf0a604ea4d0c00764a05c84447e77a856df7c3bbf6"
  license "GPL-2.0-or-later" => { with: "openvpn-openssl-exception" }

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
