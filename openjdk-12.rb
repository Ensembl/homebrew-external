class Openjdk12 < Formula
  desc "Java Development Kit"
  homepage "https://jdk.java.net/12/"
  # tag origin homebrew-core
  # tag derived

  version "12.0.1"
  url "https://download.java.net/java/GA/jdk12.0.1/69cfe15208a647278a19ef0990eea691/12/GPL/openjdk-12.0.1_linux-x64_bin.tar.gz"
  sha256 "151eb4ec00f82e5e951126f572dc9116104c884d97f91be14ec11e85fc2dd626"

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
