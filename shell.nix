{pkgs ? (import <nixpkgs> {})}: let
  notoSansFontRegular = pkgs.fetchurl {
    url = "https://github.com/notofonts/notofonts.github.io/raw/refs/heads/main/fonts/NotoSans/unhinted/ttf/NotoSans-Regular.ttf";
    hash = "sha256-VjG6CEn8msf6i2K9gxeqUxDP5UUbm/RUF9liHlJpY+Q=";
  };
  notoSansFontBold = pkgs.fetchurl {
    url = "https://github.com/notofonts/notofonts.github.io/raw/refs/heads/main/fonts/NotoSans/unhinted/ttf/NotoSans-Bold.ttf";
    hash = "sha256-9FCl4vBAmD8Znku4e4lI7kSChouQjgf5tOv8nK4LsDQ=";
  };
  notoSansFontItalic = pkgs.fetchurl {
    url = "https://github.com/notofonts/notofonts.github.io/raw/refs/heads/main/fonts/NotoSans/unhinted/ttf/NotoSans-Italic.ttf";
    hash = "sha256-ZmpkakWtAi6sls+/VLqNxqUcQrkkrTU8NkvJlc06WzE=";
  };
  notoSansFontBoldItalic = pkgs.fetchurl {
    url = "https://github.com/notofonts/notofonts.github.io/raw/refs/heads/main/fonts/NotoSans/unhinted/ttf/NotoSans-BoldItalic.ttf";
    hash = "sha256-D+u9vH5mGKF7NmQ43Ojp/MhXa/34cAJQW0hVF8iyM5o=";
  };

  fonts = [
    notoSansFontRegular
    notoSansFontBold
    notoSansFontItalic
    notoSansFontBoldItalic
  ];

  fontsDrv = pkgs.runCommand "noto-fonts" {} ''
    mkdir -p "$out"
    ${pkgs.lib.concatStringsSep "\n" (builtins.map (font: "ln -s ${font} $out/") fonts)}
  '';
in
  pkgs.mkShellNoCC {
    buildInputs = with pkgs; [
      typst
      pdfpc
      polylux2pdfpc
      typstyle
    ];

    shellHook = ''
      export TYPST_FONT_PATHS=${pkgs.lib.escapeShellArg fontsDrv}
    '';
  }
