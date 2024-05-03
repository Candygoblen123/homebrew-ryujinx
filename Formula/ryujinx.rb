class Ryujinx < Formula
  desc "Experimental Nintendo Switch Emulator written in C#"
  homepage "https://www.ryujinx.org"
  license "MIT"
  version "1.1.1297"
  url "https://github.com/Ryujinx/Ryujinx.git", tag: "#{version}"
  head "https://github.com/Ryujinx/Ryujinx.git"

  # depends_on "dotnet" => :build

  def install
    # this is a hack, and should be removed as soon as the dotnet formula is up to date enough
    if Cask::CaskLoader.load("dotnet-sdk").installed? == false
      odie "This formulae requires 'homebrew/cask/dotnet-sdk' to be installed.
       To install it, run:
         brew install --cask dotnet-sdk"
    end

    ENV.prepend_path "PATH", "/usr/local/share/dotnet"

    git_hash = `git rev-parse --short HEAD`.strip

    inreplace "src/Ryujinx.Common/ReleaseInformation.cs" do |s|
      s.gsub!("%%RYUJINX_BUILD_VERSION%%", "#{version}")
      s.gsub!("%%RYUJINX_BUILD_GIT_HASH%%", "#{git_hash}")
      s.gsub!("%%RYUJINX_TARGET_RELEASE_CHANNEL_NAME%%", "master")
      s.gsub!("%%RYUJINX_TARGET_RELEASE_CHANNEL_OWNER%%", "brew")
      s.gsub!("%%RYUJINX_TARGET_RELEASE_CHANNEL_REPO%%", "homebrew-ryujinx")
      s.gsub!("%%RYUJINX_CONFIG_FILE_NAME%%", "Config.json")
    end

    system "./distribution/macos/create_macos_build_ava.sh . publish_tmp_ava publish_ava ./distribution/macos/entitlements.xml \"#{version}\" \"#{git_hash}\" Release -p:ExtraDefineConstants=\"DISABLE_UPDATER\""

    prefix.install "publish_ava/Ryujinx.app"
  end

  def caveats
    <<~EOS
      Ryujinx.app was installed to:
        #{prefix}

      To link the application to default Homebrew App location:
        osascript -e 'tell application "Finder" to make alias file to posix file "#{prefix}/Ryujinx.app" at POSIX file "/Applications" with properties {name:"Ryujinx.app"}'

    EOS
  end

  test do
    system "false"
  end
end
