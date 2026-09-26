-- Paste images from the system clipboard (img-clip.nvim, reads via wl-paste).
-- <leader>p saves the clipboard image under an `assets/` dir next to the
-- current file and inserts a link in the filetype's syntax: ![](...) in
-- markdown, \includegraphics in tex, <img> in html, a bare path elsewhere.
-- At the "File name:" prompt, <CR> on an empty answer uses a timestamp name.
if isModuleAvailable("img-clip") then
    require("img-clip").setup({
        default = {
            dir_path = "assets",
            relative_to_current_file = true,  -- assets/ lives beside the file, not in the cwd
        },
    })

    vim.keymap.set("n", "<leader>p", "<cmd>PasteImage<cr>", { desc = "Paste image from clipboard" })
end
