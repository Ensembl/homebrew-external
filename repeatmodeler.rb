class Repeatmodeler < Formula
  desc "De-novo repeat family identification and modeling package"
  homepage "http://www.repeatmasker.org/RepeatModeler.html"
  # tag "bioinformatics"
  # tag origin homebrew-science
  # tag derived

  version "1.0.11"
  url "http://www.repeatmasker.org/RepeatModeler/RepeatModeler-open-#{version}.tar.gz"
  sha256 "7ff0d588b40f9ad5ce78876f3ab8d2332a20f5128f6357413f741bb7fa172193"
  revision 1

  option "without-configure", "Do not run configure"

  depends_on "ensembl/external/recon"
  depends_on "ensembl/external/repeatmasker"
  depends_on "ensembl/external/repeatscout"
  depends_on "ensembl/external/rmblast"
  depends_on "ensembl/external/trf"

  def install
    prefix.install Dir["*"]
    bin.install_symlink %w[../BuildDatabase ../RepeatModeler]

  end

  def post_install
    system "cp", libexec/"RepeatMaskerConfig.tmpl", libexec/"RepeatMaskerConfig.pm"
    inreplace libexec/"RepeatMaskerConfig.pm" do |f|
      f.gsub! /(REPEATMASKER_DIR\s*=)\s*\S+/, '\1 "'.concat(Formula["ensembl/external/repeatmasker"].opt_prefix/"libexec").concat('";')
      f.gsub! /(RMBLAST_DIR\s*=)\s*\S+/, '\1 "'.concat(HOMEBREW_PREFIX).concat('/bin";')
      f.gsub! /(WUBLAST_DIR\s*=)\s*\S+/, '\1 "'.concat(HOMEBREW_PREFIX).concat('/bin";')
      f.gsub! /(DEFAULT_SEARCH_ENGINE\s*=)\s*\S+/, '\1 "ncbi";'
      f.gsub! /(RECON_DIR\s*=)\s*\S+/, '\1 "'.concat(HOMEBREW_PREFIX).concat('/bin";')
      f.gsub! /(TRF_PRGM\s*=)\s*\S+/, '\1 "'.concat(Formula['ensembl/external/trf'].opt_bin).concat('/trf";')
      f.gsub! /(RSCOUT_DIR\s*=)\s*\S+/, '\1 "'.concat(HOMEBREW_PREFIX).concat('/bin";')
    end

    if build.with? "perl"
      perl = Formula["perl"].opt_bin/"perl"
    else
      if ENV.has_key?('HOMEBREW_PLENV_ROOT')
        perl = %x{#{ENV['HOMEBREW_PLENV_ROOT']}/bin/plenv which perl}.chomp
      else
        perl = "/usr/bin/perl"
      end
    end

    for file in ["BuildDatabase", "Refiner", "RepModelConfig.pm.tmpl", "MultAln.pm", "RepeatModeler", "util/viewMSA.pl", "util/dfamConsensusTool.pl", "util/Linup", "util/renameIds.pl", "RepeatClassifier", "SeedAlignment.pm", "TRFMask", "SequenceSimilarityMatrix.pm", "configure", "configure", "NeedlemanWunschGotohAlgorit", "RepeatUtil.pm", "SeedAlignmentCollection.pm"] do
      inreplace "#{libexec}/#{file}", /^#!.*perl/, "#!#{perl}"
    end

  end

  def caveats; <<~EOS
    To reconfigure RepeatModeler, run
      brew postinstall repeatmodeler
    or
      cd #{prefix} && perl ./configure <config.txt
    EOS
  end

  test do
    assert_match version.to_s, shell_output("perl #{bin}/RepeatModeler -v")
  end
end
