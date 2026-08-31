class UvcUtil < Formula
  desc "USB Video Class (UVC) control management utility for macOS"
  homepage "https://github.com/jtfrey/uvc-util"
  license "MIT"
  head "https://github.com/jtfrey/uvc-util.git", branch: "master"
  # The stable url/version/sha256 lines are written here by
  # .github/workflows/release.yml each time a vN.N tag is pushed; they point at
  # the signed universal binary attached to that release.  Until the first such
  # release exists this formula builds from the tip of master.

  depends_on macos: :monterey

  def install
    # Release tarballs carry a prebuilt universal binary; a source checkout
    # (--HEAD, or a source tarball) is built through the Makefile.
    if File.exist?("uvc-util")
      bin.install "uvc-util"
    else
      system "make", "install", "PREFIX=#{prefix}"
    end
  end

  test do
    assert_match "list-devices", shell_output("#{bin}/uvc-util --help")
    # --list-devices needs a camera attached, so exercise the device-independent
    # control table instead.
    assert_match "brightness", shell_output("#{bin}/uvc-util --list-controls")
  end
end
