require 'timeout'

class Repeatmasker < Formula
  desc "Nucleic and proteic repeat masking tool"
  homepage "http://www.repeatmasker.org/"
  version "4-0-7"
  url "http://www.repeatmasker.org/RepeatMasker-open-#{version}.tar.gz"
  sha256 "16faf40e5e2f521146f6692f09561ebef5f6a022feb17031f2ddb3e3aabcf166"
  revision 2
  
  # tag origin homebrew-science
  # tag derived

  option "without-configure", "Do not run configure"
  option "without-cache", "Do not change the cache directory to use REPEATMASKER_CACHE instead of HOME"
  option "with-dfam", "Use Hmmer and Dfam to mask sequences"

  depends_on "ensembl/external/hmmer" # at least version 3.1 for nhmmer
  depends_on "perl" => :optional
  depends_on "ensembl/external/rmblast"
  depends_on "ensembl/external/trf"
  depends_on "ensembl/moonshine/phrap" => :recommended
  depends_on "ensembl/moonshine/repbase" => :recommended
  depends_on "ensembl/ensembl/dupliconlib" => :optional

  def install
    libexec.install Dir["*"]
    bin.install_symlink libexec/"RepeatMasker"
    bin.install_symlink libexec/"DupMasker"
  end

  def post_install
    open(libexec/"config.in", "w") { |f|
      f.puts(libexec)
      f.puts("#{HOMEBREW_PREFIX}/bin")

      default_is_set = false
      if Formula['ensembl/moonshine/repbase'].installed?
        f.puts(1)
        f.puts("#{HOMEBREW_PREFIX}/bin")
        f.puts("Y")
        default_is_set = true
        Dir.foreach (Formula['ensembl/moonshine/repbase'].opt_libexec) { |f|
          if File.file?("#{Formula['ensembl/moonshine/repbase'].opt_libexec}/#{f}")
            if File.exists?("#{libexec}/Libraries/#{f}")
              if not File.exists?("#{libexec}/Libraries/#{f}.cp") and not File.exists?("#{libexec}/Libraries/#{f}.rm")
                mv("#{libexec}/Libraries/#{f}", "#{libexec}/Libraries/#{f}.cp")
              end
            else
              open("#{libexec}/Libraries/#{f}.rm", "w")
            end
            cp("#{Formula['ensembl/moonshine/repbase'].opt_libexec}/#{f}", "#{libexec}/Libraries/#{f}")
          end
        }
      else
        delete_lib_file = true
        Dir.glob ("#{libexec}/Libraries/*.cp") { |f|
          File.mv(f, f.gsub(".cp", ""))
          if f.equals("#{libexec}/Libraries/RepeatMaskerLib.embl.cp")
            delete_lib_file = false
          end
        }
        Dir.glob ("#{libexec}/Libraries/*.rm") { |f|
          File.delete(f)
          File.delete(f.gsub(".rm", ""))
        }
        if delete_lib_file and File.exists?("#{libexec}/Libraries/RepeatMaskerLib.embl")
          File.delete("#{libexec}/Libraries/RepeatMaskerLib.embl")
        end
      end
      if Formula['ensembl/external/rmblast'].installed?
        f.puts(2)
        f.puts("#{HOMEBREW_PREFIX}/bin")
        if default_is_set
          f.puts("N")
        else
          f.puts("Y")
          default_is_set = true
        end
      end
      if Formula['ensembl/external/hmmer'].installed?
        f.puts(4)
        f.puts("#{HOMEBREW_PREFIX}/bin")
        if default_is_set
          f.puts("N")
        else
          f.puts("Y")
          default_is_set = true
        end
      end
      f.puts(5)
    }

    if build.with? "perl"
      perl = "#{HOMEBREW_PREFIX}/bin"
    elsif ENV.has_key?('HOMEBREW_PLENV_ROOT')
      perl = %x{PLENV_ROOT=#{ENV['HOMEBREW_PLENV_ROOT']} #{ENV['HOMEBREW_PLENV_ROOT']}/bin/plenv which perl}.chomp
    else
      perl = %x{which perl}.chomp
    end

    inreplace libexec/"util/buildRMLibFromEMBL.pl", /^#!.*perl/, "#!#{perl}"

    begin
      Timeout::timeout(600) {
        system "cd #{libexec} && perl configure -re_exec_perl #{perl} < config.in"
      }
    rescue
      odie("'perl configure' failed. You should try 'cd #{libexec} && perl configure -re_exec_perl #{perl}'")
    end

    if build.with? "cache"
      inreplace libexec/"RepeatMaskerConfig.pm", "HOME", "REPEATMASKER_CACHE"
    end
    if File.exists?("#{libexec}/Libraries/dupliconlib.fa")
      File.delete("#{libexec}/Libraries/dupliconlib.fa")
    end
    if Formula['ensembl/ensembl/dupliconlib'].installed?
      Pathname("#{libexec}/Libraries").install_symlink "#{Formula['ensembl/ensembl/dupliconlib'].libexec}/dupliconlib.fa"
    end
  end

  def caveats; <<~EOS
    Congratulations!  RepeatMasker is now ready to use.
    If something went wrong you can reconfigure RepeatMasker
    with:
      brew postinstall ensembl/external/repeatmasker
      or
      cd #{libexec} && ./configure

    You will need to set your environment variable REPEATMASKER_CACHE
    where you want repeatmasker to write the cache files.
    $REPEATMASKER_CACHE/.RepeatMaskerCache should exist and be writeable
      export REPEATMASKER_CACHE=$HOME
      or
      export REPEATMASKER_CACHE=/nfs/path/to/my/project
    EOS
  end

  test do
    (testpath/"hmmer_dna.fa").write(">dna\nATCGAGCTACGAGCGATCATGCGATCATCATAAAAAAAAAAAATATATATATATATATA\n")
    system "RepeatMasker -engine hmmer #{testpath}/hmmer_dna.fa"
    assert File.exist?(testpath/"hmmer_dna.fa.masked")
    assert File.exist?(testpath/"hmmer_dna.fa.out")
    assert File.exist?(testpath/"hmmer_dna.fa.tbl")
    (testpath/"blast_dna.fa").write(">dna\nATCGAGCTACGAGCGATCATGCGATCATCATAAAAAAAAAAAATATATATATATATATA\n")
    (testpath/"blast_dna.lib").write(">TEST1#SIMPLE @test [S:10]\natatatatatatata\n")
    system "RepeatMasker -engine ncbi -lib #{testpath}/blast_dna.lib #{testpath}/blast_dna.fa"
    assert File.exist?(testpath/"blast_dna.fa.masked")
    assert File.exist?(testpath/"blast_dna.fa.out")
    assert File.exist?(testpath/"blast_dna.fa.tbl")
  end
end
