class Trnascan < Formula
  desc "Searching for tRNA genes in genomic sequence"
  homepage "http://trna.ucsc.edu/tRNAscan-SE"

  # doi "10.1093/nar/gkab688"
  # tag "bioinformatics"
  # tag origin homebrew-science
  # tag derived

  version "2.0.9"
  url "http://trna.ucsc.edu/software/trnascan-se-#{version}.tar.gz"
  sha256 "566b5c8221bf90c55eb3733e1dbe67ba6b722e70e8eae3065959c0633c02002a"

  depends_on "autoconf" => :build
  depends_on "ensembl/external/infernal"

  def install
    system "mkdir", "bin"
    inreplace "tRNAscan-SE.conf.src", "infernal_dir: {bin_dir}", "infernal_dir: #{HOMEBREW_PREFIX}/bin"

    system "./configure", "--prefix=#{prefix}"
    system "make"
    system "make", "install"
    pkgshare.install Dir["Demo/*"]
  end

  test do
    system "tRNAscan-SE", "-d", "-y", "-o", "test.out", "#{pkgshare}/Example1.fa"
    assert_predicate testpath/"test.out", :exist?
    `diff test.out #{pkgshare}/Example1-tRNAs.out`.empty? ? true : false
  end
end
