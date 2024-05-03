# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://rubydoc.brew.sh/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
class Ryujinx < Formula
  desc "Experimental Nintendo Switch Emulator written in C#"
  homepage "https://www.ryujinx.org"
  license "MIT"
  version "1.1.1297"
  url "https://github.com/Ryujinx/Ryujinx.git", tag: "#{version}"
  head "https://github.com/Ryujinx/Ryujinx.git"

  # depends_on "dotnet" => :build

  def install
    # brew does not provide 2XX sdk versions in dotnet formula, so we download it manually for now
    dotnet_url = ""
    on_arm do
      dotnet_url = "https://download.visualstudio.microsoft.com/download/pr/8746698c-596d-406e-b672-49a53d77eea7/74c28673e54213d058eec2c9151714cc/dotnet-sdk-8.0.204-osx-arm64.tar.gz"
    end
    on_intel do
      dotnet_url = "https://download.visualstudio.microsoft.com/download/pr/9548c95b-8495-4b69-b6f0-1fdebdbbf9ff/30827786409718c5a9604711661da3b5/dotnet-sdk-8.0.204-osx-x64.tar.gz"
    end
    if Formula["dotnet"].any_version_installed?
      opoo "Downloading dotnet 8.0.204, which brew does not provide. It will only be used for this installation, and will be deleted afterwards."
    end

    ohai "Downloading #{dotnet_url}"
    `curl #{dotnet_url} -o dotnet_sdk.tar.gz`

    mkdir "dotnet-root"
    system "tar zxf dotnet_sdk.tar.gz -C #{buildpath}/dotnet-root"
    ENV.prepend_path "PATH", "#{buildpath}/dotnet-root"
    ENV.append "DOTNET_ROOT", "#{buildpath}/dotnet-root"
    ENV.append "DOTNET_CLI_TELEMETRY_OPTOUT", "1"

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
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test Ryujinx`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "false"
  end
end
