class Hisat2 < Formula
  desc "graph-based alignment to a population of genomes"
  homepage "https://github.com/DaehwanKimLab/hisat2"
  url "https://github.com/DaehwanKimLab/hisat2/archive/refs/tags/v2.2.1.tar.gz"
  sha256 "f3f4f867d0a6b1f880d64efc19deaa5788c62050e0a4d614ce98b3492f702599"
  # tag "bioinformatics"
  # doi "10.1038/nmeth.3317"
  # tag origin homebrew-science
  # tag derived

  depends_on "gcc@6"

  fails_with gcc: "7"
  fails_with gcc: "8"
  fails_with gcc: "9"
  fails_with gcc: "10"

  def install
    system "make"
    bin.install "hisat2", Dir["hisat2-*"]
    doc.install Dir["doc/*"]
  end

  test do
    assert_match "HISAT2", shell_output("#{bin}/hisat2 2>&1", 1)
  end
end
