class Openjdk11 < Formula
  desc "Java Development Kit"
  homepage "https://jdk.java.net/11/"
  # tag origin homebrew-core
  # tag derived

  version "11.0.4"
  url "https://download.oracle.com/otn/java/jdk/11.0.4+10/cf1bbcbf431a474eb9fc550051f4ee78/jdk-11.0.4_linux-x64_bin.tar.gz"
  
  sha256 "45962ed7a08d66775cb036e6f33cd576ecb1eab655c96dbe74851a3ebe1945fa"

  bottle :unneeded
  keg_only "this would clash with other JDKs (and java is selected via jenv anyway)"

  depends_on :linux

  def install
    prefix.install Dir["*"]
    share.mkdir
  end

  test do
    (testpath/"Hello.java").write <<~EOS
      class Hello
      {
        public static void main(String[] args)
        {
          System.out.println("Hello Homebrew");
        }
      }
    EOS
    system bin/"javac", "Hello.java"
    assert_predicate testpath/"Hello.class", :exist?, "Failed to compile Java program!"
    assert_equal "Hello Homebrew\n", shell_output("#{bin}/java Hello")
  end
end
