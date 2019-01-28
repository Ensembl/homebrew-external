class Blast281 < Formula
  desc "Basic Local Alignment Search Tool"
  homepage "http://blast.ncbi.nlm.nih.gov/"
  # doi "10.1016/S0022-2836(05)80360-2"
  # tag "bioinformatics"
  # tag origin homebrew-core
  # tag derived
  version "2.8.1"

  keg_only "blast #{version} clashes with ensembl/external/blast"
  option 'with-src', 'Build Blast from SRC not using precompiled binaries provided by NCBI'

  if build.with? 'src'
    url "ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/#{version}/ncbi-blast-#{version}+-src.tar.gz"
    sha256 "e03dd1a30e37cb8a859d3788a452c5d70ee1f9102d1ee0f93b2fbd145925118f"
  else
    if OS.linux?
      url "ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/#{version}/ncbi-blast-#{version}+-x64-linux.tar.gz"
      sha256 '6c8216ba652d0af1c11b7e368c988fad58f2cb7ff66c2f2a05c826eac69728a6'
    elsif OS.mac?
      url "ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/#{version}/ncbi-blast-#{version}+-x64-macosx.tar.gz"
      sha256 'ce7f517063ea21e01e8a4341dfb921b68ec73e0706fd15de19dba22a38ff57fc'
    else
      onoe 'Do not know how to support the current OS'
    end
  end

  option "with-static", "Build without static libraries and binaries"
  option "with-dll", "Build dynamic libraries"

  depends_on "freetype" => :optional
  depends_on "gnutls" => :optional
  depends_on "hdf5" => :optional
  depends_on "jpeg" => :recommended
  depends_on "libpng" => :recommended
  depends_on "lzo" => :optional
  depends_on "mysql" => :optional
  depends_on "pcre" => :recommended

  def install

    if build.with? 'src'
      ohai 'Building from source'
      # The libraries and headers conflict with ncbi-c++-toolkit so use libexec.
      args = %W[
        --prefix=#{prefix}
        --libdir=#{libexec}
        --without-debug
        --with-mt
      ]

      args << (build.with?("mysql") ? "--with-mysql" : "--without-mysql")
      args << (build.with?("freetype") ? "--with-freetype=#{Formula["freetype"].opt_prefix}" : "--without-freetype")
      args << (build.with?("gnutls") ? "--with-gnutls=#{Formula["gnutls"].opt_prefix}" : "--without-gnutls")
      args << (build.with?("jpeg")   ? "--with-jpeg=#{Formula["jpeg"].opt_prefix}" : "--without-jpeg")
      args << (build.with?("libpng") ? "--with-png=#{Formula["libpng"].opt_prefix}" : "--without-png")
      args << (build.with?("pcre")   ? "--with-pcre=#{Formula["pcre"].opt_prefix}" : "--without-pcre")
      args << (build.with?("hdf5")   ? "--with-hdf5=#{Formula[""].opt_prefix}" : "--without-hdf5")

      if build.without? "static"
        args << "--with-dll" << "--without-static" << "--without-static-exe"
      else
        args << "--with-static"
        args << "--with-static-exe" unless OS.linux?
        args << "--with-dll" if build.with? "dll"
      end

      cd "c++"

      # The build invokes datatool but its linked libraries aren't installed yet.
      ln_s buildpath/"c++/ReleaseMT/lib", prefix/"libexec" if build.without? "static"

      system "./configure", *args
      system "make"

      rm prefix/"libexec" if build.without? "static"

      system "make", "install"

      # The libraries and headers conflict with ncbi-c++-toolkit.
      libexec.install include
    else
      ohai 'Using NCBI precompiled binaries'
      bin.install Dir['bin/*']
      doc.install 'doc/README.txt'
    end
  end

  def caveats; <<~EOS
    Using the option "--with-static" will create static binaries instead of
    dynamic. The NCBI Blast static installation is approximately 7 times larger
    than the dynamic.

    Static binaries should be used for speed if the executable requires fast
    startup time, such as if another program is frequently restarting the blast
    executables.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/blastn -version")
  end
end
