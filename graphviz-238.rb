class Graphviz238 < Formula
  desc "Graph visualization software from AT&T and Bell Labs"
  homepage "http://graphviz.org/"
  revision 1

  # tag origin homebrew-core
  # tag derived

  stable do
    url "http://graphviz.org/pub/graphviz/stable/SOURCES/graphviz-2.38.0.tar.gz"
    mirror "https://mirrors.ocf.berkeley.edu/debian/pool/main/g/graphviz/graphviz_2.38.0.orig.tar.gz"
    sha256 "81aa238d9d4a010afa73a9d2a704fc3221c731e1e06577c2ab3496bdef67859e"

    # https://github.com/ellson/graphviz/commit/f97c86e
    # Support either version of ghostcript's error prefixes
    patch do
      url "https://raw.githubusercontent.com/Homebrew/formula-patches/6a6a1a3/graphviz/patch-gvloadimage_gs.c.diff"
      sha256 "bcc0758dd9e0ac17bd1cde63a55a613124814002b470ac4a7a0c421c83a253ab"
    end
  end

  keg_only "Binaries would clash with homebrew-core/graphviz so keg only"

  head do
    url "https://github.com/ellson/graphviz.git"

    depends_on "automake" => :build
    depends_on "autoconf" => :build
    depends_on "libtool" => :build
  end

  # https://github.com/Homebrew/homebrew/issues/14566
  env :std

  depends_on "pkg-config" => :build
  depends_on "pango"
  depends_on "librsvg"
  depends_on "freetype"
  depends_on "libpng"
  
  if build.with? "x11"
    depends_on "libx11"
  end

  fails_with :clang do
    build 318
  end

  patch :p0 do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/ec8d133/graphviz/patch-project.pbxproj.diff"
    sha256 "7c8d5c2fd475f07de4ca3a4340d722f472362615a369dd3f8524021306605684"
  end

  def install
    args = %W[
      --disable-debug
      --disable-dependency-tracking
      --prefix=#{prefix}
      --without-qt
      --with-quartz
    ]
    args << "--disable-swig" if build.without? "bindings"

    system "./configure", *args
    system "make", "install"

    (bin/"gvmap.sh").unlink
  end

  test do
    (testpath/"sample.dot").write <<~EOS
    digraph G {
      a -> b
    }
    EOS

    system "#{bin}/dot", "-Tpdf", "-o", "sample.pdf", "sample.dot"
  end
end
