class MegatoolsExperimental < Formula
  desc "Command-line client for Mega.co.nz"
  homepage "https://megatools.megous.com/"
  url "https://github.com/JrMasterModelBuilder/homebrew-megatools/releases/download/sources/megatools-1.11.0-git-20220401.tar.gz"
  version "1.11.0-git-20220401"
  sha256 "e63fc192c69cb51436beff95940b69e843a0e82314251d28e48e9388c374b3f1"

  livecheck do
    url "https://megatools.megous.com/builds/builds/experimental/"
    regex(/href=.*?megatools[._-]v?(\d+(?:\.[\dx]+)+)\.t/i)
  end

  conflicts_with "megatools", because: "homebrew version"
  conflicts_with "megatools-experimental-extra", because: "experimental extra version"
  conflicts_with "megatools-stable", because: "stable version"
  conflicts_with "megatools-stable-extra", because: "stable extra version"

  depends_on "asciidoc" => :build
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "cmake" => :build
  depends_on "docbook2x" => :build
  depends_on "pkg-config" => :build
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
