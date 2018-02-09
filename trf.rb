class Trf < Formula
  desc "Tandem repeats finder"
  homepage "https://tandem.bu.edu/trf/trf.html"

  if OS.mac?
    url "https://tandem.bu.edu/trf/downloads/trf409.macosx"
    sha256 "383213647a8ddeb08380d2a80bb265d16c925ef16a353c999f811ea5ea6212f8"
  elsif OS.linux?
    url "https://tandem.bu.edu/trf/downloads/trf409.linux64"
    sha256 "536092453453e5ca90327434cc7a0be88e9f40eed17cd15c43d3fb61246af765"
  else
    raise "Unknown operating system"
  end
  version "4.09"

  # doi "10.1093/nar/27.2.573"
  # tag "bioinformatics"
  # tag origin homebrew-science
  # tag derived

  # The license does not permit redistribution. https://tandem.bu.edu/trf/trf.license.html
  bottle :unneeded

  depends_on "patchelf" => :build unless OS.mac?

  def install
    # the download is "trf___.xxxx" so we future proof here
    bin.install Dir["trf*"].first => "trf"
    # as this is a binary, ensure it is using brewed libm, libc etc.
    unless OS.mac?
      system "patchelf",
        "--set-rpath", HOMEBREW_PREFIX,
        "--set-interpreter", HOMEBREW_PREFIX/"lib/ld.so",
        bin/"trf"
    end
  end

  test do
    assert_match "period", shell_output("#{bin}/trf 2>&1", 1)
    (testpath/"test.fa").write <<~EOS
       >seq
       aggaaacctgccatggcctcctggtgagctgtcctcatccactgctcgctgcctctccag
       atactctgacccatggatcccctgggtgcagccaagccacaatggccatggcgccgctgt
       actcccacccgccccaccctcctgatcctgctatggacatggcctttccacatccctgtg
    EOS
    assert_match version.to_s, shell_output("#{bin}/trf #{testpath}/test.fa 2 7 7 80 10 50 500 2>&1", 1)
    out = "#{testpath}/test.fa.2.7.7.80.10.50.500.1.txt.html"
    assert File.exist?(out)
    assert_match "Length: 180", File.read(out)
  end
end
