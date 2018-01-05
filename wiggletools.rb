class Wiggletools < Formula
  desc "Compute genome-wide statistics with composable iterators"
  homepage "https://github.com/Ensembl/WiggleTools"
  url "https://github.com/Ensembl/WiggleTools/archive/v1.2.2.tar.gz"
  sha256 "e9e75b09bcc8aeb012c49937c543e2b05379d3983ba8f6798ca8d6a4171702d9"
  revision 1
  head "https://github.com/Ensembl/WiggleTools.git"
  # tag "bioinformatics"
  # doi "10.1093/bioinformatics/btt737"
  # tag origin homebrew-science
  # tag derived

  depends_on "curl" unless OS.mac?
  depends_on "gsl"
  depends_on "htslib"
  depends_on "libbigwig"

  def install
    system "make"
    pkgshare.install "test"
    lib.install "lib/libwiggletools.a"
    bin.install "bin/wiggletools"
  end

  test do
    cp_r pkgshare/"test", testpath
    cp_r prefix/"bin", testpath
    cd "test" do
      system "python2.7", "test.py"
    end
  end
end