class Rmblast < Formula
  desc "RepeatMasker compatible version of the standard NCBI BLAST suite"
  homepage "http://www.repeatmasker.org/RMBlast.html"
  # tag "bioinformatics"
  # tag origin homebrew-science
  # tag derived
  keg_only "Uses software from NCBI blast"

  version "2.10.0"
  if OS.mac?
    url "http://www.repeatmasker.org/rmblast-#{version}+-x64-macosx.tar.gz"
    sha256 "f94e91487b752eb24386c3571250a3394ec7a00e7a5370dd103f574c721b9c81"
  elsif OS.linux?
    url "http://www.repeatmasker.org/rmblast-#{version}+-x64-linux.tar.gz"
    sha256 "e592d0601a98b9764dd55f2aa4815beb1987beb7222f0e171d4f4cd70a0d4a03"
  else
    onoe "Unknown operating system"
  end

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/rmblastn -version")
  end
end
