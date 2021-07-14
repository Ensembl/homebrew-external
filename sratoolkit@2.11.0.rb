class SratoolkitAT2110 < Formula
  desc "Data tools for INSDC Sequence Read Archive"
  homepage "https://github.com/ncbi/sra-tools"
  version "2.11.0"
  url "https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/#{version}/sratoolkit.#{version}-centos_linux64.tar.gz"
  sha256 "21592580f0ad19288cc3a9e0b01cdbc9664cecb26771128d5ab6b55f82789d2a"
  license all_of: [:public_domain, "GPL-3.0-or-later", "MIT"]

  def install
    bin.install Dir["bin/*"]
    share.install Dir["schema/*"]
  end

  test do
    # For testing purposes, generate a sample config noninteractively in lieu of running vdb-config --interactive
    # See upstream issue: https://github.com/ncbi/sra-tools/issues/291
    require "securerandom"
    mkdir ".ncbi"
    (testpath/".ncbi/user-settings.mkfg").write "/LIBS/GUID = \"#{SecureRandom.uuid}\"\n"

    assert_match "Read 1 spots for SRR000001", shell_output("#{bin}/fastq-dump -N 1 -X 1 SRR000001")
    assert_match "@SRR000001.1 EM7LVYS02FOYNU length=284", File.read("SRR000001.fastq")
  end
end
