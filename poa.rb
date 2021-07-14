class Poa < Formula
  homepage "https://sourceforge.net/projects/poamsa/"
  # doi "10.1093/bioinformatics/18.3.452"
  # tag "bioinformatics"
  # tag origin homebrew-science
  # tag derived

  url "https://downloads.sourceforge.net/project/poamsa/poamsa/2.0/poaV2.tar.gz"
  version "2.0"
  sha256 "d98d8251af558f442d909a6527694825ef6f79881b7636cad4925792559092c2"

  depends_on "gcc@6"

  fails_with gcc: "7"
  fails_with gcc: "8"
  fails_with gcc: "9"
  fails_with gcc: "10"

  def install
    system "make", "poa"
    bin.install "poa", "make_pscores.pl"
    doc.install "README"
    lib.install "liblpo.a"
    prefix.install "blosum80.mat", "blosum80_trunc.mat", "multidom.pscore", "multidom.seq"
    (include/"poa").install Dir["*.h"]
  end

  test do
    assert_match "poa", shell_output("#{bin}/poa 2>&1", 255)
  end
end
