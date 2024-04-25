{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:

let
  inherit (lib) types mkEnableOption mkIf;
  inherit (lib.nazarick) mkOpt enabled;

  plugins = (
    with pkgs.vimPlugins;
    [
      codeium-nvim
      nvim-cmp
      nvim-hlslens
      nvim-lspconfig
      nvim-notify
      nvim-spider
      nvim-treesitter
      nvim-ufo
      nvim-web-devicons
      cmp-buffer
      cmp-cmdline
      cmp-emoji
      cmp-latex-symbols
      cmp-nvim-lsp
      cmp-nvim-lsp-signature-help
      cmp-path
      cmp_luasnip
      dressing-nvim
      flash-nvim
      friendly-snippets
      gitsigns-nvim
      heirline-nvim
      highlight-undo-nvim
      hydra-nvim
      indent-blankline-nvim
      luasnip
      marks-nvim
      neoconf-nvim
      neodev-nvim
      neorg
      neorg-telescope
      noice-nvim
      nui-nvim
      catppuccin-nvim
      plenary-nvim
      promise-async
      rainbow-delimiters-nvim
      telescope-nvim
      telescope-fzf-native-nvim
      todo-comments-nvim
      ultimate-autopair-nvim
      vim-illuminate
      rustaceanvim
      smart-splits-nvim
      twilight-nvim
      undotree
      vimtex
      yanky-nvim
      vim-pencil
      zen-mode-nvim
      inc-rename-nvim
      bufdelete-nvim
      glance-nvim
      neo-tree-nvim
    ]
  );
  packagedPlugins = [
    (pkgs.vimUtils.buildVimPlugin {
      name = "cutlass.nvim";
      src = pkgs.fetchFromGitHub {
        owner = "gbprod";
        repo = "cutlass.nvim";
        rev = "1ac7e4b53d79410be52a9e464d44c60556282b3e";
        hash = "sha256-zmS/JlcGW8hLWla01F2z9QMfnIYvWr5BkPCoZqzsAFw=";
      };
    })
    (pkgs.vimUtils.buildVimPlugin {
      name = "accelerated-jk.nvim";
      src = pkgs.fetchFromGitHub {
        owner = "rainbowhxch";
        repo = "accelerated-jk.nvim";
        rev = "8fb5dad4ccc1811766cebf16b544038aeeb7806f";
        hash = "sha256-zpjqCARlQU6g50s8wpaqN9xFK4tdUbrxU6MJrQZfSA8=";
      };
    })
    (pkgs.vimUtils.buildVimPlugin {
      name = "luasnip-snippets";
      src = pkgs.fetchFromGitHub {
        owner = "mireq";
        repo = "luasnip-snippets";
        rev = "df849a10585546e70d6d688154c53f9f373df796";
        hash = "sha256-zYGSLcGfd/5Shaak2menHuprPCLL0tb0qZcUXm6Lixc=";
      };
    })
    (pkgs.vimUtils.buildVimPlugin {
      name = "mini.animate";
      src = pkgs.fetchFromGitHub {
        owner = "echasnovski";
        repo = "mini.animate";
        rev = "82519630b2760ffc516ebc387bef632f9c07b9f5";
        hash = "sha256-6TmydrqtiCftpgv050KVJL9OfGoj/3JEkclQqkh4opo=";
      };
    })
    (pkgs.vimUtils.buildVimPlugin {
      name = "mini.hipatterns";
      src = pkgs.fetchFromGitHub {
        owner = "echasnovski";
        repo = "mini.hipatterns";
        rev = "0a72439dbded766af753a3e7ec0a5b21d0f8ada0";
        hash = "sha256-LQviyWJ6b9d/swswRxznBaHaTacYu5m0E7P9rDniNAg=";
      };
    })
    (pkgs.vimUtils.buildVimPlugin {
      name = "mini.surround";
      src = pkgs.fetchFromGitHub {
        owner = "echasnovski";
        repo = "mini.surround";
        rev = "a1b590cc3b676512de507328d6bbab5e43794720";
        hash = "sha256-ATQcAcDAQcT818sLUSJmyOYqLDvNLiCrwAafvD8rAvM=";
      };
    })
    (pkgs.vimUtils.buildVimPlugin {
      name = "scrollEOF.nvim";
      src = pkgs.fetchFromGitHub {
        owner = "Aasim-A";
        repo = "scrollEOF.nvim";
        rev = "38fd5880021e90c15dc61fa325f714bd8077f0a6";
        hash = "sha256-n36L6mtayKtXI/orwf0B72sFpgAKZ0HU4vv2UxKexvU=";
      };
    })
    (pkgs.vimUtils.buildVimPlugin {
      name = "fold-cycle.nvim";
      src = pkgs.fetchFromGitHub {
        owner = "jghauser";
        repo = "fold-cycle.nvim";
        rev = "eab5db9129593d46e58154320e415f2e30cf537e";
        hash = "sha256-CDwqSTi9NVu11wOuu/E63aFtn69kg1BSY1aSPGgcRJM=";
      };
    })
    (pkgs.vimUtils.buildVimPlugin {
      name = "heirline-components.nvim";
      src = pkgs.fetchFromGitHub {
        owner = "Zeioth";
        repo = "heirline-components.nvim";
        rev = "342f713d0daf233d752d1d287e0e114cd277827f";
        hash = "sha256-OkOg/Hd9lQCrc+EEf9TrQjcPqa/hTxrljiTEFsQp92A=";
      };
    })
    (pkgs.vimUtils.buildVimPlugin {
      name = "telescope-egrepify.nvim";
      src = pkgs.fetchFromGitHub {
        owner = "fdschmidt93";
        repo = "telescope-egrepify.nvim";
        rev = "728dc1b7f31297876c3a3254fc6108108b6a9e9d";
        hash = "sha256-6ClthSvXBYRNBVl40H4Dpob5CfhrrXjgdDFi5HQelJc=";
      };
    })
  ];

  cfg = config.nazarick.apps.neovim;
in
{
  options.nazarick.apps.neovim = {
    enable = mkEnableOption "neovim";
  };

  config = mkIf cfg.enable {
    # Lazy (rn) I think is a better choice for me.
    # I'm definitely interested in fully packaging my neovim config,
    # but for now I can meet in the middle and have my LSP stuff be defined here.

    # So, luajit will cache lua files. The linked file below will never change it's 
    # metadata (time), so luajit will never recompile it. So json it is!

    home.file.".local/share/nvim/binaries_data.json".text = ''
      {
        "lsp": {
          "lua_ls": "${pkgs.lua-language-server}/bin/lua-language-server",
          "texlab": "${pkgs.texlab}/bin/texlab",
          "svls": "${pkgs.svls}/bin/svls",
          "nil_ls": "${pkgs.nil}/bin/nil"
        }
      }
    '';

    home.sessionVariables = {
      EDITOR = "nvim";
    };

    programs.neovim = {
      enable = true;
      # package = pkgs.neovim-nightly;

      # plugins = plugins ++ packagedPlugins;
      plugins = with pkgs.vimPlugins; [ codeium-nvim ];
      defaultEditor = true;
      withNodeJs = false;
      withRuby = false;
      withPython3 = false;
    };
  };
}
