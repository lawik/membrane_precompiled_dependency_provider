defmodule Membrane.PrecompiledDependencyProviderTest do
  use ExUnit.Case, async: true

  alias Membrane.PrecompiledDependencyProvider

  @linux_x86 %{architecture: "x86_64", os: "linux", abi: "gnu"}
  @macos_arm %{architecture: "aarch64", os: "darwin23.0.0", abi: "gnu"}

  describe "get_dependency_url(:ffmpeg)" do
    test "defaults to a pinned release hosted by membraneframework-precompiled" do
      assert PrecompiledDependencyProvider.get_dependency_url(:ffmpeg, target: @linux_x86) ==
               "https://github.com/membraneframework-precompiled/precompiled_ffmpeg/releases/download/v6.0.1/ffmpeg_linux64.tar.xz"

      assert PrecompiledDependencyProvider.get_dependency_url(:ffmpeg, target: @macos_arm) ==
               "https://github.com/membraneframework-precompiled/precompiled_ffmpeg/releases/download/v6.0.1/ffmpeg_macos_arm.tar.gz"
    end

    test "returns a pinned URL for every known version" do
      for version <- PrecompiledDependencyProvider.known_ffmpeg_versions(), version != "latest" do
        url =
          PrecompiledDependencyProvider.get_dependency_url(:ffmpeg,
            version: version,
            target: @linux_x86
          )

        assert is_binary(url)
        refute url =~ "latest"
      end
    end

    test "raises on an unknown version instead of falling back to a nightly build" do
      assert_raise ArgumentError, ~r/Unknown FFmpeg version "5.1.2"/, fn ->
        PrecompiledDependencyProvider.get_dependency_url(:ffmpeg,
          version: "5.1.2",
          target: @linux_x86
        )
      end
    end

    test "resolves \"latest\" only when explicitly requested" do
      url =
        PrecompiledDependencyProvider.get_dependency_url(:ffmpeg,
          version: "latest",
          target: @linux_x86
        )

      assert url =~ "/releases/latest/download/"
    end
  end
end
