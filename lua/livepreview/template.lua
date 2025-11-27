local utils = require("livepreview.utils")

local M = {}

local html_template = function(body, stylesheet, script_tag)
	return [[
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Live preview</title>
]] .. stylesheet .. [[
            <link rel="stylesheet" href="/live-preview.nvim/static/katex/katex.min.css">	
            <script defer src="/live-preview.nvim/static/katex/katex.min.js"></script>
			<script defer src="/live-preview.nvim/static/katex/auto-render.min.js" onload="renderMathInElement(document.body);"></script>
            <script src="/live-preview.nvim/static/mermaid/mermaid.min.js"></script>
			<link rel="stylesheet" href="/live-preview.nvim/static/highlight/main.css">
			<script defer src="/live-preview.nvim/static/highlight/highlight.min.js"></script>
]] .. script_tag .. [[
			<script defer src='/live-preview.nvim/static/ws-client.js'></script>
        </head>

        <body>
            <div class="markdown-body">
]] .. body .. [[
            </div>
			<script defer src="/live-preview.nvim/static/katex/main.js"></script>
            <script defer src="/live-preview.nvim/static/mermaid/main.js"></script>
        </body>
        </html>
    ]]
end

M.md2html = function(md)
	local script = [[
		<script defer src="/live-preview.nvim/static/markdown/line-numbers.js"></script>
		<script defer src="/live-preview.nvim/static/markdown/markdown-it-emoji.min.js"></script>
		<script defer src='/live-preview.nvim/static/markdown/markdown-it.min.js'></script>
		<script defer src='/live-preview.nvim/static/markdown/main.js'></script>
	]]
	local stylesheet = [[
        <link rel="stylesheet" href="/live-preview.nvim/static/markdown/github-markdown.min.css">
    ]]
	return html_template(md, stylesheet, script)
end

M.adoc2html = function(adoc)
	local script = [[
		<script defer src="/live-preview.nvim/static/asciidoc/asciidoctor.min.js"></script>
        <script defer src='/live-preview.nvim/static/asciidoc/main.js'></script>
    ]]
	local stylesheet = [[
        <link rel="stylesheet" href="/live-preview.nvim/static/asciidoc/asciidoctor.min.css">
    ]]
	return html_template(adoc, stylesheet, script)
end

local function decode_json(path)
	if not path then
		return nil
	end
	local raw = utils.read_file(path)
	if not raw then
		return nil
	end
	local ok, parsed = pcall(vim.json.decode, raw)
	if not ok or type(parsed) ~= "table" then
		return nil
	end
	return parsed
end

local function hbs2html(template, initial_data)
	local container = [[
        <div id="livepreview-container" class="markdown-body"></div>
    ]]
	local script = [[
		<script>
			const livepreview_template = ]] .. vim.json.encode(template or "") .. [[;
			let livepreview_currentTemplate = livepreview_template;
			const livepreview_initialData = ]] .. vim.json.encode(initial_data or {}) .. [[;

			const livepreview_escapeHtml = (value) =>
				value
					.replace(/&/g, "&amp;")
					.replace(/</g, "&lt;")
					.replace(/>/g, "&gt;")
					.replace(/"/g, "&quot;")
					.replace(/'/g, "&#39;");

			const livepreview_resolve = (data, path) => {
				if (!data || typeof data !== "object") return undefined;
				return path.split(".").reduce((acc, key) => {
					if (acc === undefined || acc === null) return undefined;
					return acc[key];
				}, data);
			};

			const livepreview_renderTemplate = (tpl, data) => {
				const safeTpl = typeof tpl === "string" ? tpl : "";
				const safeData = data && typeof data === "object" ? data : {};
				const stringify = (value) => {
					if (value === null || value === undefined) return "";
					if (typeof value === "object") {
						try {
							return JSON.stringify(value);
						} catch (_) {
							return "";
						}
					}
					return String(value);
				};
				const replaceValue = (raw) => (_match, expr) => {
					const value = livepreview_resolve(safeData, expr.trim());
					const rendered = stringify(value);
					return raw ? rendered : livepreview_escapeHtml(rendered);
				};

				let html = safeTpl.replace(/{{{\s*([^}]+)\s*}}}/g, replaceValue(true));
				html = html.replace(/{{\s*([^}]+)\s*}}/g, replaceValue(false));
				return html;
			};

			const livepreview_fetchData = async () => {
				try {
					const response = await fetch(window.location.pathname + ".json", { cache: "no-store" });
					if (!response.ok) throw new Error("Bad status");
					return await response.json();
				} catch (err) {
					console.warn("live-preview.nvim: failed to load Handlebars data", err);
					return livepreview_initialData;
				}
			};

			const livepreview_applyRender = async (tpl) => {
				const container = document.getElementById("livepreview-container");
				if (!container) return;
				const nextTemplate = typeof tpl === "string" ? tpl : livepreview_currentTemplate;
				const data = await livepreview_fetchData();
				livepreview_currentTemplate = nextTemplate;
				container.innerHTML = livepreview_renderTemplate(livepreview_currentTemplate, data);
			};

			document.addEventListener("DOMContentLoaded", () => {
				livepreview_applyRender(livepreview_template);
			});

			window.livepreview_render = (updatedTemplate) => {
				const tpl = typeof updatedTemplate === "string" ? updatedTemplate : livepreview_currentTemplate;
				livepreview_applyRender(tpl);
			};
		</script>
	]]
	return html_template(container, "", script)
end

M.svg2html = function(svg)
	svg = svg:gsub(
		"</svg>",
		"<script href='/live-preview.nvim/static/ws-client.js' type='application/ecmascript'></script></svg>"
	)
	return [[
		<!DOCTYPE html>
		<html lang="en">

		<head>
		</head>

		<body>
			<div class='markdown-body'>
]] .. svg .. [[
			</div>
		</body>
		</html>
	]]
end

M.toHTML = function(text, filetype, file_path)
	if filetype == "markdown" then
		return M.md2html(text)
	elseif filetype == "asciidoc" then
		return M.adoc2html(text)
	elseif filetype == "hbs" then
		local data = decode_json(file_path and (file_path .. ".json") or nil) or {}
		return hbs2html(text, data)
	elseif filetype == "svg" then
		return M.svg2html(text)
	end
end

M.handle_body = function(data)
	local ws_script = "<script src='/live-preview.nvim/static/ws-client.js'></script>"
	local body
	if data:match("<head>") then
		body = data:gsub("<head>", "<head>" .. ws_script)
	else
		body = ws_script .. data
	end
	return body
end

return M
