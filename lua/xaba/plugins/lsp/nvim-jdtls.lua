return {
  "mfussenegger/nvim-jdtls",
  ft = { "java" },
  config = function()
    local jdtls = require("jdtls")

    local function normalize_path(path)
      return path:gsub("\\", "/"):gsub("^%a:", string.lower):lower()
    end

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "java",
      callback = function()
        local home = os.getenv("HOME") or os.getenv("USERPROFILE")

        -- Root detection and normalization
        local root_markers = { "mvnw", "gradlew", "pom.xml", "build.gradle" }
        local raw_root = require("jdtls.setup").find_root(root_markers)
        if not raw_root then return end
        local root_dir = normalize_path(raw_root)

        -- Workspace directory
        local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
        local workspace_dir = normalize_path(home .. "/.local/share/eclipse/" .. project_name)

        -- OS-specific setup
        local jdtls_bin = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
        local config_os = vim.fn.has("mac") == 1 and "mac"
            or vim.fn.has("unix") == 1 and "linux"
            or "win"
        local config_dir = jdtls_bin .. "/config_" .. config_os
        local plugins_dir = jdtls_bin .. "/plugins"
        local lombok_path = jdtls_bin .. "/lombok.jar"
        local jar_path = vim.fn.glob(plugins_dir .. "/org.eclipse.equinox.launcher_*.jar")

        -- Debug/test bundles
        local java_dbg_dir = vim.fn.stdpath("data") .. "/mason/packages/java-debug-adapter/extension/server"
        local java_test_dir = vim.fn.stdpath("data") .. "/mason/packages/java-test/extension/server"
        local bundles = {
          vim.fn.glob(java_dbg_dir .. "/com.microsoft.java.debug.plugin-*.jar")
        }
        vim.list_extend(bundles, vim.split(vim.fn.glob(java_test_dir .. "/*.jar"), "\n"))

        -- LSP config
        local config = {
          cmd = {
            "java",
            "-Declipse.application=org.eclipse.jdt.ls.core.id1",
            "-Dosgi.bundles.defaultStartLevel=4",
            "-Declipse.product=org.eclipse.jdt.ls.core.product",
            "-Dlog.protocol=true",
            "-Dlog.level=ALL",
            "-Xmx1g",
            "--add-modules=ALL-SYSTEM",
            "--add-opens", "java.base/java.util=ALL-UNNAMED",
            "--add-opens", "java.base/java.lang=ALL-UNNAMED",
            "-javaagent:" .. lombok_path,
            "-jar", jar_path,
            "-configuration", config_dir,
            "-data", workspace_dir,
          },
          root_dir = root_dir,
          settings = {
            java = {
              eclipse = { downloadSources = true },
              maven = { downloadSources = true },
              gradle = { downloadSources = true },
              saveActions = { organizeImports = true },
              signatureHelp = { enabled = true },
              contentProvider = { preferred = "fernflower" },
              completion = {
                favoriteStaticMembers = {
                  "org.hamcrest.MatcherAssert.assertThat",
                  "org.hamcrest.Matchers.*",
                  "org.hamcrest.CoreMatchers.*",
                  "org.junit.jupiter.api.Assertions.*",
                  "java.util.Objects.requireNonNull",
                  "java.util.Objects.requireNonNullElse",
                  "org.mockito.Mockito.*"
                },
              },
              filteredTypes = {
                "com.sun.*",
                "io.micrometer.shaded.*",
                "java.awt.*",
                "jdk.*",
                "sun.*"
              },
              importOrder = {
                "java",
                "jakarta",
                "javax",
                "com",
                "org"
              },
              sources = {
                organizeImports = {
                  starThreshold = 9999,
                  staticStarThreshold = 9999,
                },
              },
              codeGeneration = {
                toString = {
                  template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
                },
                hashCodeEquals = { useJava7Objects = true },
                useBlocks = true,
              },
              configuration = {
                updateBuildConfiguration = "interactive",
              },
              inlayHints = {
                parameterNames = { enabled = "all" },
              }
            },
          },
          init_options = {
            bundles = bundles,
          },
          capabilities = require("cmp_nvim_lsp").default_capabilities(),
        }

        config.capabilities.resolveAdditionalTextEditsSupport = true
        config.capabilities = vim.tbl_extend("keep", config.capabilities, jdtls.extendedClientCapabilities)

        jdtls.start_or_attach(config)
        jdtls.setup_dap({ hotcodereplace = "auto" })
      end,
    })
  end,
}
