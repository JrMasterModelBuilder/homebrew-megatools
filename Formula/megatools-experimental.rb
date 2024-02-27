class MegatoolsExperimental < Formula
  desc "Command-line client for Mega.co.nz"
  homepage "https://megatools.megous.com/"
  url "https://github.com/JrMasterModelBuilder/homebrew-megatools/releases/download/sources/megatools-1.11.x.20220919.tar.gz"
  version "1.11.x.20220919"
  sha256 "1106ed8338789be54a9162023e57ec408a12b4069d2179f6cafe88e0e84a1d95"
  license "GPL-2.0-or-later" => { with: "openvpn-openssl-exception" }
  revision 1

  livecheck do
    url "https://megatools.megous.com/builds/builds/experimental/"
    regex(/href=.*?megatools[._-]v?(\d+(?:\.[\dx]+)+)\.t/i)
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "glib"
  depends_on "glib-networking"
  depends_on "openssl@3"

  uses_from_macos "curl"

  conflicts_with "megatools", because: "homebrew version"
  conflicts_with "megatools-experimental-extra", because: "experimental extra version"
  conflicts_with "megatools-stable", because: "stable version"
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
