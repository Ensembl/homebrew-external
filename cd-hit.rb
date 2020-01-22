class CdHit < Formula
  desc "Cluster and compare protein or nucleotide sequences"
  homepage "http://cd-hit.org"
  # doi "10.1093/bioinformatics/btl158"
  # tag "bioinformatics"
  # tag origin homebrew-science
  # tag derived

  version "4.8.1"
  url "https://github.com/weizhongli/cdhit/releases/download/V#{version}/cd-hit-v#{version}-2019-0228.tar.gz"
  sha256 "26172dba3040d1ae5c73ff0ac6c3be8c8e60cc49fc7379e434cdf9cb1e7415de"

  head "https://github.com/weizhongli/cdhit.git"

  # error: 'omp.h' file not found
  needs :openmp

  def install
    args = (ENV.compiler == :clang) ? [] : ["openmp=yes"]

    system "make", *args
    bin.mkpath
    system "make", "PREFIX=#{bin}", "install"
  end

  test do
    assert_match "Usage", shell_output("#{bin}/cd-hit -h", 1)
  end
end
