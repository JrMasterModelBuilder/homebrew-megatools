class MegatoolsExperimentalExtra < Formula
  desc "Command-line client for Mega.co.nz"
  homepage "https://megatools.megous.com/"
  url "https://github.com/JrMasterModelBuilder/homebrew-megatools/releases/download/sources/megatools-1.11.0-git-20220401.tar.gz"
  version "1.11.0-git-20220401"
  sha256 "e63fc192c69cb51436beff95940b69e843a0e82314251d28e48e9388c374b3f1"

  livecheck do
    url "https://megatools.megous.com/builds/experimental/"
    regex(/href=.*?megatools[._-]v?(\d+(?:\.\d+)+\-git\-\d+)\.tar\.gz/i)
  end

  conflicts_with "megatools", because: "Homebrew version"
  conflicts_with "megatools-experimental", because: "Experimental version"
  conflicts_with "megatools-stable", because: "Stable version"
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
    ##########################################################################
    # Network.Browser
    ##########################################################################
    # Extend mega_session and transfer structs with browser member.
    inreplace "lib/mega.c", "gchar *proxy;", <<~'EOS'.strip
      gchar *browser;
      gchar *proxy;
    EOS
    inreplace "lib/mega.c", "t.proxy = s->proxy;", <<~'EOS'.strip
      t.browser = s->browser;
      t.proxy = s->proxy;
    EOS

    # Add functions to set browser similar to proxy.
    inreplace "lib/http.h", "void http_set_proxy(struct http *h, const gchar *proxy);", <<~'EOS'.strip
      void http_set_browser(struct http *h, const gchar *browser);
      void http_set_proxy(struct http *h, const gchar *proxy);
    EOS
    inreplace "lib/http.c", "void http_set_proxy(struct http *h, const gchar *proxy)", <<~'EOS'.strip
      void http_set_browser(struct http *h, const gchar *browser)
      {
        http_set_header(h, "User-Agent", browser);
        http_set_header(h, "Referer", "https://mega.nz/");
        http_set_header(h, "Origin", "https://mega.nz");
        http_set_header(h, "Accept", "*/*");
        http_set_header(h, "Accept-Language", "en-US;q=0.8,en;q=0.3");
        http_set_header(h, "Cache-Control", "no-cache");
        http_set_header(h, "Pragma", "no-cache");
        http_set_header(h, "DNT", "1");
      }

      void http_set_proxy(struct http *h, const gchar *proxy)
    EOS
    inreplace "lib/mega.h", "void mega_session_set_proxy(struct mega_session *s, const gchar *proxy);", <<~'EOS'.strip
      void mega_session_set_browser(struct mega_session *s, const gchar *browser);
      void mega_session_set_proxy(struct mega_session *s, const gchar *proxy);
    EOS
    inreplace "lib/mega.c", "// {{{ mega_session_set_proxy", <<~'EOS'.strip
      // {{{ mega_session_set_browser

      void mega_session_set_browser(struct mega_session *s, const gchar *browser)
      {
        g_return_if_fail(s != NULL);
        g_free(s->browser);
        s->browser = g_strdup(browser);
        http_set_browser(s->http, s->browser);
      }

      // }}}
      // {{{ mega_session_set_proxy
    EOS

    # Read the setting into new global.
    inreplace "lib/tools.c", "static gchar *proxy;", <<~'EOS'.strip
      static gchar *browser;
      static gchar *proxy;
    EOS
    inreplace "lib/tools.c", 'proxy = g_key_file_get_string(kf, "Network", "Proxy", NULL);', <<~'EOS'.strip
      browser = g_key_file_get_string(kf, "Network", "Browser", NULL);
      proxy = g_key_file_get_string(kf, "Network", "Proxy", NULL);
    EOS

    # Set browser when setting the proxy.
    inreplace "lib/tools.c", "if (proxy)", <<~'EOS'.strip
      if (browser)
        mega_session_set_browser(s, browser);
      if (proxy)
    EOS
    inreplace "lib/mega.c", "http_set_proxy(h, s->proxy);", <<~'EOS'.strip
      if (s->browser)
        http_set_browser(h, s->browser);
      http_set_proxy(h, s->proxy);
    EOS
    inreplace "lib/mega.c", "http_set_proxy(h, t->proxy);", <<~'EOS'.strip
      if (t->browser)
        http_set_browser(h, t->browser);
      http_set_proxy(h, t->proxy);
    EOS

    ##########################################################################
    # Network.SkipOverQuota
    ##########################################################################
    # Extend mega_session struct with skip_over_quota member.
    inreplace "lib/mega.c", "gboolean create_preview;", <<~'EOS'.strip
      gboolean skip_over_quota;
      gboolean create_preview;
    EOS

    # Add functions to set skip_over_quota similar to create_preview.
    inreplace "lib/mega.h", "void mega_session_enable_previews(struct mega_session *s, gboolean enable);", <<~'EOS'.strip
      void mega_session_skip_over_quota(struct mega_session *s, gboolean enable);
      void mega_session_enable_previews(struct mega_session *s, gboolean enable);
    EOS
    inreplace "lib/mega.c", "// {{{ mega_session_enable_previews", <<~'EOS'.strip
      // {{{ mega_session_skip_over_quota

      void mega_session_skip_over_quota(struct mega_session *s, gboolean enable)
      {
        g_return_if_fail(s != NULL);

        s->skip_over_quota = enable;
      }

      // }}}
      // {{{ mega_session_enable_previews
    EOS

    # Read the setting into new global.
    inreplace "lib/tools.c", "static gboolean opt_enable_previews = BOOLEAN_UNSET_BUT_TRUE;", <<~'EOS'.strip
      static gboolean skip_over_quota;
      static gboolean opt_enable_previews = BOOLEAN_UNSET_BUT_TRUE;
    EOS
    inreplace "lib/tools.c", 'if (opt_enable_previews == BOOLEAN_UNSET_BUT_TRUE) {', <<~'EOS'.strip
      gboolean skip_over_quota_bool = g_key_file_get_boolean(kf, "Network", "SkipOverQuota", &local_err);
      if (local_err == NULL)
        skip_over_quota = skip_over_quota_bool;
      else
        g_clear_error(&local_err);

      if (opt_enable_previews == BOOLEAN_UNSET_BUT_TRUE) {
    EOS

    # Set when creating session.
    inreplace "lib/tools.c", 'mega_session_enable_previews(s, TRUE);', <<~'EOS'.strip
      mega_session_skip_over_quota(s, skip_over_quota);
      mega_session_enable_previews(s, TRUE);
    EOS

    # Check setting when quota error reached.
    inreplace "lib/mega.c", "if (!download_ok) {", <<~'EOS'.strip
      if (!download_ok) {
        if (
          local_err &&
          local_err->domain == HTTP_ERROR &&
          local_err->code == HTTP_ERROR_BANDWIDTH_LIMIT &&
          s->skip_over_quota
        ) {
          end_time = 0;
        }
    EOS

    ##########################################################################
    # Build
    ##########################################################################
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
