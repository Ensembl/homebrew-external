class MafftAT7427 < Formula
  desc "Multiple alignments with fast Fourier transforms"
  homepage "https://mafft.cbrc.jp/alignment/software/"
  # doi "10.1093/nar/gkf436"
  # tag "bioinformatics"
  # tag origin homebrew-core
  # tag derived

  url "https://mafft.cbrc.jp/alignment/software/mafft-7.427-with-extensions-src.tgz"
  sha256 "068abcbc20965cbfa4e14c138cbfbcd0d311874ac2fdde384a580ac774f40e26"

  keg_only "Clashes with linuxbrew mafft"

  depends_on "gcc@6"

  fails_with gcc: "7"
  fails_with gcc: "8"
  fails_with gcc: "9"
  fails_with gcc: "10"

  def install
    make_args = %W[CC=#{ENV.cc} CXX=#{ENV.cxx} PREFIX=#{prefix} install]
    system "make", "-C", "core", *make_args
    system "make", "-C", "extensions", *make_args
  end

  test do
    (testpath/"test.fa").write ">1\nA\n>2\nA"
    output = shell_output("#{bin}/mafft test.fa")
    assert_match ">1\na\n>2\na", output
  end
end
