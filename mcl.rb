class Mcl < Formula
  desc "Clustering algorithm for graphs"
  homepage "https://micans.org/mcl"
  url "https://micans.org/mcl/src/mcl-14-137.tar.gz"
  sha256 "b5786897a8a8ca119eb355a5630806a4da72ea84243dba85b19a86f14757b497"
  # doi "10.1093/nar/30.7.1575"
  # tag "bioinformatics"
  # tag origin homebrew-science
  # tag derived

  depends_on "gcc@6" => :build
  fails_with gcc: "7"
  fails_with gcc: "8"
  fails_with gcc: "9"
  fails_with gcc: "10"
 
  def install
    bin.mkpath
    system "./configure",
      "--disable-dependency-tracking",
      "--prefix=#{prefix}",
      "--enable-blast"
    system "make", "install"
    inreplace bin/"mcxdeblast", "/usr/local/bin/perl -w", "/usr/bin/env perl\nuse warnings;"
    inreplace bin/"clxdo", "/usr/local/bin/perl", "perl"
  end

  test do
    system bin/"mcl", "--help"
  end
end
